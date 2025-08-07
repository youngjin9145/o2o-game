abstract class InvestmentRepository {
  Future<List<Map<String, dynamic>>> getInvestmentProducts();
  Future<void> purchaseProduct(String productId, double amount);
}
