class Portfolio {
  final String id;
  final String userId;
  final String productId;
  final double quantity;
  final double averagePrice;
  final double totalInvestment;
  final double currentValue;
  final double profitLoss;
  final double profitRate;
  final DateTime? firstPurchaseAt;
  final DateTime? lastPurchaseAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Portfolio({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.averagePrice,
    required this.totalInvestment,
    required this.currentValue,
    required this.profitLoss,
    required this.profitRate,
    this.firstPurchaseAt,
    this.lastPurchaseAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Portfolio copyWith({
    String? id,
    String? userId,
    String? productId,
    double? quantity,
    double? averagePrice,
    double? totalInvestment,
    double? currentValue,
    double? profitLoss,
    double? profitRate,
    DateTime? firstPurchaseAt,
    DateTime? lastPurchaseAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Portfolio(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      averagePrice: averagePrice ?? this.averagePrice,
      totalInvestment: totalInvestment ?? this.totalInvestment,
      currentValue: currentValue ?? this.currentValue,
      profitLoss: profitLoss ?? this.profitLoss,
      profitRate: profitRate ?? this.profitRate,
      firstPurchaseAt: firstPurchaseAt ?? this.firstPurchaseAt,
      lastPurchaseAt: lastPurchaseAt ?? this.lastPurchaseAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'quantity': quantity,
      'averagePrice': averagePrice,
      'totalInvestment': totalInvestment,
      'currentValue': currentValue,
      'profitLoss': profitLoss,
      'profitRate': profitRate,
      'firstPurchaseAt': firstPurchaseAt?.toIso8601String(),
      'lastPurchaseAt': lastPurchaseAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'average_price': averagePrice,
      'total_investment': totalInvestment,
      'current_value': currentValue,
      'profit_loss': profitLoss,
      'profit_rate': profitRate,
      'first_purchase_at': firstPurchaseAt?.toIso8601String(),
      'last_purchase_at': lastPurchaseAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json['id'] as String,
      userId: json['userId'] as String,
      productId: json['productId'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      averagePrice: (json['averagePrice'] as num).toDouble(),
      totalInvestment: (json['totalInvestment'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      profitLoss: (json['profitLoss'] as num).toDouble(),
      profitRate: (json['profitRate'] as num).toDouble(),
      firstPurchaseAt: json['firstPurchaseAt'] != null 
          ? DateTime.parse(json['firstPurchaseAt'] as String) 
          : null,
      lastPurchaseAt: json['lastPurchaseAt'] != null 
          ? DateTime.parse(json['lastPurchaseAt'] as String) 
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  factory Portfolio.fromSupabaseJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      productId: json['product_id'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      averagePrice: (json['average_price'] as num).toDouble(),
      totalInvestment: (json['total_investment'] as num).toDouble(),
      currentValue: (json['current_value'] as num).toDouble(),
      profitLoss: (json['profit_loss'] as num).toDouble(),
      profitRate: (json['profit_rate'] as num).toDouble(),
      firstPurchaseAt: json['first_purchase_at'] != null 
          ? DateTime.parse(json['first_purchase_at'] as String) 
          : null,
      lastPurchaseAt: json['last_purchase_at'] != null 
          ? DateTime.parse(json['last_purchase_at'] as String) 
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  @override
  String toString() {
    return 'Portfolio(productId: $productId, quantity: $quantity, profitRate: $profitRate%)';
  }
}