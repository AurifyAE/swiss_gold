class MarketModel {
  final Map<String, double> bids;

  MarketModel({required this.bids});

  // Add/Update a bid
  void updateBid(String symbol, double bid) {
    bids[symbol] = bid;
  }

  // Retrieve a bid for a symbol
  double? getBid(String symbol) {
    return bids[symbol];
  }
}
