import 'package:get_it/get_it.dart';

import '../../domain/repositories/portfolio_repository.dart';
import '../../../../core/database/local_storage_service.dart';
import '../../../../core/services/price_simulation_service.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  final PriceSimulationService _priceService = PriceSimulationService();
  final LocalStorageService _storageService = GetIt.instance<LocalStorageService>();

  @override
  Future<Map<String, dynamic>> getPortfolioData() async {
    try {
      final currentUser = _priceService.currentUser;

      // 로컬 스토리지에서 포트폴리오 데이터 가져오기
      final portfolios = await _storageService.getPortfoliosByUserId(currentUser.id);

      if (portfolios.isEmpty) {
        // 포트폴리오가 비어있으면 초기 값 반환
        return {
          'totalAssets': currentUser.currentCash,
          'totalReturn': 0.0,
          'returnRate': 0.0,
        };
      }

      // 포트폴리오 총 값 계산
      double totalCurrentValue = portfolios.fold(
        0.0,
        (sum, portfolio) => sum + portfolio.currentValue,
      );

      double totalInvestment = portfolios.fold(
        0.0,
        (sum, portfolio) => sum + portfolio.totalInvestment,
      );

      double totalReturn = totalCurrentValue - totalInvestment;
      double returnRate = totalInvestment > 0 ? (totalReturn / totalInvestment) * 100 : 0.0;
      double totalAssets = currentUser.currentCash + totalCurrentValue;

      return {
        'totalAssets': totalAssets,
        'totalReturn': totalReturn,
        'returnRate': returnRate,
      };
    } catch (e) {
      print('로컬 스토리지에서 포트폴리오 데이터 가져오기 실패: $e');
      // 실패시 로컬 데이터 사용
      final user = _priceService.currentUser;
      return {
        'totalAssets': user.totalAssets,
        'totalReturn': user.totalReturn,
        'returnRate': user.returnRate,
      };
    }
  }

  @override
  Future<void> updatePortfolio(Map<String, dynamic> data) async {
    // 포트폴리오 업데이트 로직은 거래 시에 자동으로 처리됨
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
