import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/price_simulation_service.dart';
import '../../../../core/models/portfolio.dart';
import '../../../../core/models/user.dart';
import '../../../../core/models/trade_record.dart';
import '../../../investment/domain/entities/investment_product.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final PriceSimulationService _priceService = PriceSimulationService();
  final _currencyFormat = NumberFormat('#,###', 'ko_KR');
  String selectedFilter = '전체';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '포트폴리오',
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
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedFilter,
                icon: Icon(Icons.expand_more, color: Colors.grey[600], size: 20),
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (value) {
                  setState(() {
                    selectedFilter = value!;
                  });
                },
                items: const [
                  DropdownMenuItem(value: '전체', child: Text('전체')),
                  DropdownMenuItem(value: '유네스코', child: Text('유네스코')),
                  DropdownMenuItem(value: '주식', child: Text('주식')),
                  DropdownMenuItem(value: '가상자산', child: Text('가상자산')),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _buildCompletedTradesTab(),
    );
  }

  Widget _buildCompletedTradesTab() {
    return StreamBuilder<List<TradeRecord>>(
      stream: _priceService.tradeRecordsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allTradeRecords = snapshot.data!;
        
        // 매도 거래만 필터링
        final completedTrades = allTradeRecords.where((record) => record.tradeType == 'sell').toList();
        
        if (completedTrades.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.trending_down_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  '거래 기록이 없습니다',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '매수한 자산을 매도하면 여기에 표시됩니다',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        // 날짜 역순으로 정렬
        completedTrades.sort((a, b) => b.tradeDate.compareTo(a.tradeDate));

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: completedTrades.length,
          itemBuilder: (context, index) {
            final record = completedTrades[index];
            return _buildCompletedTradeCard(record);
          },
        );
      },
    );
  }

  Widget _buildCompletedTradeCard(TradeRecord record) {
    final dateFormat = DateFormat('M/d HH:mm');
    final hasProfit = record.profit != null && record.profitRate != null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(record.productIcon, style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              Text(
                '${dateFormat.format(record.tradeDate)}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '매도 수량',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${record.quantity.round()}개',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '구매가',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${_currencyFormat.format(_calculatePurchasePrice(record).round())}원',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '매도금액',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${_currencyFormat.format(record.totalAmount.round())}원',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (hasProfit) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (record.profit! >= 0 ? AppTheme.profitColor : AppTheme.lossColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '실현 손익',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${record.profit! >= 0 ? '+' : ''}${_currencyFormat.format(record.profit!.round())}원',
                        style: TextStyle(
                          color: record.profit! >= 0 ? AppTheme.profitColor : AppTheme.lossColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '수익률: ${record.profitRate! >= 0 ? '+' : ''}${record.profitRate!.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: record.profit! >= 0 ? AppTheme.profitColor : AppTheme.lossColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 전체기록 탭 삭제됨

  String _getQuantityUnit(String productType) {
    // 모든 상품을 "개" 단위로 통일
    return '개';
  }

  Widget _buildPortfolioSummary(User user) {
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
                    '총 투자자산',
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
                        '투자금액',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_currencyFormat.format((user.totalAssets - user.totalReturn).round())}원',
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
                        '수익금액',
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
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[700],
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '매매 기록은 전체기록 탭에서 확인하실 수 있습니다',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioList(List<Portfolio> portfolios, List<InvestmentProduct> products) {
    // 필터링
    List<Portfolio> filteredPortfolios = portfolios;
    if (selectedFilter != '전체') {
      filteredPortfolios = portfolios.where((portfolio) {
        final product = products.firstWhere(
          (p) => p.id == portfolio.productId,
          orElse: () => products.first,
        );
        return product.category == selectedFilter;
      }).toList();
    }

    // 수익률순 정렬
    filteredPortfolios.sort((a, b) => b.profitRate.compareTo(a.profitRate));

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
            child: Row(
              children: [
                Text(
                  '보유 종목',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                Text(
                  '${filteredPortfolios.length}개',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ...filteredPortfolios.asMap().entries.map((entry) {
            final index = entry.key;
            final portfolio = entry.value;
            final product = products.firstWhere(
              (p) => p.id == portfolio.productId,
              orElse: () => products.first,
            );
            
            return Column(
              children: [
                if (index > 0) 
                  Divider(height: 1, color: Colors.grey[100]),
                _buildPortfolioItem(portfolio, product),
              ],
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPortfolioItem(Portfolio portfolio, InvestmentProduct product) {
    final isProfit = portfolio.profitRate >= 0;
    
    return InkWell(
      onTap: () => _showDetailDialog(portfolio, product),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  product.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        isProfit 
                          ? '+${portfolio.profitRate.toStringAsFixed(2)}%'
                          : '${portfolio.profitRate.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isProfit ? AppTheme.profitColor : AppTheme.lossColor,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        isProfit 
                          ? '+${_currencyFormat.format(portfolio.profitLoss.round())}원'
                          : '${_currencyFormat.format(portfolio.profitLoss.round())}원',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isProfit ? AppTheme.profitColor : AppTheme.lossColor,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 2),
                  
                  Row(
                    children: [
                      Text(
                        '${portfolio.quantity.round()}개',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_currencyFormat.format(portfolio.currentValue.round())}원',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(Portfolio portfolio, InvestmentProduct product) {
    final isProfit = portfolio.profitRate >= 0;
    final expectedProfitPerShare = product.currentPrice - portfolio.averagePrice;
    final expectedProfitRate = ((product.currentPrice - portfolio.averagePrice) / portfolio.averagePrice) * 100;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  product.icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('보유 수량', '${portfolio.quantity.round()}개'),
            _buildDetailRow('평균 매수가', '${_currencyFormat.format(portfolio.averagePrice.round())}원'),
            _buildDetailRow('현재 단가', '${_currencyFormat.format(product.currentPrice.round())}원'),
            _buildDetailRow('투자 금액', '${_currencyFormat.format(portfolio.totalInvestment.round())}원'),
            _buildDetailRow('현재 가치', '${_currencyFormat.format(portfolio.currentValue.round())}원'),
            const Divider(height: 20),
            
            // 매도 시 예상 수익 정보
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '매도 시 예상 수익 (전량 매도 기준)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '주당 손익',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${expectedProfitPerShare >= 0 ? '+' : ''}${_currencyFormat.format(expectedProfitPerShare.round())}원',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: expectedProfitPerShare >= 0 ? AppTheme.profitColor : AppTheme.lossColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '수익률',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${expectedProfitRate >= 0 ? '+' : ''}${expectedProfitRate.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: expectedProfitRate >= 0 ? AppTheme.profitColor : AppTheme.lossColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '현재 손익',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isProfit 
                        ? '+${_currencyFormat.format(portfolio.profitLoss.round())}원'
                        : '${_currencyFormat.format(portfolio.profitLoss.round())}원',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isProfit ? AppTheme.profitColor : AppTheme.lossColor,
                      ),
                    ),
                    Text(
                      isProfit 
                        ? '+${portfolio.profitRate.toStringAsFixed(2)}%'
                        : '${portfolio.profitRate.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isProfit ? AppTheme.profitColor : AppTheme.lossColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '닫기',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSellDialog(portfolio, product);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lossColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('매도하기'),
          ),
        ],
      ),
    );
  }

  void _showSellDialog(Portfolio portfolio, InvestmentProduct product) {
    final quantityController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final quantity = double.tryParse(quantityController.text) ?? 0;
          final sellAmount = quantity * product.currentPrice;
          final profitFromSale = (product.currentPrice - portfolio.averagePrice) * quantity;
          final profitRateFromSale = portfolio.averagePrice > 0 
            ? ((product.currentPrice - portfolio.averagePrice) / portfolio.averagePrice) * 100 
            : 0.0;
          
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
                      _buildDetailRow('보유 수량', '${portfolio.quantity.round()}개'),
                      const SizedBox(height: 8),
                      _buildDetailRow('평균 매수가', '${_currencyFormat.format(portfolio.averagePrice.round())}원'),
                      const SizedBox(height: 8),
                      _buildDetailRow('현재 단가', '${_currencyFormat.format(product.currentPrice.round())}원'),
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
                              onPressed: portfolio.quantity >= 5 ? () {
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
                              onPressed: portfolio.quantity >= 10 ? () {
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
                                quantityController.text = portfolio.quantity.round().toString();
                                setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: quantity == portfolio.quantity ? AppTheme.lossColor : Colors.white,
                                foregroundColor: quantity == portfolio.quantity ? Colors.white : Colors.grey[700],
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
                          setState(() {}); // UI 업데이트
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
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: profitFromSale >= 0 
                        ? AppTheme.profitColor.withOpacity(0.1)
                        : AppTheme.lossColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: profitFromSale >= 0 
                          ? AppTheme.profitColor.withOpacity(0.3)
                          : AppTheme.lossColor.withOpacity(0.3)
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '매도 금액',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              '${_currencyFormat.format(sellAmount.round())}원',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '예상 손익',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${profitFromSale >= 0 ? '+' : ''}${_currencyFormat.format(profitFromSale.round())}원',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: profitFromSale >= 0 ? AppTheme.profitColor : AppTheme.lossColor,
                                  ),
                                ),
                                Text(
                                  '${profitRateFromSale >= 0 ? '+' : ''}${profitRateFromSale.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: profitFromSale >= 0 ? AppTheme.profitColor : AppTheme.lossColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
                onPressed: quantity > 0 ? () async {
                  final quantity = double.tryParse(quantityController.text);
                  if (quantity == null || quantity <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('올바른 수량을 입력해주세요'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (quantity > portfolio.quantity) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('보유 수량은 ${portfolio.quantity.round()}개입니다'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final profitFromSale = (product.currentPrice - portfolio.averagePrice) * quantity;
                  final profitRate = ((product.currentPrice - portfolio.averagePrice) / portfolio.averagePrice) * 100;
                  
                  Navigator.of(context).pop();
                  final success = await _priceService.sellProduct(product.id, quantity);

                  if (success) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${product.name} ${quantity.round()}개 매도완료\n'
                            '손익: ${profitFromSale >= 0 ? '+' : ''}${_currencyFormat.format(profitFromSale.round())}원 '
                            '(${profitRate >= 0 ? '+' : ''}${profitRate.toStringAsFixed(2)}%)'
                          ),
                          backgroundColor: profitFromSale >= 0 ? AppTheme.profitColor : AppTheme.lossColor,
                          duration: const Duration(seconds: 4),
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
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lossColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('매도하기'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 매도 기록에서 평균 구매가를 계산하는 메서드
  double _calculatePurchasePrice(TradeRecord record) {
    if (record.averagePrice != null) {
      return record.averagePrice!;
    }
    
    // averagePrice가 null인 경우, 수익과 매도가에서 역산
    if (record.profit != null && record.profit != 0) {
      // 매도가 - (수익 / 수량) = 구매가
      return record.price - (record.profit! / record.quantity);
    }
    
    // 수익 정보가 없는 경우 매도가를 그대로 표시
    return record.price;
  }
}
