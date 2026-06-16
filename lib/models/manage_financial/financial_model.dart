import 'package:cloud_firestore/cloud_firestore.dart';

DateTime _parseDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}

DateTime? _parseDateNullable(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value);
  return null;
}

class FeeBreakdown {
  final double educationFee;
  final double hostelFee;
  final double otherFee;

  FeeBreakdown({
    required this.educationFee,
    required this.hostelFee,
    required this.otherFee,
  });

  double get total => educationFee + hostelFee + otherFee;

  factory FeeBreakdown.fromMap(Map<String, dynamic> map) {
    return FeeBreakdown(
      educationFee: (map['educationFee'] ?? 0).toDouble(),
      hostelFee:    (map['hostelFee']    ?? 0).toDouble(),
      otherFee:     (map['otherFee']     ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
    'educationFee': educationFee,
    'hostelFee':    hostelFee,
    'otherFee':     otherFee,
  };
}

// Firestore: students/{studentId}/financial/current
class FinancialModel {
  final String studentId;
  final String studentName;
  final String semester;
  final double totalOutstanding;
  final double totalPaid;
  final double totalFees;
  final FeeBreakdown feeBreakdown;
  final bool isBlocked;
  final String paymentDeadline;
  final bool deadlineOverdue;
  final String status;
  final String paymentID;

  FinancialModel({
    required this.studentId,
    required this.studentName,
    required this.semester,
    required this.totalOutstanding,
    required this.totalPaid,
    required this.totalFees,
    required this.feeBreakdown,
    required this.isBlocked,
    required this.paymentDeadline,
    required this.deadlineOverdue,
    required this.status,
    this.paymentID = '',
  });

  factory FinancialModel.fromMap(Map<String, dynamic> map, {String studentName = ''}) {
    final total = (map['totalAmount'] ?? 0).toDouble();
    final paid  = (map['paidAmount']  ?? 0).toDouble();
    return FinancialModel(
      studentId:        map['studentID']       ?? '',
      studentName:      studentName,
      semester:         map['semester']        ?? '',
      totalFees:        total,
      totalPaid:        paid,
      totalOutstanding: (total - paid).clamp(0, double.infinity),
      feeBreakdown: FeeBreakdown(
        educationFee: (map['educationFee'] ?? 0).toDouble(),
        hostelFee:    (map['hostelFee']    ?? 0).toDouble(),
        otherFee:     (map['otherFee']     ?? 0).toDouble(),
      ),
      isBlocked:       map['isBlocked']       ?? false,
      paymentDeadline: map['paymentDeadine']  ?? map['paymentDeadline'] ?? 'Week 5',
      deadlineOverdue: map['deadlineOverdue'] ?? false,
      status:          (map['paymentStatus']  ?? 'outstanding').toString().toLowerCase(),
      paymentID:       map['paymentID']       ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'studentID':       studentId,
    'semester':        semester,
    'totalAmount':     totalFees,
    'paidAmount':      totalPaid,
    'paymentStatus':   status,
    'isBlocked':       isBlocked,
    'paymentDeadline': paymentDeadline,
    'deadlineOverdue': deadlineOverdue,
    'educationFee':    feeBreakdown.educationFee,
    'hostelFee':       feeBreakdown.hostelFee,
    'otherFee':        feeBreakdown.otherFee,
  };
}

// Firestore: payments/{autoId}
class PaymentHistoryModel {
  final String id;
  final String studentId;
  final String studentName;
  final String semester;
  final double amount;
  final String method;
  final String reference;
  final DateTime date;

  PaymentHistoryModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.semester,
    required this.amount,
    required this.method,
    required this.reference,
    required this.date,
  });

  factory PaymentHistoryModel.fromMap(Map<String, dynamic> map, String docId) {
    return PaymentHistoryModel(
      id:          docId,
      studentId:   map['studentID']    ?? '',
      studentName: map['studentName']  ?? '',
      semester:    map['semester']     ?? '',
      amount:      (map['totalAmount'] ?? 0).toDouble(),
      method:      map['paymentMethod'] ?? '',
      reference:   map['receiptNo']    ?? '',
      date: _parseDate(map['createdAt']),
    );
  }
}

enum PaymentMethod { onlineBanking, creditDebitCard }

extension PaymentMethodLabel on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.onlineBanking:
        return 'Online Banking (FPX)';
      case PaymentMethod.creditDebitCard:
        return 'Credit/Debit Card';
    }
  }

  String get subtitle {
    switch (this) {
      case PaymentMethod.onlineBanking:
        return 'Instant payment via bank';
      case PaymentMethod.creditDebitCard:
        return 'Visa, Mastercard accepted';
    }
  }
}

class ReceiptModel {
  final String receiptNo;
  final String studentName;
  final String studentId;
  final String semester;
  final String bank;
  final String refNo;
  final double educationFee;
  final double hostelFee;
  final double othersFee;
  final DateTime generatedAt;

  ReceiptModel({
    required this.receiptNo,
    required this.studentName,
    required this.studentId,
    required this.semester,
    required this.bank,
    required this.refNo,
    required this.educationFee,
    required this.hostelFee,
    required this.othersFee,
    required this.generatedAt,
  });

  double get totalAmount => educationFee + hostelFee + othersFee;
}

// Firestore: notifications/{autoId}
class NotificationModel {
  final String id;
  final String studentId;
  final String title;
  final String message;
  final DateTime date;
  final String type;

