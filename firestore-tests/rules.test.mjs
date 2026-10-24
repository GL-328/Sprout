// Tests for ../firestore.rules against the Firestore emulator.
// Run: cd firestore-tests && npm install && npm test
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, it } from 'node:test';
import { assertFails, assertSucceeds, initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, getDocs, collection, setDoc, writeBatch, serverTimestamp } from 'firebase/firestore';

let env;
const today = () => Math.floor(Date.now() / 86400000);
const stamp = () => {
  const d = new Date();
  return `${d.getUTCFullYear()}${String(d.getUTCMonth() + 1).padStart(2, '0')}${String(d.getUTCDate()).padStart(2, '0')}`;
};

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-sprout',
    firestore: { rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8') },
  });
});
after(async () => env?.cleanup());
beforeEach(async () => env.clearFirestore());

const db = (uid) => env.authenticatedContext(uid).firestore();
/** Seeds data with rules switched off. */
const seed = (fn) => env.withSecurityRulesDisabled((ctx) => fn(ctx.firestore()));

/** A request from [from] to [to], with the daily counter, as the app writes it.
 *  The app always creates the sender's profile first, when Friends is turned on. */
async function sendRequest(from, to, count = 1) {
  await seed((s) => setDoc(doc(s, 'users', from), { name: from }, { merge: true }));
  const d = db(from);
  const batch = writeBatch(d);
  batch.set(doc(d, 'requests', `${from}_${to}`), { from, to, fromName: from, at: serverTimestamp() });
  batch.set(doc(d, 'users', from), { reqDay: today(), reqCount: count }, { merge: true });
  return batch.commit();
}

async function makeFriends(a, b) {
  await seed(async (d) => {
    await setDoc(doc(d, 'users', a), { name: a });
    await setDoc(doc(d, 'users', b), { name: b });
    await setDoc(doc(d, 'users', a, 'friends', b), { name: b });
    await setDoc(doc(d, 'users', b, 'friends', a), { name: a });
  });
}

describe('friend codes', () => {
  it('can be claimed once by their owner', async () => {
    await assertSucceeds(setDoc(doc(db('alice'), 'codes', 'ABCD2345'), { uid: 'alice' }));
    await assertFails(setDoc(doc(db('bob'), 'codes', 'ABCD2345'), { uid: 'bob' }));
  });
  it('cannot be claimed for someone else, or with confusing letters', async () => {
    await assertFails(setDoc(doc(db('alice'), 'codes', 'ABCD2346'), { uid: 'bob' }));
    await assertFails(setDoc(doc(db('alice'), 'codes', 'ABCDO234'), { uid: 'alice' }));
    await assertFails(setDoc(doc(db('alice'), 'codes', 'ABC'), { uid: 'alice' }));
  });
  it('can be looked up when signed in, not otherwise', async () => {
    await seed((d) => setDoc(doc(d, 'codes', 'ABCD2345'), { uid: 'alice' }));
    await assertSucceeds(getDoc(doc(db('bob'), 'codes', 'ABCD2345')));
    await assertFails(getDoc(doc(env.unauthenticatedContext().firestore(), 'codes', 'ABCD2345')));
  });
});

describe('profiles and gardens', () => {
  it('only hold a name, code, garden snapshot and request counter', async () => {
    const me = db('alice');
    await assertSucceeds(setDoc(doc(me, 'users', 'alice'), { name: 'Alice', snapshot: { plots: [] } }));
    await assertFails(setDoc(doc(me, 'users', 'alice'), { name: 'Alice', mood: 3 }));
    await assertFails(setDoc(doc(me, 'users', 'alice'), { name: 'Alice', snapshot: { plots: [], quests: [] } }));
    await assertFails(setDoc(doc(me, 'users', 'alice'), { name: 'A'.repeat(21) }));
    await assertFails(setDoc(doc(me, 'users', 'bob'), { name: 'Bob' }));
  });
  it('are visible to friends only', async () => {
    await makeFriends('alice', 'bob');
    await assertSucceeds(getDoc(doc(db('bob'), 'users', 'alice')));
    await assertFails(getDoc(doc(db('carol'), 'users', 'alice')));
  });
});

