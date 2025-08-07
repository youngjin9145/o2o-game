import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/price_simulation_service.dart';
import '../../domain/entities/investment_product.dart';
import '../bloc/investment_bloc.dart';

class InvestmentPage extends StatefulWidget {
  const InvestmentPage({super.key});

  @override
  State<InvestmentPage> createState() => _InvestmentPageState();
}

class _InvestmentPageState extends State<InvestmentPage> {
  final PriceSimulationService _priceService = PriceSimulationService();
  final _currencyFormat = NumberFormat('#,###', 'ko_KR');
  String selectedTab = '직접투자';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '투자',
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
          _buildTabSelector(),
          Expanded(
            child: _buildSelectedContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ['직접투자', '간접투자'].map((tab) {
          final isSelected = selectedTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedTab = tab;
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
                  tab,
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
    switch (selectedTab) {
      case '직접투자':
        return _buildDirectInvestmentTab();
      case '간접투자':
        return _buildIndirectInvestmentTab();
      default:
        return _buildDirectInvestmentTab();
    }
  }

  Widget _buildDirectInvestmentTab() {
    return StreamBuilder<List<InvestmentProduct>>(
      stream: _priceService.productsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!;
        final stocks = products.where((p) => p.category == '주식').toList();
        final bonds = products.where((p) => p.category == '채권').toList();
        final crypto = products.where((p) => p.category == '가상자산').toList();
        final realEstate = products.where((p) => p.category == '부동산').toList();

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              if (stocks.isNotEmpty) 
                _buildCategorySection('📈 주식', stocks, Colors.green[700]!),
              
              if (crypto.isNotEmpty) 
                _buildCategorySection('₿ 가상자산', crypto, Colors.orange[700]!),
              
              if (bonds.isNotEmpty) 
                _buildCategorySection('💰 채권', bonds, Colors.purple[700]!),
              
              if (realEstate.isNotEmpty) 
                _buildCategorySection('🏢 부동산', realEstate, Colors.brown[700]!),
              
              const SizedBox(height: 20), // 하단 여백
            ],
          ),
        );
      },
    );
  }

  Widget _buildIndirectInvestmentTab() {
    return StreamBuilder<List<InvestmentProduct>>(
      stream: _priceService.productsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!;
        final etfs = products.where((p) => p.category == 'ETF').toList();
        final funds = products.where((p) => p.category == '펀드').toList();

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              if (etfs.isNotEmpty) 
                _buildCategorySection('📊 ETF', etfs, Colors.indigo[700]!),
              
              if (funds.isNotEmpty) 
                _buildCategorySection('🏛️ 뮤추얼 펀드', funds, Colors.teal[700]!),
              
              const SizedBox(height: 20), // 하단 여백
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategorySection(String title, List<InvestmentProduct> products, Color titleColor) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '${products.length}개',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ...products.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;
            
            return Column(
              children: [
                if (index > 0) 
                  Divider(height: 1, color: Colors.grey[100]),
                _buildRealTimeProduct(product),
              ],
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRealTimeProduct(InvestmentProduct product) {
    final changeRate = ((product.currentPrice - product.basePrice) / product.basePrice * 100);
    final isProfit = changeRate >= 0;
    
    return InkWell(
      onTap: () => _showPurchaseDialog(product),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                        product.description ?? product.category,
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
                onPressed: () => _showPurchaseDialog(product),
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
                  if (product.isUnescoHeritage) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow('유형', '🏛️ 유네스코 세계문화유산', valueColor: Colors.blue[700]),
                  ],
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
    final maxQuantity = (user.currentCash / product.currentPrice).floor();
    
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
                      _buildDetailRow('개당 가격', '${_currencyFormat.format(product.currentPrice.round())}원'),
                      const SizedBox(height: 8),
                      _buildDetailRow('구매 가능', '최대 ${maxQuantity}개'),
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
                              onPressed: maxQuantity >= 5 ? () {
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
                              onPressed: maxQuantity >= 10 ? () {
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
                              onPressed: maxQuantity > 0 ? () {
                                quantityController.text = maxQuantity.toString();
                                setState(() {});
                              } : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: quantity == maxQuantity ? AppTheme.accentColor : Colors.white,
                                foregroundColor: quantity == maxQuantity ? Colors.white : Colors.grey[700],
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
                  
                  if (quantity > maxQuantity) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('구매 가능 수량은 최대 ${maxQuantity}개 입니다'),
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

  String _getUnit(String productType) {
    // 모든 상품을 "개" 단위로 통일
    return '개';
  }

  String _getUnitName(String productType) {
    // 모든 상품을 "개당"으로 통일
    return '개당';
  }
}