  NotificationModel({
    required this.id,
    required this.studentId,
    required this.title,
    required this.message,
    required this.date,
    required this.type,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    return NotificationModel(
      id:        docId,
      studentId: map['studentID'] ?? '',
      title:     map['title']     ?? '',
      message:   map['message']   ?? '',
      type:      map['type']      ?? 'reminder',
      date: _parseDate(map['createdAt']),
    );
  }
}

// Firestore: students/{studentId}/financial/current  (treasury view)
class StudentSummaryModel {
  final String id;
  final String name;
  final String matric;
  final String semester;
  final double totalFees;
  final double paid;
  final double outstanding;
  final String status;
  final bool isBlocked;
  final bool isWeek5;
  final DateTime? lastPayment;
  final DateTime? paymentDueDate;
  final FeeBreakdown feeBreakdown;

  StudentSummaryModel({
    required this.id,
    required this.name,
    required this.matric,
    required this.semester,
    required this.totalFees,
    required this.paid,
    required this.outstanding,
    required this.status,
    required this.isBlocked,
    required this.feeBreakdown,
    this.isWeek5 = false,
    this.lastPayment,
    this.paymentDueDate,
  });

  factory StudentSummaryModel.fromMap(Map<String, dynamic> map, String docId, {String studentName = ''}) {
    final total       = (map['totalAmount'] ?? 0).toDouble();
    final paid        = (map['paidAmount']  ?? 0).toDouble();
    final outstanding = (total - paid).clamp(0.0, double.infinity);
    final stored      = (map['paymentStatus'] ?? '').toString().toLowerCase();
    final status = (stored == 'paid' || stored == 'partial' || stored == 'outstanding')
        ? stored
        : outstanding <= 0
            ? 'paid'
            : paid > 0
                ? 'partial'
                : 'outstanding';
    final storedBlock     = (map['isBlocked']       ?? false) as bool;
    final deadlineOverdue = (map['deadlineOverdue'] ?? false) as bool;
    final effectiveBlock = storedBlock || (deadlineOverdue && outstanding > 0);

    return StudentSummaryModel(
      id:          docId,
      name:        studentName,
      matric:      map['studentID']     ?? '',
      semester:    map['semester']      ?? '',
      totalFees:   total,
      paid:        paid,
      outstanding: outstanding,
      status:      status,
      isBlocked:   effectiveBlock,
      isWeek5:     deadlineOverdue,
      lastPayment: _parseDateNullable(map['lastPaymentDate']),
      feeBreakdown: FeeBreakdown(
        educationFee: (map['educationFee'] ?? 0).toDouble(),
        hostelFee:    (map['hostelFee']    ?? 0).toDouble(),
        otherFee:     (map['otherFee']     ?? 0).toDouble(),
      ),
    );
  }
}

// Firestore: semester_summary/current  (treasury dashboard)
class DashboardSummaryModel {
  final double totalRevenue;
  final double pendingCollection;
  final double collectionRate;
  final int totalPaid;
  final int totalPending;
  final String semester;

  DashboardSummaryModel({
    required this.totalRevenue,
    required this.pendingCollection,
    required this.collectionRate,
    required this.totalPaid,
    required this.totalPending,
    required this.semester,
  });

  factory DashboardSummaryModel.fromMap(Map<String, dynamic> map) {
    return DashboardSummaryModel(
      totalRevenue:      (map['totalRevenue']      ?? 0).toDouble(),
      pendingCollection: (map['pendingCollection'] ?? 0).toDouble(),
      collectionRate:    (map['collectionRate']    ?? 0).toDouble(),
      totalPaid:         map['totalPaid']          ?? 0,
      totalPending:      map['totalPending']       ?? 0,
      semester:          map['semester']           ?? '',
    );
  }
}

// Firestore: payments/{autoId}  (treasury fee records)
class RecentTransactionModel {
  final String studentName;
  final String studentId;
  final double amount;
  final String method;
  final String reference;
  final DateTime date;

  RecentTransactionModel({
    required this.studentName,
    required this.studentId,
    required this.amount,
    required this.method,
    required this.reference,
    required this.date,
  });

  factory RecentTransactionModel.fromMap(Map<String, dynamic> map) {
    return RecentTransactionModel(
      studentName: map['studentName']   ?? '',
      studentId:   map['studentID']     ?? '',
      amount:      (map['totalAmount']  ?? 0).toDouble(),
      method:      map['paymentMethod'] ?? '',
      reference:   map['receiptNo']     ?? '',
      date: _parseDate(map['createdAt']),
    );
  }
}

// Firestore: fee_records/{autoId}  (treasury monthly records)
class MonthlyFeeRecord {
  final String id;
  final String month;
  final int year;
  final double collected;
  final double pending;
  final int studentsPaid;

  MonthlyFeeRecord({
    required this.id,
    required this.month,
    required this.year,
    required this.collected,
    required this.pending,
    required this.studentsPaid,
  });

  factory MonthlyFeeRecord.fromMap(Map<String, dynamic> map, String docId) {
    return MonthlyFeeRecord(
      id:           docId,
      month:        map['month']        ?? '',
      year:         map['year']         ?? 0,
      collected:    (map['collected']   ?? 0).toDouble(),
      pending:      (map['pending']     ?? 0).toDouble(),
      studentsPaid: map['studentsPaid'] ?? 0,
    );
  }
}
