import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/repositories/investment_repository.dart';

// Events
abstract class InvestmentEvent extends Equatable {
  const InvestmentEvent();

  @override
  List<Object> get props => [];
}

class LoadInvestmentProducts extends InvestmentEvent {}

class PurchaseProduct extends InvestmentEvent {
  final String productId;
  final double amount;

  const PurchaseProduct(this.productId, this.amount);

  @override
  List<Object> get props => [productId, amount];
}

// States
abstract class InvestmentState extends Equatable {
  const InvestmentState();

  @override
  List<Object> get props => [];
}

class InvestmentInitial extends InvestmentState {}

class InvestmentLoading extends InvestmentState {}

class InvestmentLoaded extends InvestmentState {
  final List<Map<String, dynamic>> products;

  const InvestmentLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class InvestmentError extends InvestmentState {
  final String message;

  const InvestmentError(this.message);

  @override
  List<Object> get props => [message];
}

class PurchaseSuccess extends InvestmentState {
  final String productName;

  const PurchaseSuccess(this.productName);

  @override
  List<Object> get props => [productName];
}

// BLoC
class InvestmentBloc extends Bloc<InvestmentEvent, InvestmentState> {
  final InvestmentRepository repository;

  InvestmentBloc(this.repository) : super(InvestmentInitial()) {
    on<LoadInvestmentProducts>(_onLoadInvestmentProducts);
    on<PurchaseProduct>(_onPurchaseProduct);
  }

  Future<void> _onLoadInvestmentProducts(
    LoadInvestmentProducts event,
    Emitter<InvestmentState> emit,
  ) async {
    emit(InvestmentLoading());
    try {
      final products = await repository.getInvestmentProducts();
      emit(InvestmentLoaded(products));
    } catch (e) {
      emit(InvestmentError(e.toString()));
    }
  }

  Future<void> _onPurchaseProduct(
    PurchaseProduct event,
    Emitter<InvestmentState> emit,
  ) async {
    try {
      await repository.purchaseProduct(event.productId, event.amount);
      emit(PurchaseSuccess(event.productId));
    } catch (e) {
      emit(InvestmentError(e.toString()));
    }
  }
}
