class PaymentModel {
  final String? id;
  final String? paymentCode;
  final String? bookingId;
  final String? bookingCode;
  final String? userId;
  final String? userName;
  final double? amount;
  final String? method;
  final String status;
  final String? proofOfPayment;
  final String? bankName;
  final String? accountNumber;
  final String? accountName;
  final String? transactionId;
  final String? notes;
  final String? paidAt;
  final String? createdAt;

  PaymentModel({
    this.id,
    this.paymentCode,
    this.bookingId,
    this.bookingCode,
    this.userId,
    this.userName,
    this.amount,
    this.method,
    this.status = 'pending',
    this.proofOfPayment,
    this.bankName,
    this.accountNumber,
    this.accountName,
    this.transactionId,
    this.notes,
    this.paidAt,
    this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    // Handle booking field
    String? bookingId;
    String? bookingCode;
    if (json['booking'] is Map) {
      bookingId = json['booking']['_id'] as String?;
      bookingCode = json['booking']['bookingCode'] as String?;
    } else if (json['booking'] is String) {
      bookingId = json['booking'] as String;
    }

    // Handle user field
    String? userId;
    String? userName;
    if (json['user'] is Map) {
      userId = json['user']['_id'] as String?;
      userName = json['user']['name'] as String?;
    } else if (json['user'] is String) {
      userId = json['user'] as String;
    }

    return PaymentModel(
      id: json['_id'] as String?,
      paymentCode: json['paymentCode'] as String?,
      bookingId: bookingId,
      bookingCode: bookingCode,
      userId: userId,
      userName: userName,
      amount: (json['amount'] as num?)?.toDouble(),
      method: json['method'] as String?,
      status: json['status'] as String? ?? 'pending',
      proofOfPayment: json['proofOfPayment'] as String?,
      bankName: json['bankName'] as String?,
      accountNumber: json['accountNumber'] as String?,
      accountName: json['accountName'] as String?,
      transactionId: json['transactionId'] as String?,
      notes: json['notes'] as String?,
      paidAt: json['paidAt'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}
