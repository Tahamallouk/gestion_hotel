// Firestore security rules tests using @firebase/rules-unit-testing
// Run with: npm install --save-dev @firebase/rules-unit-testing firebase-admin
// then: npx mocha rules/firestore.rules.spec.js

const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const fs = require('fs');
const path = require('path');

const PROJECT_ID = 'demo-project';
const RULES_PATH = path.join(__dirname, '..', 'firestore.rules');
const FIRESTORE_EMULATOR_HOST = process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:9220';
const [FIRESTORE_HOST, FIRESTORE_PORT] = FIRESTORE_EMULATOR_HOST.split(':');

let testEnv;

function getAuthedDb(auth) {
  return testEnv.authenticatedContext(auth?.uid ?? null).firestore();
}

async function seedReservation(docId, data) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context.firestore().collection('reservations').doc(docId).set(data);
  });
}

describe('Firestore rules', () => {
  before(async () => {
    testEnv = await initializeTestEnvironment({
      projectId: PROJECT_ID,
      firestore: {
        host: FIRESTORE_HOST,
        port: Number(FIRESTORE_PORT),
        rules: fs.readFileSync(RULES_PATH, 'utf8'),
      },
    });
  });

  after(async () => {
    if (testEnv) {
      await testEnv.cleanup();
    }
  });

  it('denies reservation read for other users', async () => {
    await seedReservation('r1', { userId: 'userA' });

    const db = getAuthedDb({ uid: 'userB' });
    await assertFails(db.collection('reservations').doc('r1').get());
  });

  it('allows owner reservation read', async () => {
    await seedReservation('r2', { userId: 'userA' });

    const db = getAuthedDb({ uid: 'userA' });
    await assertSucceeds(db.collection('reservations').doc('r2').get());
  });

  it('enforces immutable reservation core fields on update', async () => {
    await seedReservation('r3', {
      userId: 'userA',
      roomId: 'room1',
      startDate: new Date(),
      endDate: new Date(Date.now() + 86400000),
      qrToken: 'qr123',
      totalPriceSnapshot: 123,
      status: 'confirmed',
    });

    const db = getAuthedDb({ uid: 'userA' });
    await assertFails(
      db.collection('reservations').doc('r3').update({ roomId: 'other' }),
    );
  });

  it('allows status update by owner', async () => {
    await seedReservation('r4', {
      userId: 'userA',
      roomId: 'room1',
      startDate: new Date(),
      endDate: new Date(Date.now() + 86400000),
      qrToken: 'qr123',
      totalPriceSnapshot: 123,
      status: 'confirmed',
    });

    const db = getAuthedDb({ uid: 'userA' });
    await assertSucceeds(
      db.collection('reservations').doc('r4').update({ status: 'cancelled' }),
    );
  });
});
