class WeightModel {
  final int? id;
  final double weight;
  final DateTime date;
  final int workoutDay;

  WeightModel({
    this.id,
    required this.weight,
    required this.date,
    required this.workoutDay,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'date': date.toIso8601String(),
      'workoutDay': workoutDay,
    };
  }

  factory WeightModel.fromMap(Map<String, dynamic> map) {
    return WeightModel(
      id: map['id'],
      weight: map['weight'],
      date: DateTime.parse(map['date']),
      workoutDay: map['workoutDay'],
    );
  }
} 