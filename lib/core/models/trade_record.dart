class TradeRecord {
  final String id;
  final String userId;
  final String productId;
  final String productName;
  final String productIcon;
  final String productType; // 'stock', 'unesco_heritage', 'crypto', etc.
  final String tradeType; // 'buy' or 'sell'
  final double quantity;
  final double price;
  final double totalAmount;
  final double? averagePrice; // 매도 시 평균 구매가
  final double? profit; // 매도 시에만 계산
  final double? profitRate; // 매도 시에만 계산
  final DateTime tradeDate;

  const TradeRecord({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.productIcon,
    required this.productType,
    required this.tradeType,
    required this.quantity,
    required this.price,
    required this.totalAmount,
    this.averagePrice,
    this.profit,
    this.profitRate,
    required this.tradeDate,
  });

  TradeRecord copyWith({
    String? id,
    String? userId,
    String? productId,
    String? productName,
    String? productIcon,
    String? productType,
    String? tradeType,
    double? quantity,
    double? price,
    double? totalAmount,
    double? averagePrice,
    double? profit,
    double? profitRate,
    DateTime? tradeDate,
  }) {
    return TradeRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productIcon: productIcon ?? this.productIcon,
      productType: productType ?? this.productType,
      tradeType: tradeType ?? this.tradeType,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      totalAmount: totalAmount ?? this.totalAmount,
      averagePrice: averagePrice ?? this.averagePrice,
      profit: profit ?? this.profit,
      profitRate: profitRate ?? this.profitRate,
      tradeDate: tradeDate ?? this.tradeDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'productIcon': productIcon,
      'productType': productType,
      'tradeType': tradeType,
      'quantity': quantity,
      'price': price,
      'totalAmount': totalAmount,
      'averagePrice': averagePrice,
      'profit': profit,
      'profitRate': profitRate,
      'tradeDate': tradeDate.toIso8601String(),
    };
  }

  Map<String, dynamic> toSupabaseJson() {
    final json = {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'product_name': productName,
      'product_icon': productIcon,
      'product_type': productType,
      'trade_type': tradeType,
      'quantity': quantity,
      'price': price,
      'total_amount': totalAmount,
      'profit': profit,
      'profit_rate': profitRate,
      'trade_date': tradeDate.toIso8601String(),
    };
    
    // average_price가 null이 아닌 경우만 포함
    if (averagePrice != null) {
      json['average_price'] = averagePrice;
    }
    
    return json;
  }

  factory TradeRecord.fromJson(Map<String, dynamic> json) {
    return TradeRecord(
      id: json['id'] as String,
      userId: json['userId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productIcon: json['productIcon'] as String,
      productType: json['productType'] as String,
      tradeType: json['tradeType'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      averagePrice: json['averagePrice'] != null ? (json['averagePrice'] as num).toDouble() : null,
      profit: json['profit'] != null ? (json['profit'] as num).toDouble() : null,
      profitRate: json['profitRate'] != null ? (json['profitRate'] as num).toDouble() : null,
      tradeDate: DateTime.parse(json['tradeDate'] as String),
    );
  }

  factory TradeRecord.fromSupabaseJson(Map<String, dynamic> json) {
    return TradeRecord(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      productIcon: json['product_icon'] as String,
      productType: json['product_type'] as String,
      tradeType: json['trade_type'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      averagePrice: json['average_price'] != null ? (json['average_price'] as num).toDouble() : null,
      profit: json['profit'] != null ? (json['profit'] as num).toDouble() : null,
      profitRate: json['profit_rate'] != null ? (json['profit_rate'] as num).toDouble() : null,
      tradeDate: DateTime.parse(json['trade_date'] as String),
    );
  }

  @override
  String toString() {
    return 'TradeRecord(productName: $productName, tradeType: $tradeType, quantity: $quantity, price: $price)';
  }
}