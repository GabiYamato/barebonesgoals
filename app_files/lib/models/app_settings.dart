import 'dart:convert';

enum GraphType { bar, line, dots, area, stepped }

class AppSettings {
  final bool showHistoryInGraph;
  final int daysShownInGraph;
  final GraphType graphType;
  final int daysShownInTaskSection;

  AppSettings({
    this.showHistoryInGraph = false,
    this.daysShownInGraph = 30,
    this.graphType = GraphType.bar,
    this.daysShownInTaskSection = 7,
  });

  AppSettings copyWith({
    bool? showHistoryInGraph,
    int? daysShownInGraph,
    GraphType? graphType,
    int? daysShownInTaskSection,
  }) {
    return AppSettings(
      showHistoryInGraph: showHistoryInGraph ?? this.showHistoryInGraph,
      daysShownInGraph: daysShownInGraph ?? this.daysShownInGraph,
      graphType: graphType ?? this.graphType,
      daysShownInTaskSection:
          daysShownInTaskSection ?? this.daysShownInTaskSection,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showHistoryInGraph': showHistoryInGraph,
      'daysShownInGraph': daysShownInGraph,
      'graphType': graphType.index,
      'daysShownInTaskSection': daysShownInTaskSection,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      showHistoryInGraph: json['showHistoryInGraph'] as bool? ?? false,
      daysShownInGraph: json['daysShownInGraph'] as int? ?? 30,
      graphType: GraphType.values[json['graphType'] as int? ?? 0],
      daysShownInTaskSection: json['daysShownInTaskSection'] as int? ?? 7,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory AppSettings.fromJsonString(String jsonString) {
    return AppSettings.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  static String graphTypeToString(GraphType type) {
    switch (type) {
      case GraphType.bar:
        return 'Bar Chart';
      case GraphType.line:
        return 'Line Chart';
      case GraphType.dots:
        return 'Dot Chart';
      case GraphType.area:
        return 'Area Chart';
      case GraphType.stepped:
        return 'Stepped Chart';
    }
  }
}
