import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/price_simulation_service.dart';
import '../../../../core/models/portfolio.dart';
import '../../../../core/models/user.dart';
import '../../../investment/domain/entities/investment_product.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onNavigateToUnescoTab;
  const HomePage({super.key, this.onNavigateToUnescoTab});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PriceSimulationService _priceService = PriceSimulationService();
  final _currencyFormat = NumberFormat('#,###', 'ko_KR');

  @override
  void initState() {
    super.initState();
    // 서비스가 초기화되어 있지 않으면 초기화
    if (_priceService.portfolios.isEmpty && _priceService.products.isEmpty) {
      _priceService.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '내 자산',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: StreamBuilder<User?>(
        stream: _priceService.userStream,
        builder: (context, userSnapshot) {
          final user = userSnapshot.data ?? _priceService.currentUser;
          
          return SingleChildScrollView(
            child: Column(
              children: [
                // 총 자산 요약 카드
                _buildAssetSummary(user),
                
                const SizedBox(height: 20),
                
                // 빠른 액션 버튼
                _buildQuickActions(),
                
                const SizedBox(height: 20),
                
                // 보유 자산 리스트
                _buildAssetsList(),
                
                const SizedBox(height: 20), // 하단 여백
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAssetSummary(User user) {
    final isProfit = user.returnRate >= 0;
    
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '총 자산',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_currencyFormat.format(user.totalAssets.round())}원',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isProfit 
                    ? AppTheme.profitColor.withOpacity(0.1)
                    : AppTheme.lossColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isProfit ? Icons.trending_up : Icons.trending_down,
                      color: isProfit ? AppTheme.profitColor : AppTheme.lossColor,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isProfit 
                        ? '+${user.returnRate.toStringAsFixed(2)}%'
                        : '${user.returnRate.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: isProfit ? AppTheme.profitColor : AppTheme.lossColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '현금',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_currencyFormat.format(user.currentCash.round())}원',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '투자자산',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_currencyFormat.format((user.totalAssets - user.currentCash).round())}원',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '수익금',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isProfit 
                          ? '+${_currencyFormat.format(user.totalReturn.round())}원'
                          : '${_currencyFormat.format(user.totalReturn.round())}원',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isProfit ? AppTheme.profitColor : AppTheme.lossColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    offset: const Offset(0, 2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  widget.onNavigateToUnescoTab?.call();
                },
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.profitColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.add,
                        color: AppTheme.profitColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '투자하기',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    offset: const Offset(0, 2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  print('매도하기 버튼 클릭 - 현재 포트폴리오: ${_priceService.portfolios.length}개'); // 디버깅용
                  _showSellDialog();
                },
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.lossColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.remove,
                        color: AppTheme.lossColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '매도하기',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetsList() {
    return StreamBuilder<List<Portfolio>>(
      stream: _priceService.portfolioStream,
      builder: (context, portfolioSnapshot) {
        if (!portfolioSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final portfolios = portfolioSnapshot.data!;
        final products = _priceService.products;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                offset: const Offset(0, 2),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '보유 자산',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              ...portfolios.take(3).map((portfolio) {
                final product = products.firstWhere(
                  (p) => p.id == portfolio.productId,
                  orElse: () => products.first,
                );
                final isProfit = portfolio.profitRate >= 0;
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(product.icon, style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '${portfolio.quantity.round()}개 • ${_currencyFormat.format(portfolio.currentValue.round())}원',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        isProfit 
                          ? '+${_currencyFormat.format(portfolio.profitLoss.round())}원'
                          : '${_currencyFormat.format(portfolio.profitLoss.round())}원',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isProfit ? AppTheme.profitColor : AppTheme.lossColor,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showSellDialog() {
    showDialog(
      context: context,
      builder: (context) => StreamBuilder<List<Portfolio>>(
        stream: _priceService.portfolioStream,
        builder: (context, portfolioSnapshot) {
          // 로딩 상태 처리
          if (!portfolioSnapshot.hasData) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('자산 매도'),
              content: const SizedBox(
                height: 100,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('보유 자산을 불러오는 중...'),
                    ],
                  ),
                ),
              ),
            );
          }

          final portfolios = portfolioSnapshot.data!;
          final products = _priceService.products;
          
          if (portfolios.isEmpty) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('자산 매도'),
              content: const Text('매도할 자산이 없습니다'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    '확인',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            );
          }
          
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('자산 매도'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('매도할 자산을 선택하세요'),
                const SizedBox(height: 16),
                ...portfolios.map((portfolio) {
                  final product = products.firstWhere(
                    (p) => p.id == portfolio.productId,
                    orElse: () => products.first,
                  );
                  final isProfit = portfolio.profitRate >= 0;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        _showSellAmountDialog(portfolio, product);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(product.icon, style: const TextStyle(fontSize: 20)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${_currencyFormat.format(portfolio.currentValue.round())}원',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              isProfit 
                                ? '+${_currencyFormat.format(portfolio.profitLoss.round())}원'
                                : '${_currencyFormat.format(portfolio.profitLoss.round())}원',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isProfit ? AppTheme.profitColor : AppTheme.lossColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  '취소',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSellAmountDialog(Portfolio portfolio, InvestmentProduct product) {
    final quantityController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => StreamBuilder<List<Portfolio>>(
        stream: _priceService.portfolioStream,
        builder: (context, portfolioSnapshot) {
          // 최신 포트폴리오 데이터 가져오기
          final currentPortfolios = portfolioSnapshot.data ?? [];
          final currentPortfolio = currentPortfolios.firstWhere(
            (p) => p.productId == portfolio.productId,
            orElse: () => portfolio,
          );
          
          // 매도할 자산이 더 이상 존재하지 않는 경우 다이얼로그 닫기
          if (currentPortfolio.quantity <= 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pop();
            });
            return const SizedBox.shrink();
          }
          
          return StatefulBuilder(
            builder: (context, setState) {
              // 매도 수량에 따른 총 매도 금액 계산
              final quantity = int.tryParse(quantityController.text) ?? 0;
              final totalSellAmount = quantity * product.currentPrice;
          
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text('${product.name} 매도'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('개당 가격', '${_currencyFormat.format(product.currentPrice.round())}원'),
                      const SizedBox(height: 8),
                      _buildDetailRow('보유 수량', '${currentPortfolio.quantity.round()}개'),
                      const SizedBox(height: 8),
                      _buildDetailRow('현재 가치', '${_currencyFormat.format(currentPortfolio.currentValue.round())}원'),
                      const SizedBox(height: 8),
                      _buildDetailRow('손익', 
                        currentPortfolio.profitLoss >= 0 
                          ? '+${_currencyFormat.format(currentPortfolio.profitLoss.round())}원'
                          : '${_currencyFormat.format(currentPortfolio.profitLoss.round())}원',
                        valueColor: currentPortfolio.profitLoss >= 0 ? AppTheme.profitColor : AppTheme.lossColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // 버튼식 수량 선택
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '매도 수량 선택',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                quantityController.text = '1';
                                setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: quantity == 1 ? AppTheme.lossColor : Colors.white,
                                foregroundColor: quantity == 1 ? Colors.white : Colors.grey[700],
                                side: BorderSide(color: Colors.grey[300]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('1개'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: currentPortfolio.quantity >= 5 ? () {
                                quantityController.text = '5';
                                setState(() {});
                              } : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: quantity == 5 ? AppTheme.lossColor : Colors.white,
                                foregroundColor: quantity == 5 ? Colors.white : Colors.grey[700],
                                side: BorderSide(color: Colors.grey[300]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('5개'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: currentPortfolio.quantity >= 10 ? () {
                                quantityController.text = '10';
                                setState(() {});
                              } : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: quantity == 10 ? AppTheme.lossColor : Colors.white,
                                foregroundColor: quantity == 10 ? Colors.white : Colors.grey[700],
                                side: BorderSide(color: Colors.grey[300]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('10개'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                quantityController.text = currentPortfolio.quantity.round().toString();
                                setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: quantity == currentPortfolio.quantity ? AppTheme.lossColor : Colors.white,
                                foregroundColor: quantity == currentPortfolio.quantity ? Colors.white : Colors.grey[700],
                                side: BorderSide(color: Colors.grey[300]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('전량'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {}); // 총 매도 금액 업데이트
                        },
                        decoration: InputDecoration(
                          labelText: '직접 입력',
                          hintText: '매도할 수량을 입력하세요',
                          prefixIcon: const Icon(Icons.edit),
                          suffixText: '개',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.lossColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (quantity > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.lossColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '총 매도 금액',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '${_currencyFormat.format(totalSellAmount.round())}원',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lossColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  '취소',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final quantity = int.tryParse(quantityController.text);
                  if (quantity == null || quantity <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('올바른 수량을 입력해주세요'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  if (quantity > currentPortfolio.quantity) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('보유 수량은 ${currentPortfolio.quantity.round()}개 입니다'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  Navigator.of(context).pop();
                  
                  final success = await _priceService.sellProduct(product.id, quantity.toDouble());
                  
                  if (success) {
                    final sellAmount = quantity * product.currentPrice;
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} ${quantity}개를 ${_currencyFormat.format(sellAmount.round())}원에 매도했습니다'),
                          backgroundColor: AppTheme.lossColor,
                        ),
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('매도에 실패했습니다'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lossColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('매도'),
              ),
            ],
            );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

}