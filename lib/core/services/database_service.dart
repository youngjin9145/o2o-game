import 'dart:async';
import 'package:get_it/get_it.dart';
import '../database/local_storage_service.dart';
import '../models/user.dart' as app_user;
import '../models/portfolio.dart';
import '../models/trade_record.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final LocalStorageService _storageService = GetIt.instance<LocalStorageService>();

  // StreamControllers for real-time updates
  final StreamController<app_user.User?> _userController = StreamController<app_user.User?>.broadcast();
  final StreamController<List<Portfolio>> _portfoliosController = StreamController<List<Portfolio>>.broadcast();
  final StreamController<List<TradeRecord>> _tradeRecordsController = StreamController<List<TradeRecord>>.broadcast();

  // Streams
  Stream<app_user.User?> get userStream => _userController.stream;
  Stream<List<Portfolio>> get portfoliosStream => _portfoliosController.stream;
  Stream<List<TradeRecord>> get tradeRecordsStream => _tradeRecordsController.stream;

  // Current data cache
  app_user.User? _currentUser;
  List<Portfolio> _currentPortfolios = [];
  List<TradeRecord> _currentTradeRecords = [];

  // Getters for current data
  app_user.User? get currentUser => _currentUser;
  List<Portfolio> get currentPortfolios => List.from(_currentPortfolios);
  List<TradeRecord> get currentTradeRecords => List.from(_currentTradeRecords);

  // User operations
  Future<void> initializeUser(app_user.User user) async {
    try {
      // Check if user exists
      final existingUser = await _storageService.getUserById(user.id);

      if (existingUser == null) {
        // Create new user
        await _storageService.insertUser(user);
        print('데이터베이스: 새 사용자 생성 - ${user.displayName}');
      } else {
        // Update existing user with current session data
        await _storageService.updateUser(user);
        print('데이터베이스: 사용자 정보 업데이트 - ${user.displayName}');
      }

      _currentUser = user;
      _userController.add(_currentUser);

      // Load user's portfolios and trade records
      await _loadUserData(user.id);
    } catch (e) {
      print('사용자 초기화 실패: $e');
    }
  }

  Future<void> updateUser(app_user.User user) async {
    try {
      await _storageService.updateUser(user);
      _currentUser = user;
      _userController.add(_currentUser);
      print('사용자 정보 업데이트 완료: ${user.displayName}');
    } catch (e) {
      print('사용자 업데이트 실패: $e');
    }
  }

  Future<void> _loadUserData(String userId) async {
    try {
      // Load portfolios
      _currentPortfolios = await _storageService.getPortfoliosByUserId(userId);
      _portfoliosController.add(_currentPortfolios);
      print('포트폴리오 로드 완료: ${_currentPortfolios.length}개');

      // Load trade records
      _currentTradeRecords = await _storageService.getTradeRecordsByUserId(userId);
      _tradeRecordsController.add(_currentTradeRecords);
      print('매매기록 로드 완료: ${_currentTradeRecords.length}개');
    } catch (e) {
      print('사용자 데이터 로드 실패: $e');
    }
  }

  // Portfolio operations
  Future<Portfolio?> getPortfolioByProduct(String userId, String productId) async {
    try {
      return await _storageService.getPortfolioByUserAndProduct(userId, productId);
    } catch (e) {
      print('포트폴리오 조회 실패: $e');
      return null;
    }
  }

  Future<void> savePortfolio(Portfolio portfolio) async {
    try {
      // Check if portfolio exists
      final existing = await _storageService.getPortfolioByUserAndProduct(
        portfolio.userId,
        portfolio.productId,
      );

      if (existing != null) {
        // Update existing portfolio
        await _storageService.updatePortfolio(portfolio);
        print('포트폴리오 업데이트: ${portfolio.productId}');
      } else {
        // Insert new portfolio
        await _storageService.insertPortfolio(portfolio);
        print('새 포트폴리오 생성: ${portfolio.productId}');
      }

      // Refresh current data
      await _refreshPortfolios();
    } catch (e) {
      print('포트폴리오 저장 실패: $e');
    }
  }

  Future<void> deletePortfolio(String portfolioId) async {
    try {
      await _storageService.deletePortfolio(portfolioId);
      print('포트폴리오 삭제: $portfolioId');
      await _refreshPortfolios();
    } catch (e) {
      print('포트폴리오 삭제 실패: $e');
    }
  }

  Future<void> _refreshPortfolios() async {
    if (_currentUser != null) {
      _currentPortfolios = await _storageService.getPortfoliosByUserId(_currentUser!.id);
      _portfoliosController.add(_currentPortfolios);
    }
  }

  // Trade record operations
  Future<void> addTradeRecord(TradeRecord tradeRecord) async {
    try {
      await _storageService.insertTradeRecord(tradeRecord);
      print('매매기록 저장: ${tradeRecord.productName} ${tradeRecord.tradeType}');

      // Add to current cache and update stream
      _currentTradeRecords.insert(0, tradeRecord);
      _tradeRecordsController.add(_currentTradeRecords);
    } catch (e) {
      print('매매기록 저장 실패: $e');
    }
  }

  Future<List<TradeRecord>> getTradeRecordsByProduct(String productId) async {
    try {
      if (_currentUser == null) return [];
      return await _storageService.getTradeRecordsByProduct(_currentUser!.id, productId);
    } catch (e) {
      print('상품별 매매기록 조회 실패: $e');
      return [];
    }
  }

  // Statistics
  Future<Map<String, double>> getUserStatistics() async {
    try {
      if (_currentUser == null) return {};

      final totalInvestment = await _storageService.getTotalInvestmentByUser(_currentUser!.id);
      final totalSales = await _storageService.getTotalSalesByUser(_currentUser!.id);
      final profitByProduct = await _storageService.getProfitLossByProduct(_currentUser!.id);

      return {
        'totalInvestment': totalInvestment,
        'totalSales': totalSales,
        'netProfit': totalSales - totalInvestment,
        ...profitByProduct,
      };
    } catch (e) {
      print('통계 조회 실패: $e');
      return {};
    }
  }

  // Cleanup
  Future<void> clearAllData() async {
    try {
      await _storageService.clearAllData();
      _currentUser = null;
      _currentPortfolios.clear();
      _currentTradeRecords.clear();

      _userController.add(null);
      _portfoliosController.add([]);
      _tradeRecordsController.add([]);

      print('모든 데이터 삭제 완료');
    } catch (e) {
      print('데이터 삭제 실패: $e');
    }
  }

  Future<void> dispose() async {
    await _userController.close();
    await _portfoliosController.close();
    await _tradeRecordsController.close();
  }
}