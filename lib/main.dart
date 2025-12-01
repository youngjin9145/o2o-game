import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/price_simulation_service.dart';
import 'core/services/auth_service.dart';
import 'features/home/presentation/bloc/portfolio_bloc.dart';
import 'features/investment/presentation/bloc/investment_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // DI 설정
  await configureDependencies();

  // 가격 시뮬레이션 서비스 초기화
  PriceSimulationService().initialize();

  // 게스트 사용자 자동 생성 및 게임 시작
  await _initializeGuestUser();

  runApp(const SeogwipoInvestmentApp());
}

Future<void> _initializeGuestUser() async {
  try {
    final authService = GetIt.instance<AuthService>();

    // 기존 로그인 사용자가 있는지 확인
    if (authService.isLoggedIn()) {
      final user = await authService.getCurrentUser();
      if (user != null) {
        PriceSimulationService().setUser(user);
        print('기존 사용자 복원: ${user.displayName}');
        return;
      }
    }

    // 로그인된 사용자가 없으면 게스트 사용자 생성
    final guestUser = await authService.createGuestUser();
    print('게임 시작: ${guestUser.displayName}');
  } catch (e) {
    print('사용자 초기화 실패: $e');
  }
}

class SeogwipoInvestmentApp extends StatelessWidget {
  const SeogwipoInvestmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GetIt.instance<PortfolioBloc>()),
        BlocProvider(create: (_) => GetIt.instance<InvestmentBloc>()),
      ],
      child: MaterialApp.router(
        title: '서귀포 투자 게임',
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ko', 'KR')],
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
