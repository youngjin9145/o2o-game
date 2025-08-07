import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/main/presentation/pages/main_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    // Supabase Auth를 사용하지 않으므로 항상 로그인 페이지를 기본으로 함
    // 로그인 후에는 세션 관리 없이 메인 페이지로 이동
    
    final isLoggingIn = state.matchedLocation == '/login';
    final isSigningUp = state.matchedLocation == '/signup';
    final isMain = state.matchedLocation == '/';
    
    // 로그인/회원가입 페이지가 아니면 통과
    // (로그인 성공 후 메인 페이지로 이동 허용)
    if (isLoggingIn || isSigningUp || isMain) {
      return null;
    }
    
    // 그 외의 경우 로그인 페이지로
    return '/login';
  },
  routes: [
    GoRoute(
      path: '/',
      name: 'main',
      builder: (context, state) => const MainPage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupPage(),
    ),
  ],
);
