class Exercise {
  final String name;
  final String sets;
  final String tips;
  final int reps;
  final String? notes;

  const Exercise({
    required this.name,
    required this.sets,
    required this.tips,
    this.reps = 12,  // Default value
    this.notes,
  });
}

class WorkoutDay {
  final int dayNumber;
  final String title;
  final List<Exercise> exercises;
  final bool isCompleted;

  const WorkoutDay({
    required this.dayNumber,
    required this.title,
    required this.exercises,
    this.isCompleted = false,
  });

  WorkoutDay copyWith({
    int? dayNumber,
    String? title,
    List<Exercise>? exercises,
    bool? isCompleted,
  }) {
    return WorkoutDay(
      dayNumber: dayNumber ?? this.dayNumber,
      title: title ?? this.title,
      exercises: exercises ?? this.exercises,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class WorkoutData {
  static final List<WorkoutDay> workoutDays = [
    WorkoutDay(
      dayNumber: 1,
      title: 'Upper Body Focus',
      exercises: [
        Exercise(
          name: 'Push-ups',
          sets: '3 sets of 12 reps',
          tips: 'Keep your core tight and elbows close to body',
        ),
        Exercise(
          name: 'Dumbbell Rows',
          sets: '3 sets of 10 reps',
          tips: 'Squeeze your back at the top',
        ),
      ],
    ),
    WorkoutDay(
      dayNumber: 2,
      title: 'Lower Body Power',
      exercises: [
        Exercise(
          name: 'Squats',
          sets: '4 sets of 15 reps',
          tips: 'Keep your chest up and knees aligned',
        ),
        Exercise(
          name: 'Lunges',
          sets: '3 sets of 12 reps each leg',
          tips: 'Step forward and keep your front knee aligned',
        ),
      ],
    ),
    WorkoutDay(
      dayNumber: 3,
      title: 'Core Strength',
      exercises: [
        Exercise(
          name: 'Plank',
          sets: '3 sets of 45 seconds',
          tips: 'Keep your body in a straight line',
        ),
        Exercise(
          name: 'Russian Twists',
          sets: '3 sets of 20 reps',
          tips: 'Lift your feet off the ground for more challenge',
        ),
      ],
    ),
  ];
} 