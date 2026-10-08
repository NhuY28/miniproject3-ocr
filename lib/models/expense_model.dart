import 'dart:convert';

class Expense {
  final String id;
  final int userId;
  final String storeName;
  final double amount;
  final DateTime date;
  final String category;
  final String rawOcrText;
  final String? qrCode;
  final String? imagePath;
  final bool isVerified;

  Expense({
    required this.id,
    required this.userId,
    required this.storeName,
    required this.amount,
    required this.date,
    required this.category,
    this.rawOcrText = '',
    this.qrCode,
    this.imagePath,
    this.isVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'store_name': storeName,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'raw_ocr_text': rawOcrText,
      'qr_code': qrCode,
      'image_path': imagePath,
      'is_verified': isVerified ? 1 : 0,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'].toString(),
      userId: map['user_id'],
      storeName: map['store_name'],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      category: map['category'],
      rawOcrText: map['raw_ocr_text'] ?? '',
      qrCode: map['qr_code'],
      imagePath: map['image_path'],
      isVerified: map['is_verified'] == 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory Expense.fromJson(String source) =>
      Expense.fromMap(json.decode(source));
}