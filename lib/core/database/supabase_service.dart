import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/portfolio.dart';
import '../models/trade_record.dart';
import '../models/user.dart' as app_user;

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  // User CRUD
  Future<String> insertUser(app_user.User user) async {
    final response = await client
        .from('users')
        .insert(user.toSupabaseJson())
        .select('id')
        .single();
    return response['id'] as String;
  }

  Future<app_user.User?> getUserById(String id) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('id', id)
          .single();
      return app_user.User.fromSupabaseJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<app_user.User?> getUserByEmail(String email) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('email', email)
          .single();
      return app_user.User.fromSupabaseJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<app_user.User?> getUserByUsername(String username) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('username', username)
          .single();
      return app_user.User.fromSupabaseJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUser(app_user.User user) async {
    await client
        .from('users')
        .update(user.toSupabaseJson())
        .eq('id', user.id);
  }

  Future<List<app_user.User>> getAllUsers() async {
    final response = await client
        .from('users')
        .select()
        .order('total_assets', ascending: false);

    return (response as List)
        .map((json) => app_user.User.fromSupabaseJson(json))
        .toList();
  }

  // Portfolio CRUD
  Future<String> insertPortfolio(Portfolio portfolio) async {
    final response = await client
        .from('portfolios')
        .insert(portfolio.toSupabaseJson())
        .select('id')
        .single();
    return response['id'] as String;
  }

  Future<List<Portfolio>> getPortfoliosByUserId(String userId) async {
    final response = await client
        .from('portfolios')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Portfolio.fromSupabaseJson(json))
        .toList();
  }

  Future<Portfolio?> getPortfolioByUserAndProduct(String userId, String productId) async {
    try {
      final response = await client
          .from('portfolios')
          .select()
          .eq('user_id', userId)
          .eq('product_id', productId)
          .single();
      return Portfolio.fromSupabaseJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> updatePortfolio(Portfolio portfolio) async {
    await client
        .from('portfolios')
        .update(portfolio.toSupabaseJson())
        .eq('id', portfolio.id);
  }

  Future<void> deletePortfolio(String id) async {
    await client
        .from('portfolios')
        .delete()
        .eq('id', id);
  }

  // Trade Record CRUD
  Future<String> insertTradeRecord(TradeRecord tradeRecord) async {
    final response = await client
        .from('trade_records')
        .insert(tradeRecord.toSupabaseJson())
        .select('id')
        .single();
    return response['id'] as String;
  }

  Future<List<TradeRecord>> getTradeRecordsByUserId(String userId, {int? limit}) async {
    var query = client
        .from('trade_records')
        .select()
        .eq('user_id', userId)
        .order('trade_date', ascending: false);

    if (limit != null) {
      query = query.limit(limit);
    }

    final response = await query;

    return (response as List)
        .map((json) => TradeRecord.fromSupabaseJson(json))
        .toList();
  }

  Future<List<TradeRecord>> getTradeRecordsByProduct(String userId, String productId) async {
    final response = await client
        .from('trade_records')
        .select()
        .eq('user_id', userId)
        .eq('product_id', productId)
        .order('trade_date', ascending: false);

    return (response as List)
        .map((json) => TradeRecord.fromSupabaseJson(json))
        .toList();
  }

  // 통계 쿼리들
  Future<double> getTotalInvestmentByUser(String userId) async {
    final response = await client
        .rpc('get_total_investment', params: {'user_id': userId});
    return (response as num).toDouble();
  }

  Future<double> getTotalSalesByUser(String userId) async {
    final response = await client
        .rpc('get_total_sales', params: {'user_id': userId});
    return (response as num).toDouble();
  }

  Future<Map<String, double>> getProfitLossByProduct(String userId) async {
    final response = await client
        .rpc('get_profit_loss_by_product', params: {'user_id': userId});
    
    final Map<String, double> profitMap = {};
    for (final row in response as List) {
      profitMap[row['product_name'] as String] = (row['total_profit'] as num).toDouble();
    }
    return profitMap;
  }

  // 데이터베이스 정리 (개발용)
  Future<void> clearAllData() async {
    await client.from('trade_records').delete().neq('id', '00000000-0000-0000-0000-000000000000');
    await client.from('portfolios').delete().neq('id', '00000000-0000-0000-0000-000000000000');
    await client.from('users').delete().neq('id', '00000000-0000-0000-0000-000000000000');
  }
}