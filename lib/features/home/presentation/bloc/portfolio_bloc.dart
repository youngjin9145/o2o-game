import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';

import '../../domain/repositories/portfolio_repository.dart';
import '../../../../core/services/price_simulation_service.dart';
import '../../../../core/models/user.dart';

// Events
abstract class PortfolioEvent extends Equatable {
  const PortfolioEvent();

  @override
  List<Object> get props => [];
}

class LoadPortfolio extends PortfolioEvent {}

class RefreshPortfolio extends PortfolioEvent {}

// States
abstract class PortfolioState extends Equatable {
  const PortfolioState();

  @override
  List<Object> get props => [];
}

class PortfolioInitial extends PortfolioState {}

class PortfolioLoading extends PortfolioState {}

class PortfolioLoaded extends PortfolioState {
  final double totalAssets;
  final double totalReturn;
  final double returnRate;

  const PortfolioLoaded({
    required this.totalAssets,
    required this.totalReturn,
    required this.returnRate,
  });

  @override
  List<Object> get props => [totalAssets, totalReturn, returnRate];
}

class PortfolioError extends PortfolioState {
  final String message;

  const PortfolioError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final PortfolioRepository repository;
  final PriceSimulationService _priceService = PriceSimulationService();
  StreamSubscription<User?>? _userSubscription;

  PortfolioBloc(this.repository) : super(PortfolioInitial()) {
    on<LoadPortfolio>(_onLoadPortfolio);
    on<RefreshPortfolio>(_onRefreshPortfolio);
    
    // 실시간 사용자 데이터 구독
    _userSubscription = _priceService.userStream.listen((user) {
      if (state is PortfolioLoaded && user != null) {
        emit(PortfolioLoaded(
          totalAssets: user.totalAssets,
          totalReturn: user.totalReturn,
          returnRate: user.returnRate,
        ));
      }
    });
  }

  Future<void> _onLoadPortfolio(
    LoadPortfolio event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(PortfolioLoading());
    try {
      // 실제 repository에서 데이터 가져오기
      final portfolioData = await repository.getPortfolioData();
      
      emit(PortfolioLoaded(
        totalAssets: portfolioData['totalAssets'] as double,
        totalReturn: portfolioData['totalReturn'] as double,
        returnRate: portfolioData['returnRate'] as double,
      ));
    } catch (e) {
      emit(PortfolioError(e.toString()));
    }
  }

  Future<void> _onRefreshPortfolio(
    RefreshPortfolio event,
    Emitter<PortfolioState> emit,
  ) async {
    try {
      final user = _priceService.currentUser;
      emit(PortfolioLoaded(
        totalAssets: user.totalAssets,
        totalReturn: user.totalReturn,
        returnRate: user.returnRate,
      ));
    } catch (e) {
      emit(PortfolioError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
