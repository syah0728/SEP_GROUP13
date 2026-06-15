import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/manage_financial/financial_model.dart';

class FinancialService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<FinancialModel> getStudentFinancial(String studentId) async {
    final doc = await _db
        .collection('students')
        .doc(studentId)
        .collection('financial')
        .doc('current')
        .get();

    if (doc.exists && doc.data() != null) {
      final studentDoc =
          await _db.collection('students').doc(studentId).get();
      final studentName =
          (studentDoc.data()?['studentName'] as String?) ?? '';
      return FinancialModel.fromMap(doc.data()!, studentName: studentName);
    }
    throw Exception('Student financial record not found');
  }

  Future<void> updateBalance(String studentId, double amount) async {
    final finRef = _db
        .collection('students')
        .doc(studentId)
        .collection('financial')
        .doc('current');

    await _db.runTransaction((tx) async {
      final snap = await tx.get(finRef);
      if (snap.exists) {
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
          'paidAmount':    newPaid,
          'paymentStatus': newStatus,
          'isBlocked':     newOut <= 0 ? false : (snap.data()?['isBlocked'] ?? false),
        });
      }
    });
  }

  Future<List<StudentSummaryModel>> getAllStudents() async {
    final studentsSnap = await _db.collection('students').get();
    final List<StudentSummaryModel> list = [];

    for (final doc in studentsSnap.docs) {
      final finDoc = await _db
          .collection('students')
          .doc(doc.id)
          .collection('financial')
          .doc('current')
          .get();

      if (finDoc.exists && finDoc.data() != null) {
        final studentName =
            (doc.data()['studentName'] as String?) ?? '';
        list.add(StudentSummaryModel.fromMap(
          finDoc.data()!,
          doc.id,
          studentName: studentName,
        ));
      }
    }
    return list;
  }

  Future<void> setBlockStatus(String studentId, bool block) async {
    await _db
        .collection('students')
        .doc(studentId)
        .collection('financial')
        .doc('current')
        .update({'isBlocked': block});
  }
}
