// ============================================================
// FinancialController.dart
// Module  : Manage Financial
// Project : sams-app (Firebase project ID)
// Used by : BOTH Student and Treasury
//
// All Firestore collection/document paths here match exactly
// what is in your sams-app Firestore database.
//
// DATABASE PATHS USED:
//   students/{studentId}/financial/current  ← student financial data
//   payments/{autoId}                       ← payment records
//   notifications/{autoId}                  ← student notifications
//   fee_records/{autoId}                    ← monthly fee records
//   summary/semester                        ← dashboard summary
// ============================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/manage_financial/financial_model.dart';
import '../../services/report_services.dart';
import '../../services/session_service.dart';

class FinancialController extends ChangeNotifier {
  // ── Firestore instance connected to sams-app database ────
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Shared loading and error state ───────────────────────
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners(); // tells all watching screens to rebuild
  }

  // ══════════════════════════════════════════════════════════
  // STUDENT SECTION
  // Screens: student_financial_page, student_payment_history,
  //          student_make_payment, student_payment_summary,
  //          student_payment_success, student_notifications
  // ══════════════════════════════════════════════════════════

  FinancialModel? _studentFinancial; // current student data
  List<PaymentHistoryModel> _paymentHistory = [];
  List<NotificationModel> _notifications = [];
  PaymentMethod? _selectedMethod; // chosen payment method
  String _selectedFeeType = 'All Fees';
  ReceiptModel? _lastReceipt; // generated after payment

  FinancialModel? get studentFinancial => _studentFinancial;
  List<PaymentHistoryModel> get paymentHistory => _paymentHistory;
  List<NotificationModel> get notifications => _notifications;
  PaymentMethod? get selectedMethod => _selectedMethod;
  String get selectedFeeType => _selectedFeeType;
  ReceiptModel? get lastReceipt => _lastReceipt;

  // ── Load student financial data from studentFees collection ──
  Future<void> loadStudentFinancial(String studentId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      // Read from studentFees collection, match by studentID field
      final snap = await _db
          .collection('studentFees')
          .where('studentID', isEqualTo: studentId)
          .limit(1)
          .get(const GetOptions(source: Source.server));

      if (snap.docs.isNotEmpty) {
        final data = snap.docs.first.data();

        // Get studentName from students collection (safe — won't crash if missing)
        String studentName = '';
        try {
          final studentSnap = await _db
              .collection('students')
              .where('studentID', isEqualTo: studentId)
              .limit(1)
              .get();
          if (studentSnap.docs.isNotEmpty) {
            studentName = studentSnap.docs.first.data()['studentName'] ?? '';
          }
        } catch (_) {}

        _studentFinancial = FinancialModel.fromMap(data, studentName: studentName);

        // Effective block = manual block OR deadline overdue with unpaid fees
        final manualBlock   = _studentFinancial!.isBlocked;
        final autoBlock     = _studentFinancial!.deadlineOverdue &&
                              _studentFinancial!.totalOutstanding > 0;
        final effectiveBlock = manualBlock || autoBlock;

        // Sync isBlocked in Firestore if it differs from effective value
        if (effectiveBlock != manualBlock) {
          try {
            await snap.docs.first.reference.update({'isBlocked': effectiveBlock});
            if (effectiveBlock) {
              await _db.collection('notifications').add({
                'studentID': studentId,
                'title':     'Account Blocked',
                'message':   'Your account has been blocked due to outstanding fees '
                             'past the payment deadline. Please settle your fees to restore access.',
                'createdAt': FieldValue.serverTimestamp(),
                'type':      'blocked',
                'isRead':    false,
              });
            }
          } catch (_) {}
        }

        AppSession.setBlocked(effectiveBlock);
      } else {
        _studentFinancial = null;
        _errorMessage = 'No record found for "$studentId". Check Firestore Rules — studentFees collection may be blocked.';
      }
    } catch (e) {
      _studentFinancial = null;
      _errorMessage = 'Error: $e';
    }
    _setLoading(false);
  }

  // ── Load student payment history from sams-app Firestore ─
  // Reads from: payments (filtered by studentId, newest first)
  // Falls back to fetching by paymentID from studentFees if query returns empty.
  Future<void> loadPaymentHistory(String studentId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final snap = await _db
          .collection('payments')
          .where('studentID', isEqualTo: studentId)
          .get();

      if (snap.docs.isNotEmpty) {
        _paymentHistory = snap.docs
            .map((d) => PaymentHistoryModel.fromMap(d.data(), d.id))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      } else {
        // Fallback: fetch the payment linked in studentFees by paymentID
        final payId = _studentFinancial?.paymentID ?? '';
        if (payId.isNotEmpty) {
          final doc = await _db.collection('payments').doc(payId).get();
          if (doc.exists) {
            _paymentHistory = [PaymentHistoryModel.fromMap(doc.data()!, doc.id)];
          } else {
            _paymentHistory = [];
          }
        } else {
          _paymentHistory = [];
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load payment history: $e';
    }
    _setLoading(false);
  }

  // ── Load student notifications from sams-app Firestore ───
  // Reads from: notifications (filtered by studentId)
  Future<void> loadNotifications(String studentId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final snap = await _db
          .collection('notifications')
          .where('studentID', isEqualTo: studentId)
          .get();

      _notifications = snap.docs
          .map((d) => NotificationModel.fromMap(d.data(), d.id))
          .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      _errorMessage = 'Failed to load notifications: $e';
    }
    _setLoading(false);
  }

  // ── Student selects payment method ────────────────────────
  // Called from: student_make_payment_page
  void selectPaymentMethod(PaymentMethod method) {
    _selectedMethod = method;
    notifyListeners();
  }

  // ── Student selects fee type ──────────────────────────────
  // Called from: student_make_payment_page dropdown
  void selectFeeType(String feeType) {
    _selectedFeeType = feeType;
    notifyListeners();
  }

  // ── Process student payment → writes to sams-app Firestore
  // Writes to:
  //   payments/{autoId}                    ← new payment record
  //   students/{studentId}/financial/current ← updated balance
  //   notifications/{autoId}               ← confirmation notice
  Future<bool> processPayment({
    required String studentId,
    required String studentName,
    required String semester,
    required double amount,
    required String bank,
  }) async {
    if (_selectedMethod == null) return false;
    _setLoading(true);
    _errorMessage = null;

    try {
      // Generate unique reference and receipt numbers
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = 'MBB$timestamp';
      final rcpNo = '#RCP-${DateTime.now().year}-${timestamp % 100000}';

      // ── Write payment record to payments collection ───────
      final bd = _studentFinancial?.feeBreakdown;
      await _db.collection('payments').add({
        'studentID':     studentId,
        'studentName':   studentName,
        'semester':      semester,
        'educationFee':  bd?.educationFee ?? 0,
        'hostelFee':     bd?.hostelFee    ?? 0,
        'otherFee':      bd?.otherFee     ?? 0,
        'totalAmount':   amount,
        'paymentMethod': _selectedMethod!.label,
        'receiptNo':     ref,
        'paymentStatus': 'paid',
        'createdAt':     FieldValue.serverTimestamp(),
      });

      // ── Update balance using Firestore transaction ────────
      final feeQuery = await _db
          .collection('studentFees')
          .where('studentID', isEqualTo: studentId)
          .limit(1)
          .get();

      if (feeQuery.docs.isEmpty) throw Exception('Student fee record not found.');
      final finRef = feeQuery.docs.first.reference;

      await _db.runTransaction((tx) async {
        final snap = await tx.get(finRef);
        if (!snap.exists) {
          throw Exception('Student financial record not found in database.');
        }

        final total   = (snap['totalAmount'] ?? 0).toDouble();
        final paid    = (snap['paidAmount']  ?? 0).toDouble();
        final newPaid = paid + amount;
        final newOut  = (total - newPaid).clamp(0, double.infinity);

        String newStatus = 'outstanding';
        if (newOut <= 0) {
          newStatus = 'paid';
        } else if (newPaid > 0) {
          newStatus = 'partial';
        }

        tx.update(finRef, {
          'paidAmount':      newPaid,
          'paymentStatus':   newStatus,
          'isBlocked':       newOut <= 0 ? false : (snap.data()?['isBlocked'] ?? false),
          'deadlineOverdue': newOut <= 0 ? false : (snap.data()?['deadlineOverdue'] ?? false),
          'lastPaymentDate': FieldValue.serverTimestamp(),
        });
      });

      // ── Build receipt for success screen ─────────────────
      _lastReceipt = ReceiptModel(
        receiptNo: rcpNo,
        studentName: studentName,
        studentId: studentId,
        semester: semester,
        bank: bank,
        refNo: ref,
        educationFee: bd?.educationFee ?? 0,
        hostelFee: bd?.hostelFee ?? 0,
        othersFee: bd?.otherFee ?? 0,
        generatedAt: DateTime.now(),
      );

      // ── Write payment confirmed notification ──────────────
      await _db.collection('notifications').add({
        'studentID': studentId,
        'title': 'Payment Confirmed',
        'message':
            'Your payment of RM ${amount.toStringAsFixed(2)} '
            'has been successfully received and recorded.',
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'confirmed',
        'isRead': false,
      });

      // ── Reload financial data to show updated balance ─────
      await loadStudentFinancial(studentId);
      _setLoading(false);
      return true; // success
    } catch (e) {
      _errorMessage = 'Payment failed: $e';
      _setLoading(false);
      return false; // failed
    }
  }

  // ── Reset payment flow after done or cancel ───────────────
  void resetPaymentFlow() {
    _selectedMethod = null;
    _selectedFeeType = 'All Fees';
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════
  // TREASURY SECTION
  // Screens: treasury_dashboard, treasury_student_payments,
  //          treasury_student_detail, treasury_fee_records
  // ══════════════════════════════════════════════════════════

  DashboardSummaryModel? _dashboard;
  List<StudentSummaryModel> _allStudents = [];
  List<StudentSummaryModel> _filteredStudents = [];
  StudentSummaryModel? _selectedStudent;
  List<PaymentHistoryModel> _studentPayments = [];
  List<MonthlyFeeRecord> _monthlyRecords = [];
  List<RecentTransactionModel> _recentTx = [];
  String _studentFilter = 'All';

  DashboardSummaryModel? get dashboard => _dashboard;
  List<StudentSummaryModel> get allStudents => _filteredStudents;
  StudentSummaryModel? get selectedStudent => _selectedStudent;
  List<PaymentHistoryModel> get studentPayments => _studentPayments;
  List<MonthlyFeeRecord> get monthlyRecords => _monthlyRecords;
  List<RecentTransactionModel> get recentTransactions => _recentTx;
  String get studentFilter => _studentFilter;

  // Computed counts for dashboard stats
  int get paidCount => _allStudents.where((s) => s.status == 'paid').length;
  int get partialCount =>
      _allStudents.where((s) => s.status == 'partial').length;
  int get outstandingCount =>
      _allStudents.where((s) => s.status == 'outstanding').length;

  // ── Load treasury dashboard ───────────────────────────────
  // Computes totals from studentFees; semester_summary used only for semester name
  Future<void> loadDashboard() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await loadAllStudents();

      // Compute financial totals from actual student data
      final totalRevenue       = _allStudents.fold<double>(0, (s, e) => s + e.paid);
      final pendingCollection  = _allStudents.fold<double>(0, (s, e) => s + e.outstanding);
      final totalFees          = totalRevenue + pendingCollection;
      final collectionRate     = totalFees > 0 ? (totalRevenue / totalFees) * 100 : 0.0;
      final paidStudents       = _allStudents.where((s) => s.status == 'paid').length;
      final pendingStudents    = _allStudents.where((s) => s.status != 'paid').length;

      // Try to get semester label from Firestore; fall back to student data
      String semester = _allStudents.isNotEmpty ? _allStudents.first.semester : '';
      try {
        final doc = await _db.collection('semester_summary').doc('current').get();
        if (doc.exists && doc.data() != null) {
          final s = doc.data()!['semester'] ?? '';
          if ((s as String).isNotEmpty) semester = s;
        }
      } catch (_) {}

      _dashboard = DashboardSummaryModel(
        totalRevenue:      totalRevenue,
        pendingCollection: pendingCollection,
        collectionRate:    collectionRate,
        totalPaid:         paidStudents,
        totalPending:      pendingStudents,
        semester:          semester,
      );
    } catch (e) {
      _errorMessage = 'Failed to load dashboard: $e';
    }
    _setLoading(false);
  }

  // ── Load all students list from studentFees collection ───
  Future<void> loadAllStudents() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final feeSnap = await _db.collection('studentFees').get();
      final List<StudentSummaryModel> list = [];

      for (final doc in feeSnap.docs) {
        final data = doc.data();
        final studentId = data['studentID'] as String? ?? '';

        // Query by studentID field (doc IDs are lowercase, field values may differ)
        String studentName = '';
        try {
          final studentSnap = await _db
              .collection('students')
              .where('studentID', isEqualTo: studentId)
              .limit(1)
              .get();
          if (studentSnap.docs.isNotEmpty) {
            studentName = studentSnap.docs.first.data()['studentName'] as String? ?? '';
          }
        } catch (_) {}

        // If lastPaymentDate is missing but paidAmount > 0, fetch from payments
        // Note: no orderBy here — avoids composite index requirement; sort in Dart
        Map<String, dynamic> enriched = Map.from(data);
        if (enriched['lastPaymentDate'] == null &&
            (enriched['paidAmount'] ?? 0) > 0 &&
            studentId.isNotEmpty) {
          try {
            final paySnap = await _db
                .collection('payments')
                .where('studentID', isEqualTo: studentId)
                .get();
            if (paySnap.docs.isNotEmpty) {
              final sorted = paySnap.docs.toList()
                ..sort((a, b) {
                  final aTs = a.data()['createdAt'];
                  final bTs = b.data()['createdAt'];
                  if (aTs is Timestamp && bTs is Timestamp) {
                    return bTs.compareTo(aTs);
                  }
                  return 0;
                });
              enriched['lastPaymentDate'] = sorted.first.data()['createdAt'];
            }
          } catch (_) {}
        }

        list.add(StudentSummaryModel.fromMap(enriched, doc.id, studentName: studentName));
      }

      _allStudents = list;
      _applyFilter();
    } catch (e) {
      _errorMessage = 'Failed to load students: $e';
    }
    _setLoading(false);
  }

  // ── Filter students by status tab ─────────────────────────
  // Called from: treasury_student_payments filter chips
  void setStudentFilter(String filter) {
    _studentFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_studentFilter == 'All') {
      _filteredStudents = List.from(_allStudents);
    } else {
      _filteredStudents = _allStudents
          .where((s) => s.status.toLowerCase() == _studentFilter.toLowerCase())
          .toList();
    }
  }

  // ── Search students by name or matric ─────────────────────
  // Called from: treasury_student_payments search bar
  void searchStudents(String query) {
    if (query.isEmpty) {
      _applyFilter();
    } else {
      _filteredStudents = _allStudents
          .where(
            (s) =>
                s.name.toLowerCase().contains(query.toLowerCase()) ||
                s.matric.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }

  // ── Load one student's full detail ────────────────────────
  // Reads from: payments (filtered by studentId)
  // Called from: treasury_student_detail_view
  Future<void> loadStudentDetail(String studentId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      // Find the student in already-loaded list
      try {
        _selectedStudent = _allStudents.firstWhere(
          (s) => s.matric == studentId,
        );
      } catch (_) {
        _selectedStudent = null;
      }

      // Load their payment history from payments collection
      final snap = await _db
          .collection('payments')
          .where('studentID', isEqualTo: studentId)
          .get();

      _studentPayments = snap.docs
          .map((d) => PaymentHistoryModel.fromMap(d.data(), d.id))
          .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      _errorMessage = 'Failed to load student detail: $e';
    }
    _setLoading(false);
  }

  // ── Block or unblock a student ────────────────────────────
  // Writes to: students/{studentId}/financial/current
  // Also writes a notification to notifications collection
  Future<void> blockStudent(String studentDocId, bool block) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final feeQuery = await _db
          .collection('studentFees')
          .where('studentID', isEqualTo: studentDocId)
          .limit(1)
          .get();

      if (feeQuery.docs.isEmpty) throw Exception('Student fee record not found.');
      // When unblocking manually, also clear deadlineOverdue so student isn't auto-re-blocked on next login
      await feeQuery.docs.first.reference.update({
        'isBlocked': block,
        if (!block) 'deadlineOverdue': false,
      });

      // Write notification to student
      await _db.collection('notifications').add({
        'studentID': studentDocId,
        'title': block ? 'Account Blocked' : 'Account Unblocked',
        'message': block
            ? 'Your account has been blocked due to outstanding fees. '
                  'Please pay to restore access.'
            : 'Your account has been unblocked. Welcome back!',
        'createdAt': FieldValue.serverTimestamp(),
        'type': block ? 'blocked' : 'unblocked',
        'isRead': false,
      });

      // Reload student list to reflect the change in UI
      await loadAllStudents();
    } catch (e) {
      _errorMessage = 'Failed to update student access: $e';
    }
    _setLoading(false);
  }

  // ── Send payment reminder to student ─────────────────────
  // Writes to: notifications collection in sams-app Firestore
  Future<void> sendReminder(String studentId, String studentName) async {
    _errorMessage = null;
    try {
      await _db.collection('notifications').add({
        'studentID': studentId,
        'title': 'Payment Reminder',
        'message':
            'Dear $studentName, please settle your outstanding '
            'fees to avoid account blocking.',
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'reminder',
        'isRead': false,
      });
    } catch (e) {
      _errorMessage = 'Failed to send reminder: $e';
    }
    notifyListeners();
  }

  // ── Load fee records for Fee Records screen ───────────────
  // Computes summary from studentFees; builds monthly records from payments
  Future<void> loadFeeRecords() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      // Ensure student list is loaded for summary computation
      if (_allStudents.isEmpty) await loadAllStudents();

      // Compute financial totals from student data
      final totalRevenue      = _allStudents.fold<double>(0, (s, e) => s + e.paid);
      final pendingCollection = _allStudents.fold<double>(0, (s, e) => s + e.outstanding);
      final totalFees         = totalRevenue + pendingCollection;
      final collectionRate    = totalFees > 0 ? (totalRevenue / totalFees) * 100 : 0.0;
      final paidStudents      = _allStudents.where((s) => s.status == 'paid').length;
      final pendingStudents   = _allStudents.where((s) => s.status != 'paid').length;
      String semester         = _allStudents.isNotEmpty ? _allStudents.first.semester : '';

      _dashboard = DashboardSummaryModel(
        totalRevenue:      totalRevenue,
        pendingCollection: pendingCollection,
        collectionRate:    collectionRate,
        totalPaid:         paidStudents,
        totalPending:      pendingStudents,
        semester:          semester,
      );

      // Load all payments to build monthly breakdown + recent list
      final allPaySnap = await _db.collection('payments').get();
      final monthNames = ['','January','February','March','April','May','June',
                          'July','August','September','October','November','December'];

      final Map<String, Map<String, dynamic>> byMonth = {};
      for (final doc in allPaySnap.docs) {
        final data = doc.data();
        final raw  = data['createdAt'];
        DateTime? date;
        if (raw is Timestamp) date = raw.toDate();
        if (date == null) continue;

        final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        byMonth[key] ??= {
          'month': monthNames[date.month],
          'year': date.year,
          'collected': 0.0,
          'studentSet': <String>{},
        };
        byMonth[key]!['collected'] =
            (byMonth[key]!['collected'] as double) + (data['totalAmount'] ?? 0).toDouble();
        (byMonth[key]!['studentSet'] as Set<String>).add(data['studentID'] ?? '');
      }

      final sortedEntries = byMonth.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key)); // YYYY-MM sort descending
      _monthlyRecords = sortedEntries.map((e) {
        final v = e.value;
        return MonthlyFeeRecord(
          id:           e.key,
          month:        v['month'] as String,
          year:         v['year'] as int,
          collected:    v['collected'] as double,
          pending:      0,
          studentsPaid: (v['studentSet'] as Set<String>).length,
        );
      }).toList();

      // Recent 5 transactions (sorted newest-first in Dart)
      _recentTx = allPaySnap.docs
          .map((d) => RecentTransactionModel.fromMap(d.data()))
          .where((tx) => tx.date.year > 2000)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      if (_recentTx.length > 5) _recentTx = _recentTx.sublist(0, 5);
    } catch (e) {
      _errorMessage = 'Failed to load fee records: $e';
    }
    _setLoading(false);
  }

  // ── Export reports ────────────────────────────────────────
  bool _isExporting = false;
  bool get isExporting => _isExporting;

  Future<void> exportMonthlyReport() async {
    _isExporting = true;
    notifyListeners();
    try {
      await ReportService().exportMonthlyReport();
    } catch (e) {
      _errorMessage = 'Export failed: $e';
    }
    _isExporting = false;
    notifyListeners();
  }

  Future<void> exportSemesterReport() async {
    _isExporting = true;
    notifyListeners();
    try {
      await ReportService().exportSemesterReport();
    } catch (e) {
      _errorMessage = 'Export failed: $e';
    }
    _isExporting = false;
    notifyListeners();
  }

  // ── Seed missing studentFees for any student without one ─
  // Reads students collection, checks each against studentFees,
  // creates a default outstanding record for any student missing one.
  bool _isSeeding = false;
  bool get isSeeding => _isSeeding;
  int _seededCount = 0;
  int get seededCount => _seededCount;

  Future<void> seedMissingStudentFees() async {
    _isSeeding = true;
    _seededCount = 0;
    notifyListeners();
    try {
      // Get all students
      final studentsSnap = await _db.collection('students').get();

      // Get all existing studentFees (by studentID field)
      final feesSnap = await _db.collection('studentFees').get();
      final existingIds = feesSnap.docs
          .map((d) => (d.data()['studentID'] as String? ?? '').toUpperCase())
          .toSet();

      // Create missing studentFees in batches of 500
      final missing = <Map<String, dynamic>>[];
      for (final doc in studentsSnap.docs) {
        final data  = doc.data();
        final sid   = (data['studentID'] as String? ?? '').toUpperCase();
        if (sid.isEmpty || existingIds.contains(sid)) continue;

        final semester = data['semester'] as String? ?? 'Semester 2, 2025/2026';
        missing.add({
          'studentID':       sid,
          'semester':        semester,
          'educationFee':    1500.0,
          'hostelFee':       800.0,
          'otherFee':        150.0,
          'totalAmount':     2450.0,
          'paidAmount':      0.0,
          'paymentStatus':   'outstanding',
          'isBlocked':       false,
          'deadlineOverdue': false,
          'paymentDeadline': 'Week 5',
          'createdAt':       FieldValue.serverTimestamp(),
        });
      }

      // Write in batches of 500 (Firestore limit)
      for (var i = 0; i < missing.length; i += 500) {
        final chunk = missing.sublist(i, (i + 500).clamp(0, missing.length));
        final batch = _db.batch();
        for (final fee in chunk) {
          batch.set(_db.collection('studentFees').doc(), fee);
        }
        await batch.commit();
      }

      _seededCount = missing.length;

      // Reload to reflect new data
      await loadAllStudents();
    } catch (e) {
      _errorMessage = 'Seed failed: $e';
    }
    _isSeeding = false;
    notifyListeners();
  }

  // ── Clear all state (call on logout) ─────────────────────
  void clearState() {
    _studentFinancial = null;
    _paymentHistory = [];
    _notifications = [];
    _selectedMethod = null;
    _lastReceipt = null;
    _dashboard = null;
    _allStudents = [];
    _filteredStudents = [];
    _selectedStudent = null;
    _studentPayments = [];
    _monthlyRecords = [];
    _recentTx = [];
    _errorMessage = null;
    notifyListeners();
  }
}
