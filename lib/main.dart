import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/price_simulation_service.dart';
import 'core/services/auth_service.dart';
import 'features/home/presentation/bloc/portfolio_bloc.dart';
import 'features/investment/presentation/bloc/investment_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 환경 변수 설정 (웹에서는 직접 하드코딩)
  String supabaseUrl = 'https://uzkqhrhgbxmhnocnolbb.supabase.co';
  String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV6a3FocmhnYnhtaG5vY25vbGJiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ1MDY0MjksImV4cCI6MjA3MDA4MjQyOX0.-pSc4RNntAQK4Y32kykMtXpY8i7Yb8XzRaWw67nFTf8';
  
  // .env 파일이 있다면 로드 시도
  try {
    await dotenv.load(fileName: ".env");
    supabaseUrl = dotenv.env['SUPABASE_URL'] ?? supabaseUrl;
    supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? supabaseAnonKey;
    print('환경 파일 로드 성공');
  } catch (e) {
    print('환경 파일 로드 실패, 기본값 사용: $e');
  }
  
  // Supabase 초기화
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  
  await configureDependencies();
  
  // 가격 시뮬레이션 서비스 초기화
  PriceSimulationService().initialize();
  
  // 기존 로그인 사용자가 있다면 PriceSimulationService에 설정
  await _initializeExistingUser();
  
  runApp(const SeogwipoInvestmentApp());
}

Future<void> _initializeExistingUser() async {
  try {
    final authService = GetIt.instance<AuthService>();
    if (authService.isLoggedIn()) {
      final user = await authService.getCurrentUser();
      if (user != null) {
        PriceSimulationService().setUser(user);
      }
    }
  } catch (e) {
    print('기존 사용자 초기화 실패: $e');
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
