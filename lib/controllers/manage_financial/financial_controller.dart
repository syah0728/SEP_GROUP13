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

  // ── Load student financial data from student_fee collection ──
  Future<void> loadStudentFinancial(String studentId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      // Read from student_fee collection, match by studentID field
      final snap = await _db
          .collection('student_fee')
          .where('studentID', isEqualTo: studentId)
          .limit(1)
          .get(const GetOptions(source: Source.server));

      if (snap.docs.isNotEmpty) {
        final data = snap.docs.first.data();

        // Get studentName from students collection (safe — won't crash if missing)
        String studentName = '';
        try {
          final studentDoc = await _db.collection('students').doc(studentId).get();
          studentName = studentDoc.data()?['studentName'] ?? '';
        } catch (_) {}

        _studentFinancial = FinancialModel.fromMap(data, studentName: studentName);
      } else {
        _studentFinancial = null;
        _errorMessage = 'No record found for "$studentId". Check Firestore Rules — student_fee collection may be blocked.';
      }
    } catch (e) {
      _studentFinancial = null;
      _errorMessage = 'Error: $e';
    }
    _setLoading(false);
  }

  // ── Load student payment history from sams-app Firestore ─
  // Reads from: payments (filtered by studentId, newest first)
  Future<void> loadPaymentHistory(String studentId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final snap = await _db
          .collection('payments')
          .where('studentID', isEqualTo: studentId)
          .get();

      _paymentHistory = snap.docs
          .map((d) => PaymentHistoryModel.fromMap(d.data(), d.id))
          .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
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
          .collection('student_fee')
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
  // Reads from: summary/semester
  Future<void> loadDashboard() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      // Read summary document from sams-app Firestore
      final doc = await _db
          .collection('semester_summary')
          .doc('current')
          .get();

      if (doc.exists && doc.data() != null) {
        _dashboard = DashboardSummaryModel.fromMap(doc.data()!);
      }

      // Also load all students for stat counts
      await loadAllStudents();
    } catch (e) {
      _errorMessage = 'Failed to load dashboard: $e';
    }
    _setLoading(false);
  }

  // ── Load all students list from student_fee collection ───
  Future<void> loadAllStudents() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final feeSnap = await _db.collection('student_fee').get();
      final List<StudentSummaryModel> list = [];

      for (final doc in feeSnap.docs) {
        final data = doc.data();
        final studentId = data['studentID'] as String? ?? '';
        final studentDoc = await _db.collection('students').doc(studentId).get();
        final studentName = studentDoc.data()?['studentName'] as String? ?? '';
        list.add(StudentSummaryModel.fromMap(data, doc.id, studentName: studentName));
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
          .collection('student_fee')
          .where('studentID', isEqualTo: studentDocId)
          .limit(1)
          .get();

      if (feeQuery.docs.isEmpty) throw Exception('Student fee record not found.');
      await feeQuery.docs.first.reference.update({'isBlocked': block});

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
  // Reads from:
  //   fee_records (monthly records)
  //   payments    (recent 5 transactions)
  //   summary/semester (overall summary)
  Future<void> loadFeeRecords() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _monthlyRecords = [];

      // Load 5 most recent payments from payments collection
      final txSnap = await _db
          .collection('payments')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      _recentTx = txSnap.docs
          .map((d) => RecentTransactionModel.fromMap(d.data()))
          .toList();

      final summaryDoc = await _db.collection('semester_summary').doc('current').get();

      if (summaryDoc.exists && summaryDoc.data() != null) {
        _dashboard = DashboardSummaryModel.fromMap(summaryDoc.data()!);
      }
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