describe('friend requests', () => {
  it('can be sent with the daily counter', async () => {
    await seed((d) => setDoc(doc(d, 'users', 'alice'), { name: 'Alice' }));
    await assertSucceeds(sendRequest('alice', 'bob'));
  });
  it('must count towards the daily limit', async () => {
    await assertFails(setDoc(doc(db('alice'), 'requests', 'alice_bob'), { from: 'alice', to: 'bob', fromName: 'A' }));
  });
  it('stop at 10 a day', async () => {
    await seed((d) => setDoc(doc(d, 'users', 'alice'), { name: 'Alice', reqDay: today(), reqCount: 10 }));
    await assertFails(sendRequest('alice', 'bob', 11));
  });
  it('cannot be sent to yourself, as someone else, or to someone who blocked you', async () => {
    await assertFails(sendRequest('alice', 'alice'));
    const d = db('alice');
    await assertFails(setDoc(doc(d, 'requests', 'bob_carol'), { from: 'bob', to: 'carol', fromName: 'B' }));
    await seed((s) => setDoc(doc(s, 'users', 'bob', 'blocked', 'alice'), { at: 1 }));
    await assertFails(sendRequest('alice', 'bob'));
  });
  it('are seen only by the two people, and either can remove them', async () => {
    await sendRequest('alice', 'bob');
    await assertSucceeds(getDoc(doc(db('bob'), 'requests', 'alice_bob')));
    await assertFails(getDoc(doc(db('carol'), 'requests', 'alice_bob')));
    await assertSucceeds(deleteDoc(doc(db('bob'), 'requests', 'alice_bob')));
  });
});

describe('friendships', () => {
  function accept(by, from) {
    const d = db(by);
    const batch = writeBatch(d);
    batch.set(doc(d, 'users', by, 'friends', from), { name: from });
    batch.set(doc(d, 'users', from, 'friends', by), { name: by });
    batch.delete(doc(d, 'requests', `${from}_${by}`));
    return batch.commit();
  }
  it('are made by accepting a request', async () => {
    await sendRequest('alice', 'bob');
    await assertSucceeds(accept('bob', 'alice'));
  });
  it('cannot be made without a request', async () => {
    await assertFails(accept('bob', 'alice'));
    await assertFails(setDoc(doc(db('carol'), 'users', 'alice', 'friends', 'bob'), { name: 'Bob' }));
  });
  it('cannot be accepted by the person who asked', async () => {
    await sendRequest('alice', 'bob');
    await assertFails(accept('alice', 'bob'));
  });
  it('can be ended by either friend', async () => {
    await makeFriends('alice', 'bob');
    await assertSucceeds(deleteDoc(doc(db('alice'), 'users', 'bob', 'friends', 'alice')));
    await assertFails(deleteDoc(doc(db('carol'), 'users', 'bob', 'friends', 'alice')));
  });
});

describe('visits', () => {
  const note = (uid) => ({ visitor: uid, name: uid, day: stamp(), at: serverTimestamp() });
  it('can be left once a day by a friend', async () => {
    await makeFriends('alice', 'bob');
    const ref = doc(db('bob'), 'users', 'alice', 'visits', `bob_${stamp()}`);
    await assertSucceeds(setDoc(ref, note('bob')));
    await assertFails(setDoc(ref, note('bob')));
  });
  it('cannot be left by strangers or in someone else’s name', async () => {
    await makeFriends('alice', 'bob');
    await assertFails(setDoc(doc(db('carol'), 'users', 'alice', 'visits', `carol_${stamp()}`), note('carol')));
    await assertFails(setDoc(doc(db('bob'), 'users', 'alice', 'visits', `carol_${stamp()}`), note('bob')));
  });
  it('are read by the host only', async () => {
    await makeFriends('alice', 'bob');
    await assertSucceeds(getDocs(collection(db('alice'), 'users', 'alice', 'visits')));
    await assertFails(getDocs(collection(db('bob'), 'users', 'alice', 'visits')));
  });
});
