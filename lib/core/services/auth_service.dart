import 'dart:convert';
import 'dart:math';
import 'package:get_it/get_it.dart';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/supabase_service.dart';
import '../models/user.dart' as app_user;
import 'price_simulation_service.dart';

class AuthService {
  final SupabaseService _supabaseService = GetIt.instance<SupabaseService>();
  
  // Supabase 클라이언트 직접 사용
  SupabaseClient get _client => Supabase.instance.client;
  
  // 비밀번호 해싱 (실제 앱에서는 서버에서 처리)
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // UUID v4 생성
  String _generateUUID() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    
    // UUID v4 형식으로 변환
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // Version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // Variant bits
    
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }
  
  // 회원가입 (데이터베이스 직접 사용 - Supabase Auth 우회)
  Future<app_user.User?> signUp({
    required String username,
    required String displayName,
    required String password,
  }) async {
    try {
      final email = '$username@seogwipo.com';
      
      // UUID 생성 (Supabase는 UUID v4 형식 필요)
      final uuid = _generateUUID();
      
      final now = DateTime.now();
      final newUser = app_user.User(
        id: uuid,
        email: email,
        username: username,
        displayName: displayName,
        initialCash: 100000000.0, // 1억원
        currentCash: 100000000.0,
        totalAssets: 100000000.0,
        totalReturn: 0.0,
        returnRate: 0.0,
        createdAt: now,
        updatedAt: now,
        lastLogin: now,
      );
      
      // Supabase 데이터베이스에 사용자 정보 저장
      await _supabaseService.insertUser(newUser);
      
      // PriceSimulationService에 사용자 설정
      final priceService = PriceSimulationService();
      priceService.setUser(newUser);
      
      return newUser;
    } catch (e) {
      print('회원가입 오류: $e');
      return null;
    }
  }
  
  // 로그인 (데이터베이스 직접 사용 - Supabase Auth 우회)
  Future<app_user.User?> login({
    required String username,
    required String password,
  }) async {
    try {
      // 사용자명으로 직접 조회
      final user = await _supabaseService.getUserByUsername(username);
      
      if (user == null) {
        throw Exception('사용자를 찾을 수 없습니다.');
      }
      
      // 간단한 비밀번호 검증 (실제로는 해시 비교 필요)
      // 현재는 테스트를 위해 모든 비밀번호 허용
      
      // 마지막 로그인 시간 업데이트
      final updatedUser = user.copyWith(
        lastLogin: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Supabase에 업데이트
      await _supabaseService.updateUser(updatedUser);
      
      // PriceSimulationService에 사용자 설정
      final priceService = PriceSimulationService();
      priceService.setUser(updatedUser);
      
      return updatedUser;
    } catch (e) {
      print('로그인 오류: $e');
      return null;
    }
  }
  
  // 로그아웃
  Future<void> logout() async {
    // Supabase Auth 사용하지 않음
    // 단순히 상태만 초기화
  }
  
  // 현재 로그인된 사용자 가져오기 (세션 사용하지 않음)
  Future<app_user.User?> getCurrentUser() async {
    // 세션 관리 없이 null 반환
    return null;
  }
  
  // 로그인 상태 확인 (세션 사용하지 않음)
  bool isLoggedIn() {
    // 세션 관리 없이 항상 false
    return false;
  }
  
  // 데모 계정 생성
  Future<void> createDemoAccount() async {
    // 먼저 로그인 시도
    final loginResult = await login(
      username: 'demo',
      password: 'demo123',
    );
    
    // 로그인 실패시 새로 계정 생성
    if (loginResult == null) {
      await signUp(
        username: 'demo',
        displayName: '데모 사용자',
        password: 'demo123',
      );
    }
  }
}