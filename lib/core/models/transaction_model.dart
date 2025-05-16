class Transaction {
  final String id;
  final String userId;
  final String type;
  final String method;
  final double amount;
  final String balanceType;
  final double balanceAfter;
  final OrderId? orderId;
  final String transactionId;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.method,
    required this.amount,
    required this.balanceType,
    required this.balanceAfter,
    this.orderId,
    required this.transactionId,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      method: json['method'] ?? '',
      amount: json['amount']?.toDouble() ?? 0.0,
      balanceType: json['balanceType'] ?? '',
      balanceAfter: json['balanceAfter']?.toDouble() ?? 0.0,
      orderId: json['orderId'] != null ? OrderId.fromJson(json['orderId']) : null,
      transactionId: json['transactionId'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

class OrderId {
  final String id;
  final double totalWeight;
  final String paymentMethod;

  OrderId({
    required this.id,
    required this.totalWeight,
    required this.paymentMethod,
  });

  factory OrderId.fromJson(Map<String, dynamic> json) {
    return OrderId(
      id: json['_id'] ?? '',
      totalWeight: json['totalWeight']?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? '',
    );
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalItems: json['totalItems'] ?? 0,
      itemsPerPage: json['itemsPerPage'] ?? 10,
    );
  }
}

class BalanceInfo {
  final double totalGoldBalance;
  final double availableGold;
  final double goldCredit;
  final double cashBalance;
  final String name;
  final String email;

  BalanceInfo({
    required this.totalGoldBalance,
    required this.availableGold,
    required this.goldCredit,
    required this.cashBalance,
    required this.name,
    required this.email,
  });

  factory BalanceInfo.fromJson(Map<String, dynamic> json) {
    return BalanceInfo(
      totalGoldBalance: json['totalGoldBalance']?.toDouble() ?? 0.0,
      availableGold: json['availableGold']?.toDouble() ?? 0.0,
      goldCredit: json['goldCredit']?.toDouble() ?? 0.0,
      cashBalance: json['cashBalance']?.toDouble() ?? 0.0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class Summary {
  final BalanceTypeSummary gold;
  final BalanceTypeSummary cash;
  final List<RecentTransaction> recentTransactions;

  Summary({
    required this.gold,
    required this.cash,
    required this.recentTransactions,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    List<RecentTransaction> recentTransactions = [];
    if (json['recentTransactions'] != null) {
      recentTransactions = List<RecentTransaction>.from(
          json['recentTransactions'].map((x) => RecentTransaction.fromJson(x)));
    }

    return Summary(
      gold: BalanceTypeSummary.fromJson(json['gold'] ?? {}),
      cash: BalanceTypeSummary.fromJson(json['cash'] ?? {}),
      recentTransactions: recentTransactions,
    );
  }
}

class BalanceTypeSummary {
  final double totalCredits;
  final double totalDebits;
  final int creditCount;
  final int debitCount;
  final double netFlow;

  BalanceTypeSummary({
    required this.totalCredits,
    required this.totalDebits,
    required this.creditCount,
    required this.debitCount,
    required this.netFlow,
  });

  factory BalanceTypeSummary.fromJson(Map<String, dynamic> json) {
    return BalanceTypeSummary(
      totalCredits: json['totalCredits']?.toDouble() ?? 0.0,
      totalDebits: json['totalDebits']?.toDouble() ?? 0.0,
      creditCount: json['creditCount'] ?? 0,
      debitCount: json['debitCount'] ?? 0,
      netFlow: json['netFlow']?.toDouble() ?? 0.0,
    );
  }
}

class RecentTransaction {
  final String transactionId;
  final String type;
  final String method;
  final double amount;
  final String balanceType;
  final DateTime createdAt;

  RecentTransaction({
    required this.transactionId,
    required this.type,
    required this.method,
    required this.amount,
    required this.balanceType,
    required this.createdAt,
  });

  factory RecentTransaction.fromJson(Map<String, dynamic> json) {
    return RecentTransaction(
      transactionId: json['transactionId'] ?? '',
      type: json['type'] ?? '',
      method: json['method'] ?? '',
      amount: json['amount']?.toDouble() ?? 0.0,
      balanceType: json['balanceType'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

class TransactionResponse {
  final bool success;
  final TransactionData data;

  TransactionResponse({
    required this.success,
    required this.data,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      success: json['success'] ?? false,
      data: TransactionData.fromJson(json['data'] ?? {}),
    );
  }
}

class TransactionData {
  final List<Transaction> transactions;
  final Pagination pagination;
  final Summary summary;
  final BalanceInfo balanceInfo;

  TransactionData({
    required this.transactions,
    required this.pagination,
    required this.summary,
    required this.balanceInfo,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    List<Transaction> transactions = [];
    if (json['transactions'] != null) {
      transactions = List<Transaction>.from(
          json['transactions'].map((x) => Transaction.fromJson(x)));
    }

    return TransactionData(
      transactions: transactions,
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
      summary: Summary.fromJson(json['summary'] ?? {}),
      balanceInfo: BalanceInfo.fromJson(json['balanceInfo'] ?? {}),
    );
  }
}