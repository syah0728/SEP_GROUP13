import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/manage_financial/financial_model.dart';

class PaymentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> savePayment(Map<String, dynamic> paymentData) async {
    await _db.collection('payments').add(paymentData);
  }

  String generateReceiptNo() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '#RCP-${DateTime.now().year}-${timestamp % 100000}';
  }

  String generateReference() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'MBB$timestamp';
  }

  Future<List<PaymentHistoryModel>> getPaymentHistory(String studentId) async {
    final snap = await _db
        .collection('payments')
        .where('studentID', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs
        .map((d) => PaymentHistoryModel.fromMap(d.data(), d.id))
        .toList();
  }

  Future<List<RecentTransactionModel>> getRecentTransactions(int limit) async {
    final snap = await _db
        .collection('payments')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snap.docs
        .map((d) => RecentTransactionModel.fromMap(d.data()))
        .toList();
  }
}
