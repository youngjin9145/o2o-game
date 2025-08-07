class InvestmentProduct {
  final String id;
  final String code; // HALLASAN, AAPL 등
  final String name;
  final String nameEn;
  final String description;
  final String category; // direct, indirect
  final String type; // unesco_heritage, stock, crypto, etf, bond
  final String? subType; // natural_heritage, geopark, biosphere
  final double basePrice;
  final double currentPrice;
  final double changeRate;
  final double changeAmount;
  final int volume;
  final double? marketCap;
  final String icon;
  final String? location;
  final bool isUnescoHeritage;
  final String? unescoCategory; // natural, cultural, memory, geopark, biosphere
  final double minInvestment;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InvestmentProduct({
    required this.id,
    required this.code,
    required this.name,
    required this.nameEn,
    required this.description,
    required this.category,
    required this.type,
    this.subType,
    required this.basePrice,
    required this.currentPrice,
    this.changeRate = 0.0,
    this.changeAmount = 0.0,
    this.volume = 0,
    this.marketCap,
    required this.icon,
    this.location,
    this.isUnescoHeritage = false,
    this.unescoCategory,
    this.minInvestment = 1000000.0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvestmentProduct.fromJson(Map<String, dynamic> json) {
    return InvestmentProduct(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      nameEn: json['nameEn'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      type: json['type'] as String,
      subType: json['subType'] as String?,
      basePrice: (json['basePrice'] as num).toDouble(),
      currentPrice: (json['currentPrice'] as num).toDouble(),
      changeRate: (json['changeRate'] as num? ?? 0).toDouble(),
      changeAmount: (json['changeAmount'] as num? ?? 0).toDouble(),
      volume: json['volume'] as int? ?? 0,
      marketCap: json['marketCap'] != null ? (json['marketCap'] as num).toDouble() : null,
      icon: json['icon'] as String,
      location: json['location'] as String?,
      isUnescoHeritage: json['isUnescoHeritage'] as bool? ?? false,
      unescoCategory: json['unescoCategory'] as String?,
      minInvestment: (json['minInvestment'] as num? ?? 1000000).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'nameEn': nameEn,
      'description': description,
      'category': category,
      'type': type,
      'subType': subType,
      'basePrice': basePrice,
      'currentPrice': currentPrice,
      'changeRate': changeRate,
      'changeAmount': changeAmount,
      'volume': volume,
      'marketCap': marketCap,
      'icon': icon,
      'location': location,
      'isUnescoHeritage': isUnescoHeritage,
      'unescoCategory': unescoCategory,
      'minInvestment': minInvestment,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  InvestmentProduct copyWith({
    String? id,
    String? code,
    String? name,
    String? nameEn,
    String? description,
    String? category,
    String? type,
    String? subType,
    double? basePrice,
    double? currentPrice,
    double? changeRate,
    double? changeAmount,
    int? volume,
    double? marketCap,
    String? icon,
    String? location,
    bool? isUnescoHeritage,
    String? unescoCategory,
    double? minInvestment,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvestmentProduct(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      subType: subType ?? this.subType,
      basePrice: basePrice ?? this.basePrice,
      currentPrice: currentPrice ?? this.currentPrice,
      changeRate: changeRate ?? this.changeRate,
      changeAmount: changeAmount ?? this.changeAmount,
      volume: volume ?? this.volume,
      marketCap: marketCap ?? this.marketCap,
      icon: icon ?? this.icon,
      location: location ?? this.location,
      isUnescoHeritage: isUnescoHeritage ?? this.isUnescoHeritage,
      unescoCategory: unescoCategory ?? this.unescoCategory,
      minInvestment: minInvestment ?? this.minInvestment,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum InvestmentCategory {
  direct('직접투자'),
  indirect('간접투자');

  const InvestmentCategory(this.label);
  final String label;
}

enum InvestmentType {
  realEstate('부동산'),
  stock('주식'),
  bond('채권'),
  crypto('가상자산'),
  etf('ETF'),
  mutualFund('뮤추얼 펀드');

  const InvestmentType(this.label);
  final String label;
}
