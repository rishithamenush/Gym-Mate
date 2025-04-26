import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gymmate/data/models/workout_model.dart';
import '../../providers/workout_provider.dart';
import '../../providers/workout_schedule_provider.dart';

class AddWorkoutDayScreen extends StatefulWidget {
  final WorkoutDay? editWorkoutDay;

  const AddWorkoutDayScreen({
    Key? key,
    this.editWorkoutDay,
  }) : super(key: key);

  @override
  State<AddWorkoutDayScreen> createState() => _AddWorkoutDayScreenState();
}

class _AddWorkoutDayScreenState extends State<AddWorkoutDayScreen> {
  final _formKey = GlobalKey<FormState>();
  late int _selectedDay;
  late TextEditingController _titleController;
  List<Exercise> _exercises = [];
  
  // Controllers for exercise form
  final TextEditingController _exerciseNameController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _tipsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.editWorkoutDay?.dayNumber ?? 1;
    _titleController = TextEditingController(
      text: widget.editWorkoutDay?.title ?? '',
    );
    _exercises = widget.editWorkoutDay?.exercises ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _exerciseNameController.dispose();
    _setsController.dispose();
    _tipsController.dispose();
    super.dispose();
  }

  void _showAddExerciseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _exerciseNameController,
              decoration: const InputDecoration(
                labelText: 'Exercise Name',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _setsController,
              decoration: const InputDecoration(
                labelText: 'Sets (e.g., "3 sets of 12 reps")',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tipsController,
              decoration: const InputDecoration(
                labelText: 'Tips',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_exerciseNameController.text.isNotEmpty &&
                  _setsController.text.isNotEmpty) {
                setState(() {
                  _exercises.add(
                    Exercise(
                      name: _exerciseNameController.text.trim(),
                      sets: _setsController.text.trim(),
                      tips: _tipsController.text.trim(),
                    ),
                  );
                });
                _exerciseNameController.clear();
                _setsController.clear();
                _tipsController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _saveWorkout() {
    if (_formKey.currentState!.validate()) {
      if (_exercises.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one exercise'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
      
      final workoutDay = WorkoutDay(
        dayNumber: _selectedDay,
        title: _titleController.text.trim(),
        exercises: _exercises,
      );

      if (widget.editWorkoutDay != null) {
        // Update existing workout
        workoutProvider.updateWorkoutDay(workoutDay);
      } else {
        // Add new workout
        workoutProvider.addWorkoutDay(workoutDay);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.editWorkoutDay != null ? 'Edit Workout' : 'Add Workout',
        ),
        actions: [
          TextButton.icon(
            onPressed: _saveWorkout,
            icon: const Icon(Icons.check),
            label: const Text('Save'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildDaySelector(),
            const SizedBox(height: 16),
            _buildTitleField(),
            const SizedBox(height: 24),
            _buildExercisesList(),
            const SizedBox(height: 16),
            _buildAddExerciseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Day',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedDay,
              isExpanded: true,
              items: [1, 2, 3].map((day) {
                return DropdownMenuItem(
                  value: day,
                  child: Text('Day $day'),
                );
              }).toList(),
              onChanged: widget.editWorkoutDay != null
                ? null  // Disable day selection when editing
                : (value) {
                    if (value != null) {
                      setState(() {
                        _selectedDay = value;
                      });
                    }
                  },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Workout Title',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'Enter workout title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildExercisesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Exercises',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (_exercises.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No exercises added yet',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _exercises.length,
            itemBuilder: (context, index) {
              final exercise = _exercises[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(exercise.name),
                  subtitle: Text(exercise.sets),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() {
                        _exercises.removeAt(index);
                      });
                    },
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildAddExerciseButton() {
    return ElevatedButton.icon(
      onPressed: _showAddExerciseDialog,
      icon: const Icon(Icons.add),
      label: const Text('Add Exercise'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
} 