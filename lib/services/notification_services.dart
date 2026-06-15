import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/manage_financial/financial_model.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> sendNotification(
    String studentId,
    String title,
    String message,
    String type,
  ) async {
    await _db.collection('notifications').add({
      'studentID': studentId,
      'title':     title,
      'message':   message,
      'type':      type,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead':    false,
    });
  }

  Future<void> sendPaymentReminder(String studentId, String name) async {
    await sendNotification(
      studentId,
      'Payment Reminder',
      'Dear $name, please settle your outstanding fees to avoid account blocking.',
      'reminder',
    );
  }

  Future<void> sendPaymentConfirmed(
      String studentId, double amount) async {
    await sendNotification(
      studentId,
      'Payment Confirmed',
      'Your payment of RM ${amount.toStringAsFixed(2)} has been successfully received and recorded.',
      'confirmed',
    );
  }

  Future<void> sendAccountStatus(String studentId, bool blocked) async {
    if (blocked) {
      await sendNotification(
        studentId,
        'Account Blocked',
        'Your account has been blocked due to outstanding fees. Please pay to restore access.',
        'blocked',
      );
    } else {
      await sendNotification(
        studentId,
        'Account Unblocked',
        'Your account has been unblocked. Welcome back!',
        'unblocked',
      );
    }
  }

  Future<List<NotificationModel>> getNotifications(
      String studentId) async {
    final snap = await _db
        .collection('notifications')
        .where('studentID', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs
        .map((d) => NotificationModel.fromMap(d.data(), d.id))
        .toList();
  }
}
