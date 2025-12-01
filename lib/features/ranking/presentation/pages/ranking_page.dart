import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/price_simulation_service.dart';
import '../../../../core/database/local_storage_service.dart';
import '../../../../core/models/user.dart' as app_user;

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  final PriceSimulationService _priceService = PriceSimulationService();
  final LocalStorageService _storageService = GetIt.instance<LocalStorageService>();
  final _currencyFormat = NumberFormat('#,###', 'ko_KR');
  List<app_user.User> _users = [];
  bool _isLoading = true;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _loadRankingData();
    _startAutoUpdate();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startAutoUpdate() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _loadRankingData();
      }
    });
  }

  Future<void> _loadRankingData() async {
    // 처음 로딩일 때만 로딩 상태 표시
    if (_users.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // 로컬 스토리지에서 모든 사용자 데이터 가져오기
      final allUsers = await _storageService.getAllUsers();

      if (allUsers.isNotEmpty) {
        // 총 자산 기준으로 정렬 (높은 순서대로)
        allUsers.sort((a, b) => b.totalAssets.compareTo(a.totalAssets));

        setState(() {
          _users = allUsers;
          _isLoading = false;
        });
      } else {
        // 로컬 스토리지에 사용자가 없는 경우 현재 사용자만 표시
        final currentUser = _priceService.currentUser;
        setState(() {
          _users = [currentUser];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('로컬 스토리지 랭킹 데이터 로드 실패: $e');

      // 에러 발생 시 현재 사용자만 표시
      if (_users.isEmpty) {
        final currentUser = _priceService.currentUser;
        setState(() {
          _users = [currentUser];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '투자자 랭킹',
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRankingData,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRankingData,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  final rank = index + 1;
                  final isCurrentUser = user.id == _priceService.currentUser.id;
                  
                  return _buildRankingCard(user, rank, isCurrentUser);
                },
              ),
            ),
    );
  }

  Widget _buildRankingCard(app_user.User user, int rank, bool isCurrentUser) {
    Color rankColor;
    IconData rankIcon;
    
    switch (rank) {
      case 1:
        rankColor = const Color(0xFFFFD700); // 금색
        rankIcon = Icons.emoji_events;
        break;
      case 2:
        rankColor = const Color(0xFFC0C0C0); // 은색
        rankIcon = Icons.emoji_events;
        break;
      case 3:
        rankColor = const Color(0xFFCD7F32); // 동색
        rankIcon = Icons.emoji_events;
        break;
      default:
        rankColor = Colors.grey[600]!;
        rankIcon = Icons.person;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppTheme.accentColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser 
          ? Border.all(color: AppTheme.accentColor, width: 2)
          : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 순위
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: rankColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: rankColor.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(rankIcon, color: rankColor, size: 20),
                  Text(
                    '$rank위',
                    style: TextStyle(
                      color: rankColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // 사용자 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isCurrentUser ? AppTheme.accentColor : Colors.black87,
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'ME',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${user.username}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Lv.${user.level}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.account_balance_wallet,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_currencyFormat.format(user.currentCash.round())}원',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 총 자산
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '총 자산',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_currencyFormat.format(user.totalAssets.round())}원',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '수익: ${user.totalReturn >= 0 ? '+' : ''}${_currencyFormat.format(user.totalReturn.round())}원',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: user.totalReturn >= 0 ? AppTheme.profitColor : AppTheme.lossColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}