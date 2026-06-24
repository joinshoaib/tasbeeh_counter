class DailyStats {
  final String date;
  final Map<String, int> dhikrCounts;
  int get totalCount => dhikrCounts.values.fold(0, (a, b) => a + b);

  DailyStats({required this.date, required this.dhikrCounts});

  Map<String, dynamic> toJson() => {
    'date': date,
    'dhikrCounts': dhikrCounts,
  };

  factory DailyStats.fromJson(Map<String, dynamic> json) => DailyStats(
    date: json['date'],
    dhikrCounts: Map<String, int>.from(json['dhikrCounts']),
  );
}
