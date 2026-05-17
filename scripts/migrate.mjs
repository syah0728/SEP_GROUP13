/**
 * Migration script: update existing Firebase documents to use ERD field names.
 * Safe to run multiple times (uses setDoc with merge or updateDoc).
 */

import { initializeApp } from 'firebase/app';
import {
  getFirestore,
  doc,
  updateDoc,
  writeBatch,
  collection,
  getDocs,
} from 'firebase/firestore';

const firebaseConfig = {
  apiKey: 'AIzaSyBuheboasrj089fkEtKoJSyc8b1mAQy-qE',
  authDomain: 'sams13-attendanceoperation.firebaseapp.com',
  projectId: 'sams13-attendanceoperation',
  storageBucket: 'sams13-attendanceoperation.firebasestorage.app',
  messagingSenderId: '763588114877',
  appId: '1:763588114877:web:07190d64c526273b3afad4',
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

// ── lecturers ─────────────────────────────────────────────────────────────────
// ERD: lecturerID, lecturer_name, email, department
// Old: lecturerId, name, title, semesterLabel

async function migrateLecturers() {
  const snap = await getDocs(collection(db, 'lecturers'));
  const b = writeBatch(db);
  snap.forEach(d => {
    const data = d.data();
    b.update(d.ref, {
      lecturerID:    data.lecturerID    ?? data.lecturerId    ?? d.id,
      lecturer_name: data.lecturer_name ?? data.name          ?? '',
      department:    data.department    ?? data.title         ?? '',
      email:         data.email         ?? '',
    });
  });
  await b.commit();
  console.log(`✓ lecturers migrated (${snap.size} docs)`);
}

// ── students ──────────────────────────────────────────────────────────────────
// ERD: studentID, studentName, programme, password, semester, lecturerID, total_credits
// Old: studentId, name, program

async function migrateStudents() {
  const snap = await getDocs(collection(db, 'students'));
  const b = writeBatch(db);
  snap.forEach(d => {
    const data = d.data();
    b.update(d.ref, {
      studentID:     data.studentID     ?? data.studentId  ?? d.id,
      studentName:   data.studentName   ?? data.name       ?? '',
      programme:     data.programme     ?? data.program    ?? '',
      semester:      data.semester      ?? 'Semester 2, 2025/2026',
      lecturerID:    data.lecturerID    ?? 'LE210145',
      total_credits: data.total_credits ?? 0,
      password:      data.password      ?? 'student123',
    });
  });
  await b.commit();
  console.log(`✓ students migrated (${snap.size} docs)`);
}

// ── courses ───────────────────────────────────────────────────────────────────
// ERD: course_id, course_name, credits, lecturer_name, description, staffID, is_published, lecturerID
// Old: courseCode, courseName, lecturerName, lecturerId

async function migrateCourses() {
  const snap = await getDocs(collection(db, 'courses'));
  const b = writeBatch(db);
  snap.forEach(d => {
    const data = d.data();
    b.update(d.ref, {
      course_id:    data.course_id    ?? data.courseCode  ?? d.id,
      course_name:  data.course_name  ?? data.courseName  ?? '',
      lecturer_name: data.lecturer_name ?? data.lecturerName ?? '',
      lecturerID:   data.lecturerID   ?? data.lecturerId  ?? '',
      credits:      data.credits      ?? 3,
      is_published: data.is_published ?? true,
      staffID:      data.staffID      ?? 'REG001',
    });
  });
  await b.commit();
  console.log(`✓ courses migrated (${snap.size} docs)`);
}

// ── enrollments ───────────────────────────────────────────────────────────────
// ERD: studentID, course_id, semester, status, is_registration_open
// Old: studentId, courseCode

async function migrateEnrollments() {
  const snap = await getDocs(collection(db, 'enrollments'));
  const b = writeBatch(db);
  snap.forEach(d => {
    const data = d.data();
    b.update(d.ref, {
      studentID:           data.studentID           ?? data.studentId  ?? '',
      course_id:           data.course_id           ?? data.courseCode ?? '',
      // keep denormalized fields for app reads — add ERD field names alongside
      course_name:         data.course_name         ?? data.courseName ?? '',
      lecturer_name:       data.lecturer_name       ?? data.lecturerName ?? '',
      semester:            data.semester            ?? 'Semester 2, 2025/2026',
      status:              data.status              ?? 'active',
      is_registration_open: data.is_registration_open ?? true,
    });
  });
  await b.commit();
  console.log(`✓ enrollments migrated (${snap.size} docs)`);
}

// ── attendanceSessions ────────────────────────────────────────────────────────
// ERD: courseID, lecturerID
// Old: courseCode, lecturerId

async function migrateAttendanceSessions() {
  const snap = await getDocs(collection(db, 'attendanceSessions'));
  if (snap.empty) { console.log('✓ attendanceSessions — no docs'); return; }
  const b = writeBatch(db);
  snap.forEach(d => {
    const data = d.data();
    b.update(d.ref, {
      courseID:   data.courseID   ?? data.courseCode ?? '',
      lecturerID: data.lecturerID ?? data.lecturerId ?? '',
    });
  });
  await b.commit();
  console.log(`✓ attendanceSessions migrated (${snap.size} docs)`);
}

// ── attendanceRecords ─────────────────────────────────────────────────────────
// ERD: sessionID, courseID, studentID, matricID
// Old: sessionId, courseCode, studentId, matricId

async function migrateAttendanceRecords() {
  const snap = await getDocs(collection(db, 'attendanceRecords'));
  if (snap.empty) { console.log('✓ attendanceRecords — no docs'); return; }
  const b = writeBatch(db);
  snap.forEach(d => {
    const data = d.data();
    b.update(d.ref, {
      sessionID: data.sessionID ?? data.sessionId ?? '',
      courseID:  data.courseID  ?? data.courseCode ?? '',
      studentID: data.studentID ?? data.studentId  ?? '',
      matricID:  data.matricID  ?? data.matricId   ?? '',
    });
  });
  await b.commit();
  console.log(`✓ attendanceRecords migrated (${snap.size} docs)`);
}

// ── schedules ─────────────────────────────────────────────────────────────────
// Keep courseCode for now (implementation detail, not in ERD)
// No migration needed

async function main() {
  console.log('Migrating Firebase field names to match ERD...\n');
  try {
    await migrateLecturers();
    await migrateStudents();
    await migrateCourses();
    await migrateEnrollments();
    await migrateAttendanceSessions();
    await migrateAttendanceRecords();
    console.log('\nMigration selesai!');
  } catch (err) {
    console.error('Error:', err.message);
  }
  process.exit(0);
}

main();
