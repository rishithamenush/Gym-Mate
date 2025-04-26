import 'dart:async';
import 'package:flutter/material.dart';

class WorkoutRecord {
  final int dayNumber;
  final Duration duration;
  final DateTime date;

  WorkoutRecord({
    required this.dayNumber,
    required this.duration,
    required this.date,
  });
}

class WorkoutTimerProvider extends ChangeNotifier {
  Timer? _timer;
  Duration _duration = const Duration();
  bool _isRunning = false;
  DateTime? _startTime;
  Map<int, WorkoutRecord> _workoutRecords = {};

  Duration get duration => _duration;
  bool get isRunning => _isRunning;
  Map<int, WorkoutRecord> get workoutRecords => _workoutRecords;
  Map<int, Duration> get workoutDurations => 
    Map.fromEntries(_workoutRecords.entries.map((e) => MapEntry(e.key, e.value.duration)));
  
  String get formattedDuration => formatDuration(_duration);

  void startTimer(int dayNumber) {
    if (!_isRunning) {
      _isRunning = true;
      _startTime = DateTime.now();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _duration = DateTime.now().difference(_startTime!);
        notifyListeners();
      });
    }
  }

  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void resumeTimer() {
    if (!_isRunning && _startTime != null) {
      startTimer(_getCurrentDayNumber());
    }
  }

  void stopTimer([int? dayNumber]) {
    if (_isRunning) {
      _timer?.cancel();
      _isRunning = false;
      if (dayNumber != null) {
        _workoutRecords[dayNumber] = WorkoutRecord(
          dayNumber: dayNumber,
          duration: _duration,
          date: DateTime.now(),
        );
      }
      _duration = const Duration();
      _startTime = null;
      notifyListeners();
    }
  }

  void resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _duration = const Duration();
    _startTime = null;
    notifyListeners();
  }

  Duration? getWorkoutDuration(int dayNumber) {
    return _workoutRecords[dayNumber]?.duration;
  }

  DateTime? getWorkoutDate(int dayNumber) {
    return _workoutRecords[dayNumber]?.date;
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  int _getCurrentDayNumber() {
    // This should be replaced with your actual logic to determine the current day
    return 1;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
} 