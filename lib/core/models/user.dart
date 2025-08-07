class User {
  final String id;
  final String email;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final double initialCash;
  final double currentCash;
  final double totalAssets;
  final double totalReturn;
  final double returnRate;
  final double totalProfit; // Realized profit from sales
  final int level;
  final int experiencePoints;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;
  final bool isActive;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.initialCash = 100000000.0, // 1억원
    this.currentCash = 100000000.0,
    this.totalAssets = 100000000.0,
    this.totalReturn = 0.0,
    this.returnRate = 0.0,
    this.totalProfit = 0.0,
    this.level = 1,
    this.experiencePoints = 0,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
    this.isActive = true,
  });

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? avatarUrl,
    double? initialCash,
    double? currentCash,
    double? totalAssets,
    double? totalReturn,
    double? returnRate,
    double? totalProfit,
    int? level,
    int? experiencePoints,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      initialCash: initialCash ?? this.initialCash,
      currentCash: currentCash ?? this.currentCash,
      totalAssets: totalAssets ?? this.totalAssets,
      totalReturn: totalReturn ?? this.totalReturn,
      returnRate: returnRate ?? this.returnRate,
      totalProfit: totalProfit ?? this.totalProfit,
      level: level ?? this.level,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'initialCash': initialCash,
      'currentCash': currentCash,
      'totalAssets': totalAssets,
      'totalReturn': totalReturn,
      'returnRate': returnRate,
      'totalProfit': totalProfit,
      'level': level,
      'experiencePoints': experiencePoints,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'display_name': displayName,
      'initial_cash': initialCash,
      'current_cash': currentCash,
      'total_assets': totalAssets,
      'total_return': totalReturn,
      'return_rate': returnRate,
      'total_profit': totalProfit,
      'level': level,
      'experience_points': experiencePoints,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      initialCash: (json['initialCash'] as num).toDouble(),
      currentCash: (json['currentCash'] as num).toDouble(),
      totalAssets: (json['totalAssets'] as num).toDouble(),
      totalReturn: (json['totalReturn'] as num).toDouble(),
      returnRate: (json['returnRate'] as num).toDouble(),
      totalProfit: (json['totalProfit'] as num? ?? 0.0).toDouble(),
      level: json['level'] as int,
      experiencePoints: json['experiencePoints'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin'] as String) 
          : null,
      isActive: json['isActive'] as bool,
    );
  }

  factory User.fromSupabaseJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      initialCash: (json['initial_cash'] as num).toDouble(),
      currentCash: (json['current_cash'] as num).toDouble(),
      totalAssets: (json['total_assets'] as num).toDouble(),
      totalReturn: (json['total_return'] as num).toDouble(),
      returnRate: (json['return_rate'] as num).toDouble(),
      totalProfit: (json['total_profit'] as num? ?? 0.0).toDouble(),
      level: json['level'] as int,
      experiencePoints: json['experience_points'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login'] as String) 
          : null,
      isActive: true,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, displayName: $displayName, totalAssets: $totalAssets, returnRate: $returnRate%)';
  }
}