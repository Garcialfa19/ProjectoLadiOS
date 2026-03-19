import { readFile } from "node:fs/promises";
import process from "node:process";
import { initializeApp, cert } from "firebase-admin/app";
import { getFirestore, Timestamp } from "firebase-admin/firestore";

const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
const projectId = process.env.FIREBASE_PROJECT_ID;
const eventsFilePath = process.env.EVENTS_FILE_PATH ?? "docs/firestore-example-events.json";

if (!serviceAccountPath) {
  console.error("Missing FIREBASE_SERVICE_ACCOUNT_PATH");
  process.exit(1);
}

const serviceAccount = JSON.parse(await readFile(serviceAccountPath, "utf8"));

initializeApp({
  credential: cert(serviceAccount),
  projectId: projectId ?? serviceAccount.project_id
});

const firestore = getFirestore();
const rawEvents = JSON.parse(await readFile(eventsFilePath, "utf8"));

for (const rawEvent of rawEvents) {
  const { documentID, startDate, endDate, doorsOpen, ...rest } = rawEvent;

  if (!documentID) {
    console.error("Event is missing documentID");
    process.exit(1);
  }

  await firestore.collection("events").doc(documentID).set({
    ...rest,
    startDate: Timestamp.fromDate(new Date(startDate)),
    endDate: Timestamp.fromDate(new Date(endDate)),
    doorsOpen: doorsOpen ? Timestamp.fromDate(new Date(doorsOpen)) : null
  }, { merge: true });

  console.log(`Seeded event: ${documentID}`);
}

console.log("Done seeding Firestore events.");
