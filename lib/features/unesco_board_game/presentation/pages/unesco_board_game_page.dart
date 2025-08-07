import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/price_simulation_service.dart';
import '../../../../core/models/portfolio.dart';
import '../../../investment/domain/entities/investment_product.dart';

class UnescoBoardGamePage extends StatefulWidget {
  const UnescoBoardGamePage({super.key});

  @override
  State<UnescoBoardGamePage> createState() => _UnescoBoardGamePageState();
}

class _UnescoBoardGamePageState extends State<UnescoBoardGamePage> {
  final PriceSimulationService _priceService = PriceSimulationService();
  final _currencyFormat = NumberFormat('#,###', 'ko_KR');
  String selectedCategory = '자연유산';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '유네스코 부루마불',
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
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildCategorySelector(),
          Expanded(
            child: _buildSelectedContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ['자연유산', '세계기록유산', '문화유산'].map((category) {
          final isSelected = selectedCategory == category;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = category;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      offset: const Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ] : null,
                ),
                child: Text(
                  category,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.black87 : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSelectedContent() {
    switch (selectedCategory) {
      case '자연유산':
        return _buildNaturalHeritageTab();
      case '세계기록유산':
        return _buildMemoryHeritageTab();
      case '문화유산':
        return _buildCulturalHeritageTab();
      default:
        return _buildNaturalHeritageTab();
    }
  }

  Widget _buildNaturalHeritageTab() {
    return StreamBuilder<List<InvestmentProduct>>(
      stream: _priceService.productsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!;
        final unescoProducts = products
            .where((p) => p.isUnescoHeritage && p.subType == 'natural_heritage')
            .toList();

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
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
                    Text(
                      '🌍 세계자연유산 투자',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '제주도의 자연유산에 투자하여 수익을 창출하세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ...unescoProducts.map((product) => _buildRealTimeProduct(product)),
              const SizedBox(height: 20), // 하단 여백
            ],
          ),
        );
      },
    );
  }

  Widget _buildMemoryHeritageTab() {
    return StreamBuilder<List<InvestmentProduct>>(
      stream: _priceService.productsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!;
        final memoryProducts = products
            .where((p) => p.isUnescoHeritage && p.subType == 'memory_heritage')
            .toList();

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
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
                    Text(
                      '📜 세계기록유산',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '대한민국의 소중한 기록유산에 투자하세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ...memoryProducts.map((product) => _buildRealTimeProduct(product)),
              const SizedBox(height: 20), // 하단 여백
            ],
          ),
        );
      },
    );
  }

  Widget _buildCulturalHeritageTab() {
    return StreamBuilder<List<InvestmentProduct>>(
      stream: _priceService.productsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!;
        final culturalProducts = products
            .where((p) => p.isUnescoHeritage && p.subType == 'cultural_heritage')
            .toList();

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
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
                    Text(
                      '🏛️ 세계문화유산',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '대한민국의 아름다운 문화유산에 투자하세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ...culturalProducts.map((product) => _buildRealTimeProduct(product)),
              const SizedBox(height: 20), // 하단 여백
            ],
          ),
        );
      },
    );
  }

  Widget _buildRealTimeProduct(InvestmentProduct product) {
    final changeRate = ((product.currentPrice - product.basePrice) / product.basePrice * 100);
    final isProfit = changeRate >= 0;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
      child: InkWell(
        onTap: () => _showPurchaseDialog(product),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
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
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.description ?? '제주 유네스코 세계유산',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${_currencyFormat.format(product.currentPrice.round())}원',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isProfit 
                            ? AppTheme.profitColor.withOpacity(0.1)
                            : AppTheme.lossColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isProfit
                              ? '+${changeRate.toStringAsFixed(2)}%'
                              : '${changeRate.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: isProfit
                                ? AppTheme.profitColor
                                : AppTheme.lossColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showPurchaseDialog(product);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '구매하기',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showPurchaseDialog(InvestmentProduct product) {
    final changeRate = ((product.currentPrice - product.basePrice) / product.basePrice * 100);
    final isProfit = changeRate >= 0;
    
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildDetailRow('현재 가격', '${_currencyFormat.format(product.currentPrice.round())}원'),
                  const SizedBox(height: 8),
                  _buildDetailRow('카테고리', product.category),
                  const SizedBox(height: 8),
                  _buildDetailRow('변동률', 
                    isProfit 
                      ? '+${changeRate.toStringAsFixed(2)}%'
                      : '${changeRate.toStringAsFixed(2)}%',
                    valueColor: isProfit ? AppTheme.profitColor : AppTheme.lossColor,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('유형', '🏛️ 유네스코 세계문화유산', valueColor: Colors.blue[700]),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            if (product.description != null) ...[
              Text(
                product.description!,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            
            const Text(
              '구매하시겠습니까?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
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
            onPressed: () {
              Navigator.of(context).pop();
              _showBuyAmountDialog(product);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('구매'),
          ),
        ],
      ),
    );
  }

  void _showBuyAmountDialog(InvestmentProduct product) {
    final quantityController = TextEditingController();
    final user = _priceService.currentUser;
    final maxShares = (user.currentCash / product.currentPrice).floor();
    
    print('유네스코 구매: ${product.name}, 현금: ${user.currentCash}, 가격: ${product.currentPrice}, 최대구매: ${maxShares}');
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // 총 금액 계산
          final quantity = int.tryParse(quantityController.text) ?? 0;
          final totalAmount = quantity * product.currentPrice;
          
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text('${product.name} 구매'),
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
                      _buildDetailRow('주당 가격', '${_currencyFormat.format(product.currentPrice.round())}원'),
                      const SizedBox(height: 8),
                      _buildDetailRow('구매 가능', '최대 ${maxShares}주'),
                      const SizedBox(height: 8),
                      _buildDetailRow('보유 현금', '${_currencyFormat.format(user.currentCash.round())}원'),
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
                        '구매 수량 선택',
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
                                backgroundColor: quantity == 1 ? AppTheme.accentColor : Colors.white,
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
                              onPressed: maxShares >= 5 ? () {
                                quantityController.text = '5';
                                setState(() {});
                              } : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: quantity == 5 ? AppTheme.accentColor : Colors.white,
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
                              onPressed: maxShares >= 10 ? () {
                                quantityController.text = '10';
                                setState(() {});
                              } : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: quantity == 10 ? AppTheme.accentColor : Colors.white,
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
                              onPressed: maxShares > 0 ? () {
                                quantityController.text = maxShares.toString();
                                setState(() {});
                              } : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: quantity == maxShares ? AppTheme.accentColor : Colors.white,
                                foregroundColor: quantity == maxShares ? Colors.white : Colors.grey[700],
                                side: BorderSide(color: Colors.grey[300]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('최대'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {}); // 총 금액 업데이트
                        },
                        decoration: InputDecoration(
                          labelText: '직접 입력',
                          hintText: '구매할 수량을 입력하세요',
                          prefixIcon: const Icon(Icons.edit),
                          suffixText: '개',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.accentColor,
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
                      color: AppTheme.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '총 구매 금액',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '${_currencyFormat.format(totalAmount.round())}원',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accentColor,
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
                  
                  if (quantity > maxShares) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('구매 가능 수량은 최대 ${maxShares}개 입니다'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  final totalCost = quantity * product.currentPrice;
                  
                  // 다이얼로그를 닫기 전에 상위 context를 저장
                  final scaffoldContext = ScaffoldMessenger.of(context);
                  Navigator.of(context).pop();
                  
                  final success = await _priceService.buyProduct(product.id, quantity.toDouble(), immediatePortfolioUpdate: true);
                  
                  if (success) {
                    scaffoldContext.showSnackBar(
                      SnackBar(
                        content: Text('${product.name} ${quantity}개를 ${_currencyFormat.format(totalCost.round())}원에 구매했습니다'),
                        backgroundColor: AppTheme.profitColor,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  } else {
                    scaffoldContext.showSnackBar(
                      const SnackBar(
                        content: Text('구매에 실패했습니다'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.profitColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('구매'),
              ),
            ],
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