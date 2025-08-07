abstract class PortfolioRepository {
  Future<Map<String, dynamic>> getPortfolioData();
  Future<void> updatePortfolio(Map<String, dynamic> data);
}
