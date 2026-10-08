import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';

class ReceiptResultScreen extends StatefulWidget {
  final String mockStore;
  final double mockAmount;
  final String mockText;
  final String? qrCode;
  final String? imagePath;
  final DateTime? date;

  const ReceiptResultScreen({
    super.key,
    required this.mockStore,
    required this.mockAmount,
    required this.mockText,
    this.qrCode,
    this.imagePath,
    this.date,
  });

  @override
  State<ReceiptResultScreen> createState() => _ReceiptResultScreenState();
}

class _ReceiptResultScreenState extends State<ReceiptResultScreen> {
  late TextEditingController _storeController;
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  String _selectedCategory = 'Shopping';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _storeController = TextEditingController(text: widget.mockStore);
    _amountController =
        TextEditingController(text: widget.mockAmount.toString());
    _dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(widget.date ?? DateTime.now()),
    );
  }

  @override
  void dispose() {
    _storeController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _confirmAndSave() async {
    final storeName = _storeController.text.trim();
    final amount =
        double.tryParse(_amountController.text.trim().replaceAll(',', '.'));
    final date = DateTime.tryParse(_dateController.text.trim());

    if (storeName.isEmpty || amount == null || amount <= 0 || date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please verify merchant, total amount and date.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 1,
      storeName: storeName,
      amount: amount,
      date: date,
      category: _selectedCategory,
      rawOcrText: widget.mockText,
      qrCode: widget.qrCode,
      imagePath: widget.imagePath,
    );

    try {
      await Provider.of<ExpenseProvider>(context, listen: false)
          .addExpense(expense);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense confirmed and saved')),
      );
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Review & Verify', style: AppTextStyles.heading2),
            const SizedBox(height: AppDimens.xs),
            const Text(
              'Check the extracted information before saving.',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: AppDimens.xl),
            TextField(
              controller: _storeController,
              decoration: const InputDecoration(
                  labelText: 'Store Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: AppDimens.md),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Total Amount (VND)',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: AppDimens.md),
            TextField(
              controller: _dateController,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                labelText: 'Receipt Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppDimens.md),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                  labelText: 'Category', border: OutlineInputBorder()),
              items: ['Shopping', 'Food', 'Transport', 'Bills']
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: AppDimens.xl),

            // OCR Raw Text Display
            const Text('Recognized OCR Text:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDimens.xs),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimens.md),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: Text(widget.mockText,
                  style:
                      const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            ),
            if (widget.qrCode != null) ...[
              const SizedBox(height: AppDimens.lg),
              const Text('QR Code:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppDimens.xs),
              SelectableText(widget.qrCode!),
            ],
            const SizedBox(height: AppDimens.xxl),

            // Save CTA
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary),
                onPressed: _isSaving ? null : _confirmAndSave,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Confirm & Save',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
