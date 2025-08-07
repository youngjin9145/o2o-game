import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/portfolio.dart';
import '../models/trade_record.dart';
import 'database_service.dart';

/// 플랫폼에 따라 다른 저장소를 사용하는 통합 서비스
/// - 웹: SharedPreferences 사용
/// - 모바일: SQLite 사용
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  DatabaseService? _databaseService;
  SharedPreferences? _prefs;

  // StreamControllers for web fallback
  final StreamController<User?> _userController = StreamController<User?>.broadcast();
  final StreamController<List<Portfolio>> _portfoliosController = StreamController<List<Portfolio>>.broadcast();
  final StreamController<List<TradeRecord>> _tradeRecordsController = StreamController<List<TradeRecord>>.broadcast();

  // Current data cache
  User? _currentUser;
  List<Portfolio> _currentPortfolios = [];
  List<TradeRecord> _currentTradeRecords = [];

  // Streams
  Stream<User?> get userStream => kIsWeb ? _userController.stream : _databaseService!.userStream;
  Stream<List<Portfolio>> get portfoliosStream => kIsWeb ? _portfoliosController.stream : _databaseService!.portfoliosStream;
  Stream<List<TradeRecord>> get tradeRecordsStream => kIsWeb ? _tradeRecordsController.stream : _databaseService!.tradeRecordsStream;

  // Getters
  User? get currentUser => kIsWeb ? _currentUser : _databaseService?.currentUser;
  List<Portfolio> get currentPortfolios => kIsWeb ? List.from(_currentPortfolios) : _databaseService?.currentPortfolios ?? [];
  List<TradeRecord> get currentTradeRecords => kIsWeb ? List.from(_currentTradeRecords) : _databaseService?.currentTradeRecords ?? [];

  Future<void> initialize() async {
    if (kIsWeb) {
      await _initializeWeb();
    } else {
      await _initializeMobile();
    }
  }

  Future<void> _initializeWeb() async {
    _prefs = await SharedPreferences.getInstance();
    
    print('웹 저장소 초기화 완료: SharedPreferences 준비됨');
  }
  
  Future<void> _loadInitialWebData() async {
    // Load existing data
    await _loadWebData();
    
    print('웹 저장소 데이터 로드 완료: 포트폴리오 ${_currentPortfolios.length}개, 매매기록 ${_currentTradeRecords.length}개');
  }

  Future<void> _initializeMobile() async {
    _databaseService = DatabaseService();
    print('모바일 SQLite 초기화 완료');
  }

  Future<void> _loadWebData() async {
    if (_prefs == null) return;

    // Load portfolios
    final portfoliosString = _prefs!.getString('portfolios');
    if (portfoliosString != null) {
      final portfoliosJson = jsonDecode(portfoliosString) as List;
      _currentPortfolios = portfoliosJson
          .map((json) => Portfolio.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    // Load trade records
    final tradeRecordsString = _prefs!.getString('trade_records');
    if (tradeRecordsString != null) {
      final tradeRecordsJson = jsonDecode(tradeRecordsString) as List;
      _currentTradeRecords = tradeRecordsJson
          .map((json) => TradeRecord.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    // CRITICAL FIX: 웹에서는 즉시 스트림에 초기 데이터 전송
    // 빈 리스트라도 반드시 전송하여 StreamBuilder가 hasData=true가 되도록 함
    _portfoliosController.add(List.from(_currentPortfolios));
    _tradeRecordsController.add(List.from(_currentTradeRecords));
    
    print('웹 스트림 초기화: 포트폴리오 ${_currentPortfolios.length}개, 매매기록 ${_currentTradeRecords.length}개 전송');
    
    // 사용자가 설정되면 사용자 스트림도 즉시 전송
    if (_currentUser != null) {
      _userController.add(_currentUser);
    }
  }

  // User operations
  Future<void> initializeUser(User user) async {
    if (kIsWeb) {
      _currentUser = user;
      
      // 웹에서는 사용자 설정 후 데이터를 로드하고 스트림에 전송
      await _loadInitialWebData();
      
      // 사용자 스트림 전송
      _userController.add(_currentUser);
      
      print('웹 사용자 초기화 완료: ${user.displayName}');
    } else {
      await _databaseService!.initializeUser(user);
    }
  }

  Future<void> updateUser(User user) async {
    if (kIsWeb) {
      _currentUser = user;
      _userController.add(_currentUser);
    } else {
      await _databaseService!.updateUser(user);
    }
  }

  // Portfolio operations
  Future<Portfolio?> getPortfolioByProduct(String userId, String productId) async {
    if (kIsWeb) {
      try {
        return _currentPortfolios.firstWhere(
          (p) => p.userId == userId && p.productId == productId,
        );
      } catch (e) {
        return null;
      }
    } else {
      return await _databaseService!.getPortfolioByProduct(userId, productId);
    }
  }

  Future<void> savePortfolio(Portfolio portfolio) async {
    if (kIsWeb) {
      // Find existing or add new
      final existingIndex = _currentPortfolios.indexWhere(
        (p) => p.userId == portfolio.userId && p.productId == portfolio.productId,
      );

      if (existingIndex >= 0) {
        _currentPortfolios[existingIndex] = portfolio;
      } else {
        _currentPortfolios.add(portfolio);
      }

      // Save to SharedPreferences
      await _savePortfoliosToPrefs();
      _portfoliosController.add(List.from(_currentPortfolios));
      
      print('웹 포트폴리오 저장: ${portfolio.productId}');
    } else {
      await _databaseService!.savePortfolio(portfolio);
    }
  }

  Future<void> deletePortfolio(String portfolioId) async {
    if (kIsWeb) {
      _currentPortfolios.removeWhere((p) => p.id == portfolioId);
      await _savePortfoliosToPrefs();
      _portfoliosController.add(List.from(_currentPortfolios));
      
      print('웹 포트폴리오 삭제: $portfolioId');
    } else {
      await _databaseService!.deletePortfolio(portfolioId);
    }
  }

  // Trade record operations
  Future<void> addTradeRecord(TradeRecord tradeRecord) async {
    if (kIsWeb) {
      _currentTradeRecords.insert(0, tradeRecord);
      await _saveTradeRecordsToPrefs();
      _tradeRecordsController.add(List.from(_currentTradeRecords));
      
      print('웹 매매기록 저장: ${tradeRecord.productName} ${tradeRecord.tradeType}');
    } else {
      await _databaseService!.addTradeRecord(tradeRecord);
    }
  }

  Future<List<TradeRecord>> getTradeRecordsByProduct(String productId) async {
    if (kIsWeb) {
      return _currentTradeRecords
          .where((record) => record.productId == productId)
          .toList();
    } else {
      return await _databaseService!.getTradeRecordsByProduct(productId);
    }
  }

  // Web-specific save methods
  Future<void> _savePortfoliosToPrefs() async {
    if (_prefs != null) {
      final portfoliosJson = _currentPortfolios.map((p) => p.toJson()).toList();
      await _prefs!.setString('portfolios', jsonEncode(portfoliosJson));
    }
  }

  Future<void> _saveTradeRecordsToPrefs() async {
    if (_prefs != null) {
      final tradeRecordsJson = _currentTradeRecords.map((r) => r.toJson()).toList();
      await _prefs!.setString('trade_records', jsonEncode(tradeRecordsJson));
    }
  }

  // Statistics (simplified for web)
  Future<Map<String, double>> getUserStatistics() async {
    if (kIsWeb) {
      final buyRecords = _currentTradeRecords.where((r) => r.tradeType == 'buy');
      final sellRecords = _currentTradeRecords.where((r) => r.tradeType == 'sell');
      
      final totalInvestment = buyRecords.fold<double>(0.0, (sum, r) => sum + r.totalAmount);
      final totalSales = sellRecords.fold<double>(0.0, (sum, r) => sum + r.totalAmount);
      
      return {
        'totalInvestment': totalInvestment,
        'totalSales': totalSales,
        'netProfit': totalSales - totalInvestment,
      };
    } else {
      return await _databaseService!.getUserStatistics();
    }
  }

  // Migration (only needed for mobile)
  Future<void> migrateFromSharedPreferences(
    List<Portfolio> portfolios,
    List<TradeRecord> tradeRecords,
  ) async {
    if (!kIsWeb && _databaseService != null) {
      await _databaseService!.migrateFromSharedPreferences(portfolios, tradeRecords);
    }
  }

  // Cleanup
  Future<void> clearAllData() async {
    if (kIsWeb) {
      _currentUser = null;
      _currentPortfolios.clear();
      _currentTradeRecords.clear();
      
      if (_prefs != null) {
        await _prefs!.clear();
      }
      
      _userController.add(null);
      _portfoliosController.add([]);
      _tradeRecordsController.add([]);
      
      print('웹 데이터 삭제 완료');
    } else {
      await _databaseService!.clearAllData();
    }
  }

  Future<void> dispose() async {
    if (kIsWeb) {
      await _userController.close();
      await _portfoliosController.close();
      await _tradeRecordsController.close();
    } else {
      await _databaseService?.dispose();
    }
  }
}