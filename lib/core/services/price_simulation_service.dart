import 'dart:async';
import 'dart:math';
import 'package:get_it/get_it.dart';
import '../database/supabase_service.dart';
import '../models/user.dart' as app_user;
import '../models/portfolio.dart';
import '../models/trade_record.dart';
import '../../features/investment/domain/entities/investment_product.dart';
import '../data/seed_data.dart';
import 'package:uuid/uuid.dart';

class PriceSimulationService {
  static final PriceSimulationService _instance = PriceSimulationService._internal();
  factory PriceSimulationService() => _instance;
  PriceSimulationService._internal();

  Timer? _simulationTimer;
  final Random _random = Random();
  final SupabaseService _supabaseService = GetIt.instance<SupabaseService>();
  final Uuid _uuid = const Uuid();

  // 실시간 데이터를 위한 StreamController들
  final StreamController<List<InvestmentProduct>> _productsController = 
      StreamController<List<InvestmentProduct>>.broadcast();
  final StreamController<app_user.User?> _userController = 
      StreamController<app_user.User?>.broadcast();
  final StreamController<List<Portfolio>> _portfoliosController = 
      StreamController<List<Portfolio>>.broadcast();
  final StreamController<List<TradeRecord>> _tradeRecordsController = 
      StreamController<List<TradeRecord>>.broadcast();

  // 현재 데이터 상태
  List<InvestmentProduct> _products = [];
  app_user.User _currentUser = SeedData.demoUser;
  List<Portfolio> _portfolios = [];
  List<TradeRecord> _tradeRecords = [];

  // Getters for streams
  Stream<List<InvestmentProduct>> get productsStream => _productsController.stream;
  Stream<app_user.User?> get userStream => _userController.stream;
  Stream<List<Portfolio>> get portfolioStream => _portfoliosController.stream;
  Stream<List<TradeRecord>> get tradeRecordsStream => _tradeRecordsController.stream;

  // Getters for current data
  List<InvestmentProduct> get products => _products;
  app_user.User get currentUser => _currentUser;
  List<Portfolio> get portfolios => _portfolios;
  List<TradeRecord> get tradeRecords => _tradeRecords;

  void initialize() async {
    // 시드 데이터로 초기화
    _products = List.from(SeedData.investmentProducts);
    
    // 로그인 사용자가 있으면 그 사용자를, 없으면 데모 사용자를 설정
    // 실제 사용자는 main.dart의 _initializeExistingUser에서 설정됨
    _currentUser = SeedData.demoUser;
    
    // 초기 데이터를 스트림에 전송
    _productsController.add(_products);
    _userController.add(_currentUser);
    _portfoliosController.add([]);
    _tradeRecordsController.add([]);

    print('서비스 초기화 완료: 포트폴리오 0개, 매매기록 0개');

    // 가격 시뮬레이션 시작
    startPriceSimulation();
  }

  // 사용자 설정 (로그인시 호출)
  void setUser(app_user.User user) async {
    _currentUser = user;
    _userController.add(_currentUser);
    
    // Supabase에서 사용자 데이터 로드
    await _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    try {
      // Supabase에서 포트폴리오와 거래기록 로드
      _portfolios = await _supabaseService.getPortfoliosByUserId(_currentUser.id);
      _tradeRecords = await _supabaseService.getTradeRecordsByUserId(_currentUser.id);
      
      // 스트림에 전송
      _portfoliosController.add(_portfolios);
      _tradeRecordsController.add(_tradeRecords);
      
      print('Supabase에서 데이터 로드 완료: 포트폴리오 ${_portfolios.length}개, 거래기록 ${_tradeRecords.length}개');
    } catch (e) {
      print('Supabase 데이터 로드 실패: $e');
      // 실패 시 빈 데이터로 초기화
      _portfolios = [];
      _tradeRecords = [];
      _portfoliosController.add(_portfolios);
      _tradeRecordsController.add(_tradeRecords);
    }
  }

