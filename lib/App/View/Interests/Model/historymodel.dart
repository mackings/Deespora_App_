
class HistoryItem {
  final String title;
  final String subtitle;
  final String type; 
  final DateTime timestamp;

  HistoryItem({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      title: json['title'],
      subtitle: json['subtitle'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}