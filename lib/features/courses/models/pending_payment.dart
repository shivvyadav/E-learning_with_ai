/// Model to store pending payment information
/// This helps recover payments if app is closed during payment
class PendingPayment {
  final String courseSelectId;  // ID of the course selection
  final String courseId;        // Course ID
  final String courseTitle;     // Course title
  final double amount;          // Payment amount
  final String phoneNumber;     // User's phone number
  final String? pidx;           // Khalti payment identifier (if available)
  final DateTime timestamp;     // When payment was initiated
  final String status;          // "pending", "verifying", "completed", "failed"

  PendingPayment({
    required this.courseSelectId,
    required this.courseId,
    required this.courseTitle,
    required this.amount,
    required this.phoneNumber,
    this.pidx,
    required this.timestamp,
    required this.status,
  });

  // Convert to JSON for storing in SharedPreferences
  Map<String, dynamic> toJson() => {
    'courseSelectId': courseSelectId,
    'courseId': courseId,
    'courseTitle': courseTitle,
    'amount': amount,
    'phoneNumber': phoneNumber,
    'pidx': pidx,
    'timestamp': timestamp.toIso8601String(),
    'status': status,
  };

  // Create from JSON
  factory PendingPayment.fromJson(Map<String, dynamic> json) => PendingPayment(
    courseSelectId: json['courseSelectId'],
    courseId: json['courseId'],
    courseTitle: json['courseTitle'],
    amount: json['amount'],
    phoneNumber: json['phoneNumber'],
    pidx: json['pidx'],
    timestamp: DateTime.parse(json['timestamp']),
    status: json['status'],
  );
}