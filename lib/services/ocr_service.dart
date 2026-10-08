import 'dart:async';

import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRResult {
  final String storeName;
  final double amount;
  final DateTime? date;
  final String rawText;
  final bool isLowConfidence;
  final String? qrCode;

  OCRResult({
    required this.storeName,
    required this.amount,
    required this.date,
    required this.rawText,
    required this.isLowConfidence,
    this.qrCode,
  });
}

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  final BarcodeScanner _barcodeScanner = BarcodeScanner();

  /// OCR + QR scanning
  Future<OCRResult> processImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);

    String fullText = '';
    String? qrCode;
    Object? ocrError;
    Object? qrError;

    try {
      final recognizedText = await _textRecognizer.processImage(inputImage);
      fullText = recognizedText.text.trim();
    } on PlatformException catch (error) {
      ocrError = error;
    }

    try {
      final barcodes = await _barcodeScanner.processImage(inputImage);

      for (final barcode in barcodes) {
        if (barcode.format == BarcodeFormat.qrCode ||
            barcode.type == BarcodeType.text ||
            barcode.type == BarcodeType.url) {
          final value = barcode.rawValue ?? barcode.displayValue;

          if (value != null && value.trim().isNotEmpty) {
            qrCode = value.trim();
            break;
          }
        }
      }
    } on PlatformException catch (error) {
      qrError = error;
    }

    if (fullText.isEmpty && qrCode == null) {
      throw StateError(
        'Google ML Kit không nhận diện được nội dung hóa đơn hoặc QR'
        '${ocrError == null ? '' : ' (OCR: $ocrError)'}'
        '${qrError == null ? '' : ' (QR: $qrError)'}',
      );
    }

    return parseReceiptText(
      fullText,
      qrCode: qrCode,
    );
  }

  /// Parse toàn bộ nội dung OCR của hóa đơn.
  ///
  /// Ưu tiên:
  /// 1. TOTAL / TỔNG CỘNG / PHẢI TRẢ...
  /// 2. Các dòng có ngữ cảnh thanh toán
  /// 3. Candidate gần cuối hóa đơn
  /// 4. Không đơn giản chọn số lớn nhất.
  OCRResult parseReceiptText(
    String text, {
    String? qrCode,
  }) {
    final lines = text
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final storeName = _extractStoreName(lines);

    final amountResult = _extractTotalAmount(lines);

    final date = _parseReceiptDate(lines);

    return OCRResult(
      storeName: storeName,
      amount: amountResult.amount,
      date: date,
      rawText: text,
      isLowConfidence: amountResult.isLowConfidence,
      qrCode: qrCode,
    );
  }

  // ---------------------------------------------------------------------------
  // STORE NAME
  // ---------------------------------------------------------------------------

  String _extractStoreName(List<String> lines) {
    if (lines.isEmpty) {
      return 'Unknown Store';
    }

    final ignoredPatterns = <RegExp>[
      RegExp(
        r'^(receipt|invoice|bill|hóa đơn|hoa don)$',
        caseSensitive: false,
      ),
      RegExp(
        r'^(date|ngày|ngay|time|giờ|gio)',
        caseSensitive: false,
      ),
      RegExp(
        r'^(tel|phone|đt|dt|mobile)',
        caseSensitive: false,
      ),
      RegExp(
        r'^\d{5,}$',
      ),
    ];

    for (final line in lines.take(8)) {
      final cleaned = line.trim();

      if (cleaned.length < 2) {
        continue;
      }

      if (ignoredPatterns.any((pattern) => pattern.hasMatch(cleaned))) {
        continue;
      }

      // Không lấy dòng chỉ chứa số.
      if (RegExp(r'^[\d\s.,:/\-]+$').hasMatch(cleaned)) {
        continue;
      }

      return cleaned;
    }

    return 'Unknown Store';
  }

  // ---------------------------------------------------------------------------
  // AMOUNT EXTRACTION
  // ---------------------------------------------------------------------------

  _AmountResult _extractTotalAmount(List<String> lines) {
    if (lines.isEmpty) {
      return const _AmountResult(
        amount: 0,
        isLowConfidence: true,
      );
    }

    final candidates = <_AmountCandidate>[];

    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];

      final amounts = _extractAmounts(line);

      for (final amount in amounts) {
        final score = _calculateAmountScore(
          line: line,
          amount: amount,
          lineIndex: index,
          totalLines: lines.length,
        );

        candidates.add(
          _AmountCandidate(
            amount: amount,
            score: score,
            lineIndex: index,
            line: line,
          ),
        );
      }
    }

    if (candidates.isEmpty) {
      return const _AmountResult(
        amount: 0,
        isLowConfidence: true,
      );
    }

    candidates.sort(
      (a, b) => b.score.compareTo(a.score),
    );

    final best = candidates.first;

    // Score càng thấp thì càng không chắc chắn.
    final lowConfidence = best.score < 60;

    return _AmountResult(
      amount: best.amount,
      isLowConfidence: lowConfidence,
    );
  }

  List<double> _extractAmounts(String line) {
    final amounts = <double>[];

    /*
     * Hỗ trợ:
     *
     * 150000
     * 150.000
     * 1.250.000
     * 150,000
     * 1,250,000
     * 150.50
     * 150,50
     * 1.250,50
     * 1,250.50
     * 150.000đ
     * 150.000 VND
     *
     * Không lấy số có ít hơn 2 chữ số.
     */
    final moneyRegex = RegExp(
      r'(?<!\d)'
      r'(?:\d{1,3}(?:[.,]\d{3})+|\d+)'
      r'(?:[.,]\d{2})?'
      r'(?:\s*(?:đ|₫|vnd|vnđ))?'
      r'(?!\d)',
      caseSensitive: false,
    );

    for (final match in moneyRegex.allMatches(line)) {
      final raw = match.group(0);

      if (raw == null) {
        continue;
      }

      final parsed = _parseAmount(raw);

      if (parsed == null) {
        continue;
      }

      // Chỉ loại số không dương; các hóa đơn nhỏ vẫn có thể có tổng dưới 100.
      if (parsed <= 0) {
        continue;
      }

      // Loại số quá lớn bất thường.
      if (parsed > 1000000000) {
        continue;
      }

      amounts.add(parsed);
    }

    return amounts;
  }

  double _calculateAmountScore({
    required String line,
    required double amount,
    required int lineIndex,
    required int totalLines,
  }) {
    final normalized = _normalizeText(line);

    double score = 0;

    // -------------------------------------------------------------------------
    // 1. TOTAL keywords - ưu tiên cao nhất
    // -------------------------------------------------------------------------

    final strongTotalKeywords = [
      'grand total',
      'total due',
      'amount due',
      'total amount',
      'tổng cộng',
      'tong cong',
      'tổng tiền',
      'tong tien',
      'thành tiền',
      'thanh tien',
      'thanh toán',
      'thanh toan',
      'phải trả',
      'phai tra',
      'cần thanh toán',
      'can thanh toan',
      'net total',
      'final total',
    ];

    for (final keyword in strongTotalKeywords) {
      if (normalized.contains(keyword)) {
        score += 100;
        break;
      }
    }

    // -------------------------------------------------------------------------
    // 2. TOTAL tiếng Anh đơn giản
    // -------------------------------------------------------------------------

    if (RegExp(r'\btotal\b', caseSensitive: false).hasMatch(line)) {
      score += 80;
    }

    // -------------------------------------------------------------------------
    // 3. Currency
    // -------------------------------------------------------------------------

    if (RegExp(
      r'(đ|₫|vnd|vnđ)',
      caseSensitive: false,
    ).hasMatch(line)) {
      score += 15;
    }

    // -------------------------------------------------------------------------
    // 4. Vị trí gần cuối hóa đơn
    // -------------------------------------------------------------------------

    if (totalLines > 1) {
      final positionRatio = lineIndex / (totalLines - 1);

      if (positionRatio >= 0.85) {
        score += 30;
      } else if (positionRatio >= 0.70) {
        score += 20;
      } else if (positionRatio >= 0.50) {
        score += 10;
      }
    }

    // -------------------------------------------------------------------------
    // 5. Các keyword thường xuất hiện trước total
    // -------------------------------------------------------------------------

    final paymentKeywords = [
      'cash',
      'change',
      'balance',
      'payment',
      'paid',
      'subtotal',
      'vat',
      'tax',
      'cash',
      'tiền mặt',
      'tien mat',
      'thuế',
      'thue',
    ];

    for (final keyword in paymentKeywords) {
      if (normalized.contains(keyword)) {
        score += 10;
        break;
      }
    }

    // -------------------------------------------------------------------------
    // 6. Loại số điện thoại
    // -------------------------------------------------------------------------

    if (_looksLikePhoneNumber(line)) {
      score -= 100;
    }

    // -------------------------------------------------------------------------
    // 7. Loại mã hóa đơn / invoice number
    // -------------------------------------------------------------------------

    if (RegExp(
      r'(invoice\s*(no|number)?|bill\s*(no|number)?|mã\s*hóa\s*đơn|ma hoa don)',
      caseSensitive: false,
    ).hasMatch(line)) {
      score -= 80;
    }

    // -------------------------------------------------------------------------
    // 8. Loại ngày tháng
    // -------------------------------------------------------------------------

    if (_containsDate(line)) {
      score -= 50;
    }

    // -------------------------------------------------------------------------
    // 9. Quantity
    // -------------------------------------------------------------------------

    if (RegExp(
      r'\b(qty|quantity|sl|số lượng|so luong)\b',
      caseSensitive: false,
    ).hasMatch(line)) {
      score -= 50;
    }

    // -------------------------------------------------------------------------
    // 10. Số tiền càng hợp lý thì cộng điểm
    // -------------------------------------------------------------------------

    if (amount >= 1000 && amount <= 10000000) {
      score += 10;
    }

    return score;
  }

  // ---------------------------------------------------------------------------
  // DATE
  // ---------------------------------------------------------------------------

  DateTime? _parseReceiptDate(List<String> lines) {
    final dateLabel = RegExp(
      r'(date|ngày|ngay|issued|invoice date|date issued)',
      caseSensitive: false,
    );

    final orderedLines = [
      ...lines.where(dateLabel.hasMatch),
      ...lines.where(
        (line) => !dateLabel.hasMatch(line),
      ),
    ];

    for (final line in orderedLines) {
      // YYYY-MM-DD
      // YYYY/MM/DD
      // YYYY.MM.DD
      final isoMatch = RegExp(
        r'\b(20\d{2})[-/.](\d{1,2})[-/.](\d{1,2})\b',
      ).firstMatch(line);

      if (isoMatch != null) {
        final parsed = _validDate(
          int.parse(isoMatch.group(1)!),
          int.parse(isoMatch.group(2)!),
          int.parse(isoMatch.group(3)!),
        );

        if (parsed != null) {
          return parsed;
        }
      }

      // DD-MM-YYYY
      // DD/MM/YYYY
      // DD.MM.YYYY
      final dayFirstMatch = RegExp(
        r'\b(\d{1,2})[-/.](\d{1,2})[-/.](20\d{2})\b',
      ).firstMatch(line);

      if (dayFirstMatch != null) {
        final parsed = _validDate(
          int.parse(dayFirstMatch.group(3)!),
          int.parse(dayFirstMatch.group(2)!),
          int.parse(dayFirstMatch.group(1)!),
        );

        if (parsed != null) {
          return parsed;
        }
      }

      // DD Month YYYY
      final monthNameMatch = RegExp(
        r'\b'
        r'(\d{1,2})\s+'
        r'(Jan(?:uary)?|'
        r'Feb(?:ruary)?|'
        r'Mar(?:ch)?|'
        r'Apr(?:il)?|'
        r'May|'
        r'Jun(?:e)?|'
        r'Jul(?:y)?|'
        r'Aug(?:ust)?|'
        r'Sep(?:t(?:ember)?)?|'
        r'Oct(?:ober)?|'
        r'Nov(?:ember)?|'
        r'Dec(?:ember)?)'
        r'\s+(20\d{2})\b',
        caseSensitive: false,
      ).firstMatch(line);

      if (monthNameMatch != null) {
        final month = _monthNumber(
          monthNameMatch.group(2)!,
        );

        final parsed = _validDate(
          int.parse(monthNameMatch.group(3)!),
          month,
          int.parse(monthNameMatch.group(1)!),
        );

        if (parsed != null) {
          return parsed;
        }
      }

      // Month DD, YYYY
      final monthFirstMatch = RegExp(
        r'\b'
        r'(Jan(?:uary)?|'
        r'Feb(?:ruary)?|'
        r'Mar(?:ch)?|'
        r'Apr(?:il)?|'
        r'May|'
        r'Jun(?:e)?|'
        r'Jul(?:y)?|'
        r'Aug(?:ust)?|'
        r'Sep(?:t(?:ember)?)?|'
        r'Oct(?:ober)?|'
        r'Nov(?:ember)?|'
        r'Dec(?:ember)?)'
        r'\s+(\d{1,2}),?\s+(20\d{2})\b',
        caseSensitive: false,
      ).firstMatch(line);

      if (monthFirstMatch != null) {
        final month = _monthNumber(
          monthFirstMatch.group(1)!,
        );

        final parsed = _validDate(
          int.parse(monthFirstMatch.group(3)!),
          month,
          int.parse(monthFirstMatch.group(2)!),
        );

        if (parsed != null) {
          return parsed;
        }
      }
    }

    return null;
  }

  DateTime? _validDate(
    int year,
    int month,
    int day,
  ) {
    try {
      if (month < 1 || month > 12) {
        return null;
      }

      if (day < 1 || day > 31) {
        return null;
      }

      final date = DateTime(
        year,
        month,
        day,
      );

      if (date.year == year && date.month == month && date.day == day) {
        return date;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  int _monthNumber(String value) {
    final month = value.toLowerCase().substring(0, 3);

    const months = <String, int>{
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };

    return months[month] ?? 1;
  }

  // ---------------------------------------------------------------------------
  // AMOUNT PARSER
  // ---------------------------------------------------------------------------

  double? _parseAmount(String value) {
    var normalized = value.replaceAll(RegExp(r'[^0-9,.]'), '');

    if (normalized.isEmpty) {
      return null;
    }

    // Có cả "." và ","
    //
    // 1.250,50 -> 1250.50
    // 1,250.50 -> 1250.50
    if (normalized.contains(',') && normalized.contains('.')) {
      final lastComma = normalized.lastIndexOf(',');
      final lastDot = normalized.lastIndexOf('.');

      if (lastComma > lastDot) {
        // Vietnamese:
        // 1.250,50
        normalized = normalized.replaceAll('.', '').replaceFirst(',', '.');
      } else {
        // English:
        // 1,250.50
        normalized = normalized.replaceAll(',', '');
      }

      return double.tryParse(normalized);
    }

    // Chỉ có ","
    if (normalized.contains(',')) {
      final parts = normalized.split(',');
      final lastPart = parts.last;

      if (lastPart.length == 3) {
        // 150,000
        // 1,250,000
        normalized = normalized.replaceAll(',', '');
      } else if (lastPart.length == 2) {
        // 150,50
        normalized = normalized.replaceFirst(',', '.');
      } else {
        normalized = normalized.replaceAll(',', '');
      }

      return double.tryParse(normalized);
    }

    // Chỉ có "."
    if (normalized.contains('.')) {
      final parts = normalized.split('.');
      final lastPart = parts.last;

      if (lastPart.length == 3) {
        // 150.000
        // 1.250.000
        normalized = normalized.replaceAll('.', '');
      }

      return double.tryParse(normalized);
    }

    return double.tryParse(normalized);
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  String _normalizeText(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  bool _looksLikePhoneNumber(String line) {
    final digits = line.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 9 || digits.length > 12) {
      return false;
    }

    return RegExp(
      r'(0|\+84)',
    ).hasMatch(
      line.replaceAll(' ', ''),
    );
  }

  bool _containsDate(String line) {
    return RegExp(
      r'\b(?:20\d{2}[-/.]\d{1,2}[-/.]\d{1,2}|\d{1,2}[-/.]\d{1,2}[-/.]20\d{2})\b',
    ).hasMatch(line);
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------

  void dispose() {
    unawaited(_closeNativeResources());
  }

  Future<void> _closeNativeResources() async {
    try {
      await _textRecognizer.close();
    } on MissingPluginException {
      // Native ML Kit channels are unavailable in Dart unit tests.
    }

    try {
      await _barcodeScanner.close();
    } on MissingPluginException {
      // Native ML Kit channels are unavailable in Dart unit tests.
    }
  }
}

// -----------------------------------------------------------------------------
// INTERNAL RESULT CLASSES
// -----------------------------------------------------------------------------

class _AmountCandidate {
  final double amount;
  final double score;
  final int lineIndex;
  final String line;

  const _AmountCandidate({
    required this.amount,
    required this.score,
    required this.lineIndex,
    required this.line,
  });
}

class _AmountResult {
  final double amount;
  final bool isLowConfidence;

  const _AmountResult({
    required this.amount,
    required this.isLowConfidence,
  });
}
