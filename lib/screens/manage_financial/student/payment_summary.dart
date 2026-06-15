// ============================================================
// student_payment_summary_page.dart
// Screen  : Payment Summary (confirm before paying)
// Role    : STUDENT
// Path    : screens/manage_financial/student/
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/manage_financial/financial_controller.dart';
import 'payment_success.dart';

const kPurple = Color(0xFF7B2FBE);
const kGreen = Color(0xFF00C897);

class StudentPaymentSummaryPage extends StatelessWidget {
  final String studentId;
  final String studentName;
  final String semester;
  final double totalAmount;
  final String bank;

  const StudentPaymentSummaryPage({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.semester,
    required this.totalAmount,
    required this.bank,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<FinancialController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPurple,
        title: const Text('Financial', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Summary table
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _Row(label: 'Student', value: studentName),
                  _Row(label: 'Student ID', value: studentId),
                  _Row(label: 'Semester', value: semester),
                  _Row(label: 'Bank', value: bank),
                  _Row(
                    label: 'Total amount',
                    value: 'RM ${totalAmount.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),

            const Spacer(),

            if (ctrl.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  ctrl.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // Confirm and Pay button
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
                onPressed: ctrl.isLoading
                    ? null
                    : () async {
                        final success = await ctrl.processPayment(
                          studentId: studentId,
                          studentName: studentName,
                          semester: semester,
                          amount: totalAmount,
                          bank: bank,
                        );
                        if (success && context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudentPaymentSuccessPage(
                                studentId: studentId,
                              ),
                            ),
                            (route) => route.isFirst,
                          );
                        }
                      },
                child: ctrl.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Confirm and Pay',
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

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  const _Row({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
