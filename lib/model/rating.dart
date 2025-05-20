class Rating {
  final String customerName;
  final String jobType;
  final String comment;
  final int stars;
  final DateTime date;

  Rating({
    required this.customerName,
    required this.jobType,
    required this.comment,
    required this.stars,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  // Optional: Add a method to convert to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'jobType': jobType,
      'comment': comment,
      'stars': stars,
      'date': date.toIso8601String(),
    };
  }

  // Optional: Add a factory method to create from Map
  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      customerName: map['customerName'],
      jobType: map['jobType'],
      comment: map['comment'],
      stars: map['stars'],
      date: DateTime.parse(map['date']),
    );
  }

  // Optional: Override toString for debugging
  @override
  String toString() {
    return 'Rating(customerName: $customerName, jobType: $jobType, '
           'stars: $stars, date: $date)';
  }
}