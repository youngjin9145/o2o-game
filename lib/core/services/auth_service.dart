import 'dart:math';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import '../database/local_storage_service.dart';
import '../models/user.dart' as app_user;
import 'price_simulation_service.dart';

class AuthService {
  final LocalStorageService _storageService = GetIt.instance<LocalStorageService>();
  final _uuid = const Uuid();

  // 임시 사용자 생성 (자동으로 게임 시작)
  Future<app_user.User> createGuestUser() async {
    final guestNumber = Random().nextInt(9999) + 1;
    final username = 'guest_$guestNumber';
    final displayName = '게스트 $guestNumber';

    final now = DateTime.now();
    final newUser = app_user.User(
      id: _uuid.v4(),
      email: '$username@seogwipo.com',
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

    // 로컬 스토리지에 사용자 정보 저장
    await _storageService.insertUser(newUser);
    await _storageService.setCurrentUserId(newUser.id);

    // PriceSimulationService에 사용자 설정
    final priceService = PriceSimulationService();
    priceService.setUser(newUser);

    print('게스트 사용자 생성: ${newUser.displayName}');
    return newUser;
  }

  // 회원가입 (로컬 스토리지 사용)
  Future<app_user.User?> signUp({
    required String username,
    required String displayName,
    required String password,
  }) async {
    try {
      final email = '$username@seogwipo.com';

      // 중복 확인
      final existingUser = await _storageService.getUserByUsername(username);
      if (existingUser != null) {
        print('이미 존재하는 사용자명입니다.');
        return null;
      }

      final now = DateTime.now();
      final newUser = app_user.User(
        id: _uuid.v4(),
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

      // 로컬 스토리지에 사용자 정보 저장
      await _storageService.insertUser(newUser);
      await _storageService.setCurrentUserId(newUser.id);

      // PriceSimulationService에 사용자 설정
      final priceService = PriceSimulationService();
      priceService.setUser(newUser);

      return newUser;
    } catch (e) {
      print('회원가입 오류: $e');
      return null;
    }
  }

  // 로그인 (로컬 스토리지 사용)
  Future<app_user.User?> login({
    required String username,
    required String password,
  }) async {
    try {
      // 사용자명으로 직접 조회
      final user = await _storageService.getUserByUsername(username);

      if (user == null) {
        throw Exception('사용자를 찾을 수 없습니다.');
      }

      // 간단한 비밀번호 검증 (테스트를 위해 모든 비밀번호 허용)

      // 마지막 로그인 시간 업데이트
      final updatedUser = user.copyWith(
        lastLogin: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 로컬 스토리지에 업데이트
      await _storageService.updateUser(updatedUser);
      await _storageService.setCurrentUserId(updatedUser.id);

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
    await _storageService.clearCurrentUserId();
  }

  // 현재 로그인된 사용자 가져오기
  Future<app_user.User?> getCurrentUser() async {
    try {
      final userId = _storageService.getCurrentUserId();
      if (userId == null) {
        return null;
      }
      return await _storageService.getUserById(userId);
    } catch (e) {
      print('현재 사용자 조회 오류: $e');
      return null;
    }
  }

  // 로그인 상태 확인
  bool isLoggedIn() {
    return _storageService.getCurrentUserId() != null;
  }
}