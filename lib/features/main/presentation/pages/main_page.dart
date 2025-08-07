import 'package:flutter/material.dart';

import '../../../home/presentation/pages/home_page.dart';
import '../../../investment/presentation/pages/investment_page.dart';
import '../../../portfolio/presentation/pages/portfolio_page.dart';
import '../../../ranking/presentation/pages/ranking_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../unesco_board_game/presentation/pages/unesco_board_game_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(onNavigateToUnescoTab: () => _navigateToTab(1)),
      const UnescoBoardGamePage(),
      const InvestmentPage(),
      const PortfolioPage(),
      const RankingPage(),
      const SettingsPage(),
    ];
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '유네스코',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: '투자',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: '포트폴리오',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: '랭킹',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}
