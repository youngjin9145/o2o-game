import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../domain/repositories/investment_repository.dart';
import '../../../../core/database/supabase_service.dart';
import '../../../../core/models/portfolio.dart';
import '../../../../core/models/trade_record.dart';
import '../../../../core/services/price_simulation_service.dart';

class InvestmentRepositoryImpl implements InvestmentRepository {
  final PriceSimulationService _priceService = PriceSimulationService();
  final SupabaseService _supabaseService = GetIt.instance<SupabaseService>();

  @override
  Future<List<Map<String, dynamic>>> getInvestmentProducts() async {
    // 실제 시뮬레이션 데이터 반환
    await Future.delayed(const Duration(milliseconds: 300));
    
    final products = _priceService.products;
    return products.map((product) => product.toJson()).toList();
  }

  @override
  Future<void> purchaseProduct(String productId, double amount) async {
    try {
      // 1. 시뮬레이션 서비스에서 구매 처리 (로쫀 상태 업데이트)
      final success = await _priceService.buyProduct(productId, amount);
      if (!success) {
        throw Exception('구매에 실패했습니다. 잔액이 부족하거나 오류가 발생했습니다.');
      }
      
      // 2. Supabase에 데이터 저장
      final currentUser = _priceService.currentUser;
      final product = _priceService.products.firstWhere((p) => p.id == productId);
      final quantity = amount / product.currentPrice;
      
      // 거래 기록 생성
      final tradeRecord = TradeRecord(
        id: _generateId(),
        userId: currentUser.id,
        productId: productId,
        productName: product.name,
        productIcon: product.icon,
        productType: product.type,
        tradeType: 'buy',
        quantity: quantity,
        price: product.currentPrice,
        totalAmount: amount,
        tradeDate: DateTime.now(),
      );
      
      // Supabase에 저장 시도
      try {
        await _supabaseService.insertTradeRecord(tradeRecord);
        print('Supabase에 거래 기록 저장 성공: ${tradeRecord.productName}');
        
        // 포트폴리오 업데이트
        await _updateOrCreatePortfolio(currentUser.id, productId, quantity, product.currentPrice, amount);
      } catch (e) {
        print('Supabase 저장 실패, 로쫀에만 저장: $e');
        // 에러가 나도 로쫀에는 이미 저장되었으므로 계속 진행
      }
      
    } catch (e) {
      throw Exception('구매 처리 중 오류: $e');
    }
  }
  
  Future<void> _updateOrCreatePortfolio(
    String userId,
    String productId,
    double quantity,
    double price,
    double totalAmount,
  ) async {
    try {
      final existingPortfolio = await _supabaseService.getPortfolioByUserAndProduct(userId, productId);
      
      if (existingPortfolio != null) {
        // 기존 포트폴리오 업데이트
        final newQuantity = existingPortfolio.quantity + quantity;
        final newTotalInvestment = existingPortfolio.totalInvestment + totalAmount;
        final newAveragePrice = newTotalInvestment / newQuantity;
        
        final updatedPortfolio = existingPortfolio.copyWith(
          quantity: newQuantity,
          averagePrice: newAveragePrice,
          totalInvestment: newTotalInvestment,
          currentValue: newQuantity * price,
          profitLoss: (newQuantity * price) - newTotalInvestment,
          profitRate: ((newQuantity * price) - newTotalInvestment) / newTotalInvestment * 100,
          lastPurchaseAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _supabaseService.updatePortfolio(updatedPortfolio);
      } else {
        // 새 포트폴리오 생성
        final newPortfolio = Portfolio(
          id: _generateId(),
          userId: userId,
          productId: productId,
          quantity: quantity,
          averagePrice: price,
          totalInvestment: totalAmount,
          currentValue: quantity * price,
          profitLoss: 0.0,
          profitRate: 0.0,
          firstPurchaseAt: DateTime.now(),
          lastPurchaseAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _supabaseService.insertPortfolio(newPortfolio);
      }
    } catch (e) {
      print('포트폴리오 업데이트 실패: $e');
      // 에러가 나도 전체 구매 프로세스를 실패시키지는 않음
    }
  }
  
  String _generateId() {
    const uuid = Uuid();
    return uuid.v4();
  }
}
