import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  String selectedProduct = '한라산 천연보호구역';
  String selectedPeriod = '월간';
  bool showComparison = false;

  final List<String> products = [
    '한라산 천연보호구역',
    '성산일출봉',
    '거문오름 용암동굴계',
    'APPLE',
    'Bitcoin',
    'SPY ETF',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('차트 분석'),
        actions: [
          IconButton(
            icon: Icon(
              showComparison ? Icons.compare_arrows : Icons.show_chart,
              color: AppTheme.accentColor,
            ),
            onPressed: () {
              setState(() {
                showComparison = !showComparison;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 상품 선택
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedProduct,
                    decoration: const InputDecoration(
                      labelText: '투자 상품',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedProduct = value!;
                      });
                    },
                    items: products.map((product) {
                      return DropdownMenuItem(
                        value: product,
                        child: Text(product),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 100,
                  child: DropdownButtonFormField<String>(
                    value: selectedPeriod,
                    decoration: const InputDecoration(
                      labelText: '기간',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedPeriod = value!;
                      });
                    },
                    items: const [
                      DropdownMenuItem(value: '일간', child: Text('일간')),
                      DropdownMenuItem(value: '주간', child: Text('주간')),
                      DropdownMenuItem(value: '월간', child: Text('월간')),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 차트 영역
          Expanded(
            child:
                showComparison ? _buildComparisonChart() : _buildSingleChart(),
          ),

          // 기술적 지표
          if (!showComparison) _buildTechnicalIndicators(),
        ],
      ),
    );
  }

  Widget _buildSingleChart() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedProduct,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '+12.5%',
                  style: TextStyle(
                    color: AppTheme.profitColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 1,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          );
                          Widget text;
                          switch (value.toInt()) {
                            case 1:
                              text = const Text('1월', style: style);
                              break;
                            case 2:
                              text = const Text('2월', style: style);
                              break;
                            case 3:
                              text = const Text('3월', style: style);
                              break;
                            case 4:
                              text = const Text('4월', style: style);
                              break;
                            case 5:
                              text = const Text('5월', style: style);
                              break;
                            case 6:
                              text = const Text('6월', style: style);
                              break;
                            default:
                              text = const Text('', style: style);
                              break;
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: text,
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          );
                        },
                        reservedSize: 42,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xff37434d)),
                  ),
                  minX: 0,
                  maxX: 6,
                  minY: -5,
                  maxY: 20,
                  lineBarsData: [
                    // 메인 수익률 라인
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 0),
                        FlSpot(1, 3),
                        FlSpot(2, 1.5),
                        FlSpot(3, 7),
                        FlSpot(4, 5),
                        FlSpot(5, 12.5),
                        FlSpot(6, 15),
                      ],
                      isCurved: true,
                      color: AppTheme.profitColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppTheme.profitColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.profitColor.withOpacity(0.1),
                      ),
                    ),
                    // 이동평균선
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 0),
                        FlSpot(1, 2),
                        FlSpot(2, 3),
                        FlSpot(3, 5),
                        FlSpot(4, 7),
                        FlSpot(5, 9),
                        FlSpot(6, 11),
                      ],
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      dashArray: [5, 5],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonChart() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '수익률 비교',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // 범례
            Wrap(
              spacing: 16,
              children: [
                _buildLegendItem('한라산', AppTheme.profitColor),
                _buildLegendItem('성산일출봉', Colors.blue),
                _buildLegendItem('APPLE', Colors.green),
                _buildLegendItem('Bitcoin', Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    // 한라산
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 0),
                        FlSpot(1, 3),
                        FlSpot(2, 1.5),
                        FlSpot(3, 7),
                        FlSpot(4, 5),
                        FlSpot(5, 12.5),
                      ],
                      isCurved: true,
                      color: AppTheme.profitColor,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                    // 성산일출봉
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 0),
                        FlSpot(1, 2),
                        FlSpot(2, 4),
                        FlSpot(3, 3),
                        FlSpot(4, 6),
                        FlSpot(5, 8.2),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                    // APPLE
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 0),
                        FlSpot(1, 1),
                        FlSpot(2, -1),
                        FlSpot(3, 2),
                        FlSpot(4, 1.5),
                        FlSpot(5, 2.1),
                      ],
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                    // Bitcoin
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 0),
                        FlSpot(1, 10),
                        FlSpot(2, 5),
                        FlSpot(3, 15),
                        FlSpot(4, 20),
                        FlSpot(5, 24.5),
                      ],
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String name, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(name, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTechnicalIndicators() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '기술적 지표',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildIndicatorCard('RSI', '68.5', '중립'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildIndicatorCard('MACD', '+0.25', '매수'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildIndicatorCard('볼린저밴드', '상단근접', '관망'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorCard(String name, String value, String signal) {
    Color signalColor;
    switch (signal) {
      case '매수':
        signalColor = AppTheme.profitColor;
        break;
      case '매도':
        signalColor = AppTheme.lossColor;
        break;
      default:
        signalColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            signal,
            style: TextStyle(
              color: signalColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
