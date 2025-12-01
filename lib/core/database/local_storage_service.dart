import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/portfolio.dart';
import '../models/trade_record.dart';
import '../models/user.dart' as app_user;

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('LocalStorageService not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  // Keys
  static const String _usersKey = 'users';
  static const String _portfoliosKey = 'portfolios';
  static const String _tradeRecordsKey = 'trade_records';
  static const String _currentUserIdKey = 'current_user_id';

  // User CRUD
  Future<String> insertUser(app_user.User user) async {
    final users = await _getAllUsersMap();
    users[user.id] = user.toJson();
    await prefs.setString(_usersKey, json.encode(users));
    return user.id;
  }

  Future<app_user.User?> getUserById(String id) async {
    final users = await _getAllUsersMap();
    if (users.containsKey(id)) {
      return app_user.User.fromJson(users[id]!);
    }
    return null;
  }

  Future<app_user.User?> getUserByEmail(String email) async {
    final users = await _getAllUsersMap();
    for (final userJson in users.values) {
      final user = app_user.User.fromJson(userJson);
      if (user.email == email) {
        return user;
      }
    }
    return null;
  }

  Future<app_user.User?> getUserByUsername(String username) async {
    final users = await _getAllUsersMap();
    for (final userJson in users.values) {
      final user = app_user.User.fromJson(userJson);
      if (user.username == username) {
        return user;
      }
    }
    return null;
  }

  Future<void> updateUser(app_user.User user) async {
    final users = await _getAllUsersMap();
    users[user.id] = user.toJson();
    await prefs.setString(_usersKey, json.encode(users));
  }

  Future<List<app_user.User>> getAllUsers() async {
    final users = await _getAllUsersMap();
    final userList = users.values
        .map((json) => app_user.User.fromJson(json))
        .toList();

    // Sort by total assets
    userList.sort((a, b) => b.totalAssets.compareTo(a.totalAssets));
    return userList;
  }

  Future<Map<String, Map<String, dynamic>>> _getAllUsersMap() async {
    final usersString = prefs.getString(_usersKey);
    if (usersString == null) {
      return {};
    }
    final Map<String, dynamic> decoded = json.decode(usersString);
    return decoded.map((key, value) => MapEntry(key, value as Map<String, dynamic>));
  }

  // Portfolio CRUD
  Future<String> insertPortfolio(Portfolio portfolio) async {
    final portfolios = await _getAllPortfoliosMap();
    portfolios[portfolio.id] = portfolio.toJson();
    await prefs.setString(_portfoliosKey, json.encode(portfolios));
    return portfolio.id;
  }

  Future<List<Portfolio>> getPortfoliosByUserId(String userId) async {
    final portfolios = await _getAllPortfoliosMap();
    final userPortfolios = portfolios.values
        .map((json) => Portfolio.fromJson(json))
        .where((p) => p.userId == userId)
        .toList();

    // Sort by created date
    userPortfolios.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return userPortfolios;
  }

  Future<Portfolio?> getPortfolioByUserAndProduct(String userId, String productId) async {
    final portfolios = await _getAllPortfoliosMap();
    for (final portfolioJson in portfolios.values) {
      final portfolio = Portfolio.fromJson(portfolioJson);
      if (portfolio.userId == userId && portfolio.productId == productId) {
        return portfolio;
      }
    }
    return null;
  }

  Future<void> updatePortfolio(Portfolio portfolio) async {
    final portfolios = await _getAllPortfoliosMap();
    portfolios[portfolio.id] = portfolio.toJson();
    await prefs.setString(_portfoliosKey, json.encode(portfolios));
  }

  Future<void> deletePortfolio(String id) async {
    final portfolios = await _getAllPortfoliosMap();
    portfolios.remove(id);
    await prefs.setString(_portfoliosKey, json.encode(portfolios));
  }

  Future<Map<String, Map<String, dynamic>>> _getAllPortfoliosMap() async {
    final portfoliosString = prefs.getString(_portfoliosKey);
    if (portfoliosString == null) {
      return {};
    }
    final Map<String, dynamic> decoded = json.decode(portfoliosString);
    return decoded.map((key, value) => MapEntry(key, value as Map<String, dynamic>));
  }

  // Trade Record CRUD
  Future<String> insertTradeRecord(TradeRecord tradeRecord) async {
    final records = await _getAllTradeRecordsMap();
    records[tradeRecord.id] = tradeRecord.toJson();
    await prefs.setString(_tradeRecordsKey, json.encode(records));
    return tradeRecord.id;
  }

  Future<List<TradeRecord>> getTradeRecordsByUserId(String userId, {int? limit}) async {
    final records = await _getAllTradeRecordsMap();
    var userRecords = records.values
        .map((json) => TradeRecord.fromJson(json))
        .where((r) => r.userId == userId)
        .toList();

    // Sort by trade date
    userRecords.sort((a, b) => b.tradeDate.compareTo(a.tradeDate));

    if (limit != null && userRecords.length > limit) {
      userRecords = userRecords.sublist(0, limit);
    }

    return userRecords;
  }

  Future<List<TradeRecord>> getTradeRecordsByProduct(String userId, String productId) async {
    final records = await _getAllTradeRecordsMap();
    final productRecords = records.values
        .map((json) => TradeRecord.fromJson(json))
        .where((r) => r.userId == userId && r.productId == productId)
        .toList();

    // Sort by trade date
    productRecords.sort((a, b) => b.tradeDate.compareTo(a.tradeDate));
    return productRecords;
  }

  Future<Map<String, Map<String, dynamic>>> _getAllTradeRecordsMap() async {
    final recordsString = prefs.getString(_tradeRecordsKey);
    if (recordsString == null) {
      return {};
    }
    final Map<String, dynamic> decoded = json.decode(recordsString);
    return decoded.map((key, value) => MapEntry(key, value as Map<String, dynamic>));
  }

  // Statistics (simplified without RPC)
  Future<double> getTotalInvestmentByUser(String userId) async {
    final records = await getTradeRecordsByUserId(userId);
    double total = 0.0;
    for (final record in records) {
      if (record.tradeType == 'buy') {
        total += record.totalAmount;
      }
    }
    return total;
  }

  Future<double> getTotalSalesByUser(String userId) async {
    final records = await getTradeRecordsByUserId(userId);
    double total = 0.0;
    for (final record in records) {
      if (record.tradeType == 'sell') {
        total += record.totalAmount;
      }
    }
    return total;
  }

  Future<Map<String, double>> getProfitLossByProduct(String userId) async {
    final records = await getTradeRecordsByUserId(userId);
    final Map<String, double> profitMap = {};

    for (final record in records) {
      if (record.tradeType == 'sell' && record.profit != null) {
        final productName = record.productName;
        profitMap[productName] = (profitMap[productName] ?? 0.0) + record.profit!;
      }
    }

    return profitMap;
  }

  // Current user management
  Future<void> setCurrentUserId(String userId) async {
    await prefs.setString(_currentUserIdKey, userId);
  }

  String? getCurrentUserId() {
    return prefs.getString(_currentUserIdKey);
  }

  Future<void> clearCurrentUserId() async {
    await prefs.remove(_currentUserIdKey);
  }

  // Clear all data
  Future<void> clearAllData() async {
    await prefs.remove(_usersKey);
    await prefs.remove(_portfoliosKey);
    await prefs.remove(_tradeRecordsKey);
    await prefs.remove(_currentUserIdKey);
  }
}
