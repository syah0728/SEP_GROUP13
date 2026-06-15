// ============================================================
// student_make_payment_page.dart
// Screen  : Make Payment
// Role    : STUDENT
// Path    : screens/manage_financial/student/
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/manage_financial/financial_controller.dart';
import '../../../models/manage_financial/financial_model.dart';
import 'payment_summary.dart';

const kPurple = Color(0xFF7B2FBE);
const kGreen = Color(0xFF00C897);

class StudentMakePaymentPage extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String semester;
  final double totalAmount;

  const StudentMakePaymentPage({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.semester,
    required this.totalAmount,
  });

  @override
  State<StudentMakePaymentPage> createState() => _StudentMakePaymentPageState();
}

class _StudentMakePaymentPageState extends State<StudentMakePaymentPage> {
  late final TextEditingController _amountCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.totalAmount.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  double get _enteredAmount => double.tryParse(_amountCtrl.text) ?? 0;

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<FinancialController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPurple,
        title: const Text('Financial', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [
          Icon(Icons.notifications_outlined, color: Colors.white),
          SizedBox(width: 8),
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.person_outline, color: Colors.white),
          ),
        ],
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Fee Type dropdown
            const Text(
              'Fee Type',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: ctrl.selectedFeeType,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'All Fees', child: Text('All Fees')),
                DropdownMenuItem(
                  value: 'Education Fee',
                  child: Text('Education Fee'),
                ),
                DropdownMenuItem(
                  value: 'Hostel Fee',
                  child: Text('Hostel Fee'),
                ),
                DropdownMenuItem(value: 'Other Fee', child: Text('Other Fee')),
              ],
              onChanged: (val) {
                if (val != null) ctrl.selectFeeType(val);
              },
            ),
            const SizedBox(height: 16),

            // Payment Total (editable)
            const Text(
              'Payment Total (RM)',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixText: 'RM ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              validator: (val) {
                final amount = double.tryParse(val ?? '');
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                if (amount > widget.totalAmount) {
                  return 'Amount cannot exceed RM ${widget.totalAmount.toStringAsFixed(2)}';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Student Name (read-only)
            const Text(
              'Student Name',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            _ReadOnlyField(widget.studentName),
            const SizedBox(height: 16),

            // Student ID (read-only)
            const Text(
              'Student ID',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            _ReadOnlyField(widget.studentId),
            const SizedBox(height: 16),

            // Semester (read-only)
            const Text(
              'Semester',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            _ReadOnlyField(widget.semester),
            const SizedBox(height: 24),

            // Payment Methods
            const Text(
              'Select Payment Methods',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _MethodCard(
              icon: Icons.account_balance,
              color: Colors.blue,
              method: PaymentMethod.onlineBanking,
              isSelected: ctrl.selectedMethod == PaymentMethod.onlineBanking,
              onTap: () =>
                  ctrl.selectPaymentMethod(PaymentMethod.onlineBanking),
            ),
            const SizedBox(height: 10),

            _MethodCard(
              icon: Icons.credit_card,
              color: Colors.purple,
              method: PaymentMethod.creditDebitCard,
              isSelected: ctrl.selectedMethod == PaymentMethod.creditDebitCard,
              onTap: () =>
                  ctrl.selectPaymentMethod(PaymentMethod.creditDebitCard),
            ),
            const SizedBox(height: 32),

            // Continue button
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
                onPressed: ctrl.selectedMethod == null
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudentPaymentSummaryPage(
                                studentId: widget.studentId,
                                studentName: widget.studentName,
                                semester: widget.semester,
                                totalAmount: _enteredAmount,
                                bank: ctrl.selectedMethod ==
                                        PaymentMethod.onlineBanking
                                    ? 'Maybank2u (FPX)'
                                    : 'Credit/Debit Card',
                              ),
                            ),
                          );
                        }
                      },
                child: const Text(
                  'Continue to verify',
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
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String value;
  const _ReadOnlyField(this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodCard({
    required this.icon,
    required this.color,
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.07) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method.subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? color : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
