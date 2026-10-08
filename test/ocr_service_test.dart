import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/services/ocr_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('extracts merchant, total amount, and receipt date', () {
    final service = OCRService();
    final result = service.parseReceiptText('''
VINMART
Item A 120.00
Item B 45.00
Date: 30 Sep 2026
TOTAL: 70.00
''');

    expect(result.storeName, 'VINMART');
    expect(result.amount, 70.0);
    expect(result.date, DateTime(2026, 9, 30));
    service.dispose();
  });

  test('uses the receipt total instead of the largest item price', () {
    final service = OCRService();
    final result = service.parseReceiptText('''
SHOP
Item A 120.00
Item B 45.00
SUBTOTAL 165.00
TOTAL: 70.00
''');

    expect(result.amount, 70.0);
    service.dispose();
  });

  test('parses Vietnamese decimal amounts on the total line', () {
    final service = OCRService();
    final result = service.parseReceiptText('''
CUA HANG
San pham 120,00
TONG CONG: 70,50
''');

    expect(result.amount, 70.5);
    service.dispose();
  });
}
