class HealthRecord {
  final String? id;
  final String testName;
  final DateTime date;
  final String reportUrl;

  HealthRecord({
    this.id,
    required this.testName,
    required this.date,
    required this.reportUrl,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['_id'],
      testName: json['testName'] ?? '',
      date: DateTime.parse(json['date']),
      reportUrl: json['reportUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'testName': testName,
        'date': date.toIso8601String(),
        'reportUrl': reportUrl,
      };
}
