import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../database/local_storage_service.dart';
import '../services/auth_service.dart';
import '../../features/home/data/repositories/portfolio_repository_impl.dart';
import '../../features/home/domain/repositories/portfolio_repository.dart';
import '../../features/home/presentation/bloc/portfolio_bloc.dart';
import '../../features/investment/data/repositories/investment_repository_impl.dart';
import '../../features/investment/domain/repositories/investment_repository.dart';
import '../../features/investment/presentation/bloc/investment_bloc.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Local Storage Service
  final localStorageService = LocalStorageService();
  await localStorageService.initialize();
  getIt.registerLazySingleton<LocalStorageService>(
    () => localStorageService,
  );

  // Auth Service
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(),
  );

  // Repositories
  getIt.registerLazySingleton<PortfolioRepository>(
    () => PortfolioRepositoryImpl(),
  );
  getIt.registerLazySingleton<InvestmentRepository>(
    () => InvestmentRepositoryImpl(),
  );

  // BLoCs
  getIt.registerFactory(() => PortfolioBloc(getIt()));
  getIt.registerFactory(() => InvestmentBloc(getIt()));
}
