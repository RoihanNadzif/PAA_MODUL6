class BookingModel {
  final String? id;
  final String? bookingCode;
  final String? userId;
  final String? userName;
  final String? carId;
  final String? carName;
  final String? startDate;
  final String? endDate;
  final int? duration;
  final double? totalPrice;
  final String status;
  final String? pickupLocation;
  final String? returnLocation;
  final String? notes;
  final String? paymentStatus;
  final String? createdAt;

  BookingModel({
    this.id,
    this.bookingCode,
    this.userId,
    this.userName,
    this.carId,
    this.carName,
    this.startDate,
    this.endDate,
    this.duration,
    this.totalPrice,
    this.status = 'pending',
    this.pickupLocation,
    this.returnLocation,
    this.notes,
    this.paymentStatus,
    this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    String? carId;
    String? carName;
    if (json['car'] is Map) {
      carId = json['car']['_id'] as String?;
      carName = json['car']['name'] as String?;
    } else if (json['car'] is String) {
      carId = json['car'] as String;
    }

    String? userId;
    String? userName;
    if (json['user'] is Map) {
      userId = json['user']['_id'] as String?;
      userName = json['user']['name'] as String?;
    } else if (json['user'] is String) {
      userId = json['user'] as String;
    }

    return BookingModel(
      id: json['_id'] as String?,
      bookingCode: json['bookingCode'] as String?,
      userId: userId,
      userName: userName,
      carId: carId,
      carName: carName,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      duration: json['duration'] as int?,
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'pending',
      pickupLocation: json['pickupLocation'] as String?,
      returnLocation: json['returnLocation'] as String?,
      notes: json['notes'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}
