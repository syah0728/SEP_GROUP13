// ============================================================
// student_payment_success_page.dart
// Screen  : Payment Successful + Receipt
// Role    : STUDENT
// Path    : screens/manage_financial/student/
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../controllers/manage_financial/financial_controller.dart';
import '../../../models/manage_financial/financial_model.dart';

const kPurple = Color(0xFF7B2FBE);
const kGreen = Color(0xFF00C897);

class StudentPaymentSuccessPage extends StatelessWidget {
  final String studentId;
  const StudentPaymentSuccessPage({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<FinancialController>();
    final receipt = ctrl.lastReceipt;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPurple,
        title: const Text('Financial', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Green check circle
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: kGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),

            const SizedBox(height: 16),

            const Text(
              'Payment successful!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Payment recorded. Access to academic activities restored.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),

            const SizedBox(height: 24),

            if (receipt != null) _ReceiptCard(receipt: receipt),

            const SizedBox(height: 24),

            // Return to Financial
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  ctrl.resetPaymentFlow();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/student/financial',
                    (route) => false,
                  );
                },
                child: const Text(
                  'Return to Financial',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final ReceiptModel receipt;
  const _ReceiptCard({required this.receipt});

  @override
  Widget build(BuildContext context) {
    final genStr = DateFormat(
      'd MMM yyyy, hh:mm a',
    ).format(receipt.generatedAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Generated: $genStr',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const Divider(height: 20),
          _R('Receipt no.', receipt.receiptNo),
          _R('Student', receipt.studentName),
          _R('Student ID', receipt.studentId),
          _R('Semester', receipt.semester),
          _R('Bank', receipt.bank),
          _R('Ref no.', receipt.refNo),
          const Divider(height: 20),
          _R('Education fee', 'RM ${receipt.educationFee.toStringAsFixed(2)}'),
          _R('Hostel fee', 'RM ${receipt.hostelFee.toStringAsFixed(2)}'),
          _R('Others fee', 'RM ${receipt.othersFee.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          // Fully paid badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: kGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kGreen.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check, color: kGreen, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Fully paid — ${receipt.semester}',
                    style: const TextStyle(
                      color: kGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _R extends StatelessWidget {
  final String label;
  final String value;
  const _R(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