  void startPriceSimulation() {
    // 3초마다 가격 업데이트
    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updatePrices();
      _updatePortfolios();
      _updateUserAssets();
    });
  }

  void stopPriceSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  void _updatePrices() {
    final updatedProducts = _products.map((product) {
      final priceChange = _generatePriceChange(product);
      final newPrice = (product.currentPrice * (1 + priceChange / 100)).clamp(
        product.basePrice * 0.5, // 최소 50% 하락까지만
        product.basePrice * 2.0,  // 최대 100% 상승까지만
      );
      
      final changeAmount = newPrice - product.currentPrice;
      final changeRate = (changeAmount / product.currentPrice) * 100;
      
      return product.copyWith(
        currentPrice: newPrice,
        changeRate: changeRate,
        changeAmount: changeAmount,
        volume: product.volume + _random.nextInt(20) - 10,
        updatedAt: DateTime.now(),
      );
    }).toList();

    _products = updatedProducts;
    _productsController.add(_products);
  }

  double _generatePriceChange(InvestmentProduct product) {
    // 상품 유형별 변동성 차이
    double volatility;
    switch (product.type) {
      case 'crypto':
        volatility = 3.0;
        break;
      case 'stock':
        volatility = 1.5;
        break;
      case 'unesco_heritage':
        volatility = 0.8;
        break;
      case 'bond':
        volatility = 0.3;
        break;
      default:
        volatility = 1.0;
    }

    // 정규분포 근사
    final u1 = _random.nextDouble();
    final u2 = _random.nextDouble();
    final z0 = sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
    
    return (z0 * volatility).clamp(-5.0, 5.0);
  }

  void _updatePortfolios() async {
    try {
      List<Portfolio> updatedPortfolios = [];
      
      for (final portfolio in _portfolios) {
        final product = _products.firstWhere(
          (p) => p.id == portfolio.productId,
          orElse: () => _products.first,
        );
        
        final currentValue = portfolio.quantity * product.currentPrice;
        final profitLoss = currentValue - portfolio.totalInvestment;
        final profitRate = portfolio.totalInvestment > 0 
            ? (profitLoss / portfolio.totalInvestment) * 100 
            : 0.0;

        final updatedPortfolio = portfolio.copyWith(
          currentValue: currentValue,
          profitLoss: profitLoss,
          profitRate: profitRate,
          updatedAt: DateTime.now(),
        );
        
        updatedPortfolios.add(updatedPortfolio);
        
        // Supabase에 업데이트 (비동기로 처리)
        _supabaseService.updatePortfolio(updatedPortfolio).catchError((e) {
          print('포트폴리오 업데이트 실패: $e');
        });
      }
      
      _portfolios = updatedPortfolios;
      _portfoliosController.add(_portfolios);
    } catch (e) {
      print('포트폴리오 업데이트 실패: $e');
    }
  }

  void _updateUserAssets() async {
    try {
      // 현재 보유 중인 포트폴리오의 가치
      final totalCurrentValue = _portfolios.fold<double>(
        0.0, 
        (sum, portfolio) => sum + portfolio.currentValue,
      );
      final totalInvestment = _portfolios.fold<double>(
        0.0, 
        (sum, portfolio) => sum + portfolio.totalInvestment,
      );
      
      // 매도 거래에서 실현된 수익 계산
      final realizedProfit = _tradeRecords.where((record) => record.tradeType == 'sell')
          .fold<double>(0.0, (sum, record) => sum + (record.profit ?? 0.0));
      
      // 현재 보유 중인 자산의 미실현 수익
      final unrealizedProfit = totalCurrentValue - totalInvestment;
      
      // 총 자산 = 현금 + 현재 보유 자산 가치
      final totalAssets = _currentUser.currentCash + totalCurrentValue;
      
      // 총 수익 = 실현된 수익 + 미실현 수익
      final totalReturn = realizedProfit + unrealizedProfit;
      
      // 총 투자 원금 = 현재 보유 투자금 + 모든 매수 거래 금액 - 현재 보유 투자금 (중복 제거)
      final totalBoughtAmount = _tradeRecords.where((record) => record.tradeType == 'buy')
          .fold<double>(0.0, (sum, record) => sum + record.totalAmount);
      
      final totalOriginalInvestment = totalBoughtAmount;
      
      // 수익률 계산
      final returnRate = totalOriginalInvestment > 0 
          ? (totalReturn / totalOriginalInvestment) * 100 
          : 0.0;

      final updatedUser = _currentUser.copyWith(
        totalAssets: totalAssets,
        totalReturn: totalReturn,
        returnRate: returnRate,
        updatedAt: DateTime.now(),
      );

      _currentUser = updatedUser;
      _userController.add(_currentUser);
      
      // Supabase에 업데이트 (비동기로 처리)
      _supabaseService.updateUser(updatedUser).catchError((e) {
        print('사용자 업데이트 실패: $e');
      });
    } catch (e) {
      print('사용자 자산 업데이트 실패: $e');
    }
  }

  // 매수 기능 - 수량 기준으로 변경
  Future<bool> buyProduct(String productId, double quantity, {bool immediatePortfolioUpdate = false}) async {
    try {
      final product = _products.firstWhere((p) => p.id == productId);
      final purchasePrice = product.currentPrice;
      
      print('구매 시도: ${product.name}, 요청수량: ${quantity}개, 현재가격: ${purchasePrice}, 보유현금: ${_currentUser.currentCash}');
      
      // 수량이 1개 미만인지 확인
      if (quantity < 1) {
        print('구매 실패: 수량이 1개 미만 (${quantity})');
        return false;
      }
      
      final actualAmount = quantity * purchasePrice;
      print('실제 구매 금액: ${actualAmount}');

      if (_currentUser.currentCash < actualAmount) {
        print('구매 실패: 현금 부족 (보유: ${_currentUser.currentCash}, 필요: ${actualAmount})');
        return false;
      }

      // 현금 차감
      _currentUser = _currentUser.copyWith(
        currentCash: _currentUser.currentCash - actualAmount,
        updatedAt: DateTime.now(),
      );

      // 거래 기록 생성 (매수 기록은 항상 바로 생성)
      final tradeRecord = TradeRecord(
        id: _uuid.v4(),
        userId: _currentUser.id,
        productId: productId,
        productName: product.name,
        productIcon: product.icon,
        productType: product.type,
        tradeType: 'buy',
        quantity: quantity,
        price: purchasePrice,
        totalAmount: actualAmount,
        averagePrice: null, // 매수 시에는 null
        tradeDate: DateTime.now(),
      );

      await _supabaseService.insertTradeRecord(tradeRecord);

      // 포트폴리오 업데이트는 옵션에 따라 처리
      if (immediatePortfolioUpdate) {
        final savedPortfolio = await _updatePortfolioAfterPurchase(productId, quantity, actualAmount, purchasePrice, product);
        
        // 로컬 포트폴리오 리스트도 업데이트
        final existingIndex = _portfolios.indexWhere((p) => p.productId == productId);
        if (existingIndex >= 0) {
          _portfolios[existingIndex] = savedPortfolio;
        } else {
          _portfolios.add(savedPortfolio);
        }
        
        // 스트림에 즉시 반영
        _portfoliosController.add(_portfolios);
      }

      // 사용자 정보 업데이트
      await _supabaseService.updateUser(_currentUser);
      
      // 거래 기록만 새로고침
      _tradeRecords = await _supabaseService.getTradeRecordsByUserId(_currentUser.id);
      _tradeRecordsController.add(_tradeRecords);
      
      _userController.add(_currentUser);

      print('매수 완료: ${product.name} ${quantity.round()}개 ${immediatePortfolioUpdate ? '(포트폴리오 즉시 반영)' : '(거래 기록만 저장)'}');
      return true;
    } catch (e, stackTrace) {
      print('매수 실패 예외 발생: $e');
      print('스택트레이스: $stackTrace');
      return false;
    }
  }

  Future<Portfolio> _updatePortfolioAfterPurchase(String productId, double quantity, double actualAmount, double purchasePrice, InvestmentProduct product) async {
    // 기존 포트폴리오 찾기
    final existingPortfolio = _portfolios.firstWhere(
      (p) => p.productId == productId,
      orElse: () => Portfolio(
        id: '',
        userId: '',
        productId: '',
        quantity: 0,
        averagePrice: 0,
        totalInvestment: 0,
        currentValue: 0,
        profitLoss: 0,
        profitRate: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    Portfolio portfolioToSave;
    if (existingPortfolio.id.isNotEmpty) {
      // 기존 포트폴리오 업데이트
      final newQuantity = existingPortfolio.quantity + quantity;
      final newTotalInvestment = existingPortfolio.totalInvestment + actualAmount;
      final newAveragePrice = newTotalInvestment / newQuantity;
      final newCurrentValue = newQuantity * product.currentPrice;

      portfolioToSave = existingPortfolio.copyWith(
        quantity: newQuantity,
        averagePrice: newAveragePrice,
        totalInvestment: newTotalInvestment,
        currentValue: newCurrentValue,
        profitLoss: newCurrentValue - newTotalInvestment,
        profitRate: ((newCurrentValue - newTotalInvestment) / newTotalInvestment) * 100,
        lastPurchaseAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _supabaseService.updatePortfolio(portfolioToSave);
    } else {
      // 새 포트폴리오 생성
      portfolioToSave = Portfolio(
        id: _uuid.v4(),
        userId: _currentUser.id,
        productId: productId,
        quantity: quantity,
        averagePrice: purchasePrice,
        totalInvestment: actualAmount,
        currentValue: actualAmount,
        profitLoss: 0.0,
        profitRate: 0.0,
        firstPurchaseAt: DateTime.now(),
        lastPurchaseAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _supabaseService.insertPortfolio(portfolioToSave);
    }
    
    return portfolioToSave;
  }

  // 매도 기능
  Future<bool> sellProduct(String productId, double quantity) async {
    try {
      final product = _products.firstWhere((p) => p.id == productId);
      final portfolio = _portfolios.firstWhere(
        (p) => p.productId == productId,
        orElse: () => Portfolio(
          id: '',
          userId: '',
          productId: '',
          quantity: 0,
          averagePrice: 0,
          totalInvestment: 0,
          currentValue: 0,
          profitLoss: 0,
          profitRate: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      if (portfolio.id.isEmpty || portfolio.quantity < quantity) return false;

      final sellAmount = quantity * product.currentPrice;
      final profitFromSale = (product.currentPrice - portfolio.averagePrice) * quantity;

      // 현금 증가
      _currentUser = _currentUser.copyWith(
        currentCash: _currentUser.currentCash + sellAmount,
        updatedAt: DateTime.now(),
      );

      // 포트폴리오 업데이트 또는 삭제
      if (portfolio.quantity == quantity) {
        // 전량 매도
        await _supabaseService.deletePortfolio(portfolio.id);
      } else {
        // 부분 매도
        final remainingQuantity = portfolio.quantity - quantity;
        final remainingInvestment = portfolio.averagePrice * remainingQuantity;
        
        final updatedPortfolio = portfolio.copyWith(
          quantity: remainingQuantity,
          totalInvestment: remainingInvestment,
          currentValue: remainingQuantity * product.currentPrice,
          profitLoss: (remainingQuantity * product.currentPrice) - remainingInvestment,
          profitRate: (((remainingQuantity * product.currentPrice) - remainingInvestment) / remainingInvestment) * 100,
          updatedAt: DateTime.now(),
        );
        
        await _supabaseService.updatePortfolio(updatedPortfolio);
      }

      // 거래 기록 생성
      final tradeRecord = TradeRecord(
        id: _uuid.v4(),
        userId: _currentUser.id,
        productId: productId,
        productName: product.name,
        productIcon: product.icon,
        productType: product.type,
        tradeType: 'sell',
        quantity: quantity,
        price: product.currentPrice,
        totalAmount: sellAmount,
        averagePrice: null, // 임시로 null 설정 (DB 컬럼 없음)
        profit: profitFromSale,
        profitRate: (profitFromSale / (portfolio.averagePrice * quantity)) * 100,
        tradeDate: DateTime.now(),
      );

      await _supabaseService.insertTradeRecord(tradeRecord);

      // 로컬 데이터 업데이트 및 스트림 전송
      await _loadUserData(); // 데이터 새로고침
      
      // 사용자 자산 정보 업데이트 (실현된 수익 포함)
      _updateUserAssets();
      
      await _supabaseService.updateUser(_currentUser);

      print('매도 완료: ${product.name} ${quantity.round()}개');
      return true;
    } catch (e) {
      print('매도 실패: $e');
      return false;
    }
  }

  // 거래 기록에서 포트폴리오로 이동하는 기능 추가
  Future<bool> addTradeToPortfolio(String tradeRecordId) async {
    try {
      final tradeRecord = _tradeRecords.firstWhere((t) => t.id == tradeRecordId);
      if (tradeRecord.tradeType != 'buy') return false;

      final product = _products.firstWhere((p) => p.id == tradeRecord.productId);
      
      final savedPortfolio = await _updatePortfolioAfterPurchase(
        tradeRecord.productId, 
        tradeRecord.quantity, 
        tradeRecord.totalAmount, 
        tradeRecord.price, 
        product
      );

      // 로컬 포트폴리오 리스트도 업데이트
      final existingIndex = _portfolios.indexWhere((p) => p.productId == tradeRecord.productId);
      if (existingIndex >= 0) {
        _portfolios[existingIndex] = savedPortfolio;
      } else {
        _portfolios.add(savedPortfolio);
      }
      
      _portfoliosController.add(_portfolios);

      print('포트폴리오에 추가 완료: ${tradeRecord.productName}');
      return true;
    } catch (e) {
      print('포트폴리오 추가 실패: $e');
      return false;
    }
  }

  // 보유하지 않은 매수 기록 목록 가져오기
  List<TradeRecord> getPendingBuyRecords() {
    final portfolioProductIds = _portfolios.map((p) => p.productId).toSet();
    return _tradeRecords.where((record) => 
      record.tradeType == 'buy' && 
      !portfolioProductIds.contains(record.productId)
    ).toList();
  }

  void dispose() {
    _simulationTimer?.cancel();
    _productsController.close();
    _userController.close();
    _portfoliosController.close();
    _tradeRecordsController.close();
  }
}