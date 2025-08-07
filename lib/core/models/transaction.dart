enum TransactionType {
  buy('BUY'),
  sell('SELL');

  const TransactionType(this.value);
  final String value;

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionType.buy,
    );
  }
}

enum TransactionStatus {
  pending('PENDING'),
  completed('COMPLETED'),
  cancelled('CANCELLED');

  const TransactionStatus(this.value);
  final String value;

  static TransactionStatus fromString(String value) {
    return TransactionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionStatus.completed,
    );
  }
}

class Transaction {
  final String id;
  final String userId;
  final String productId;
  final TransactionType type;
  final double quantity;
  final double price;
  final double totalAmount;
  final double fee;
  final TransactionStatus status;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.userId,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.price,
    required this.totalAmount,
    this.fee = 0.0,
    this.status = TransactionStatus.completed,
    required this.createdAt,
  });

  Transaction copyWith({
    String? id,
    String? userId,
    String? productId,
    TransactionType? type,
    double? quantity,
    double? price,
    double? totalAmount,
    double? fee,
    TransactionStatus? status,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      totalAmount: totalAmount ?? this.totalAmount,
      fee: fee ?? this.fee,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'type': type.value,
      'quantity': quantity,
      'price': price,
      'totalAmount': totalAmount,
      'fee': fee,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      productId: json['productId'] as String,
      type: TransactionType.fromString(json['type'] as String),
      quantity: (json['quantity'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      fee: (json['fee'] as num? ?? 0).toDouble(),
      status: TransactionStatus.fromString(json['status'] as String? ?? 'COMPLETED'),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Transaction(${type.value}: $quantity @ $price = $totalAmount)';
  }
}