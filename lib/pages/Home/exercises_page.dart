import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  ExercisesPageState createState() => ExercisesPageState();
}

class ExercisesPageState extends State<ExercisesPage> {
  int _currentExerciseIndex = 0;
  Map<String, dynamic>? _currentExercise;
  bool _isExerciseActive = false;
  Timer? _exerciseTimer;

  final List<Map<String, dynamic>> _exercises = [
    {
      'title': 'Box Breathing',
      'description': 'A calming technique to reduce stress and improve focus',
      'type': 'breathing',
      'icon': FontAwesomeIcons.rectangleList,
      'steps': [
        'Inhale for 4 seconds',
        'Hold for 4 seconds',
        'Exhale for 4 seconds',
        'Hold for 4 seconds'
      ]
    },
    {
      'title': '5-4-3-2-1 Grounding',
      'description': 'Sensory awareness technique to manage anxiety',
      'type': 'mindfulness',
      'icon': FontAwesomeIcons.handHolding,
      'steps': [
        '5 things you can see',
        '4 things you can touch',
        '3 things you can hear',
        '2 things you can smell',
        '1 thing you can taste'
      ]
    },
    {
      'title': 'Progressive Muscle Relaxation',
      'description': 'Systematic muscle tension and relaxation',
      'type': 'relaxation',
      'icon': FontAwesomeIcons.personWalking,
      'steps': [
        'Tense muscle groups',
        'Hold for 5 seconds',
        'Release and relax',
        'Notice the difference'
      ]
    },
    {
      'title': 'Mindful Meditation',
      'description': 'Focused awareness and present moment reflection',
      'type': 'meditation',
      'icon': FontAwesomeIcons.brain,
      'steps': [
        'Sit comfortably',
        'Focus on your breath',
        'Observe thoughts without judgment',
        'Return to breath when mind wanders'
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  void _startExercise(Map<String, dynamic> exercise) {
    setState(() {
      _currentExercise = {
        ...exercise,
        'currentStage': 0,
      };
      _isExerciseActive = true;
    });
    _exerciseTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentExercise != null) {
        setState(() {
          _updateCurrentExerciseStage();
        });
      }
    });
  }

  void _stopExercise() {
    _exerciseTimer?.cancel();
    setState(() {
      _isExerciseActive = false;
      _currentExercise = null;
    });
  }

  void _updateCurrentExerciseStage() {
    if (_currentExercise != null) {
      int currentStage = (_currentExercise!['currentStage'] ?? -1) + 1;
      _currentExercise = {
        ..._currentExercise!,
        'currentStage': currentStage % _currentExercise!['steps'].length,
      };
    }
  }

  @override
  void dispose() {
    _exerciseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mental Health Exercises')),
      body: _currentExercise != null
          ? _ExerciseWidget(
        exercise: _currentExercise!,
        isActive: _isExerciseActive,
        onStop: _stopExercise,
      )
          : _ExerciseSelector(
        exercises: _exercises,
        onSelectExercise: _startExercise,
      ),
    );
  }
}

class _ExerciseSelector extends StatelessWidget {
  final List<Map<String, dynamic>> exercises;
  final Function(Map<String, dynamic>) onSelectExercise;

  const _ExerciseSelector({
    required this.exercises,
    required this.onSelectExercise,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Choose an Exercise',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return Card(
                  elevation: 4,
                  child: InkWell(
                    onTap: () => onSelectExercise(exercise),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          exercise['icon'],
                          size: 80,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          exercise['title'],
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseWidget extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final bool isActive;
  final VoidCallback onStop;

  const _ExerciseWidget({
    required this.exercise,
    required this.isActive,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              exercise['title'],
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              exercise['description'],
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getColorForStage(exercise['currentStage']),
              ),
              child: Center(
                child: Text(
                  _getInstructionForStage(exercise),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ).animate(
              effects: [
                const ScaleEffect(duration: Duration(milliseconds: 500)),
                const ShimmerEffect(duration: Duration(milliseconds: 1000))
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onStop,
              child: const Text('Stop Exercise'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForStage(int stage) {
    switch (stage % 4) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  String _getInstructionForStage(Map<String, dynamic> exercise) {
    List<String> steps = exercise['steps'];
    int currentStage = exercise['currentStage'];
    if (currentStage < steps.length) {
      return steps[currentStage];
    } else {
      return 'Breathe';
    }
  }
}