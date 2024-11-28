import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  ExercisesPageState createState() => ExercisesPageState();
}

class ExercisesPageState extends State<ExercisesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _currentUser;
  int _dailyStreak = 0;
  Map<String, dynamic> _userProgress = {};

  final int _currentExerciseIndex = 0;
  Map<String, dynamic>? _currentExercise;
  bool _isExerciseActive = false;
  Timer? _exerciseTimer;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _fetchUserProgress();
    }
  }

  final List<Map<String, dynamic>> _exercises = [
    {
      'title': 'Box Breathing',
      'description': 'A calming technique to reduce stress and improve focus',
      'type': 'breathing',
      'icon': FontAwesomeIcons.wind,
      'color': const Color(0xFF1DC38E),
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
      'color': const Color(0xFF4A90E2),
      'steps': [
        '5 things you can see',
        '4 things you can touch',
        '3 things you can hear',
        '2 things you can smell',
        '1 thing you can taste'
      ]
    },
    {
      'title': 'Body Scan',
      'description': 'Systematic relaxation from head to toe',
      'type': 'relaxation',
      'icon': FontAwesomeIcons.personRays,
      'color': const Color(0xFFF5A623),
      'steps': [
        'Focus on your head and face',
        'Move to shoulders and arms',
        'Notice your chest and back',
        'Scan your legs and feet',
        'Feel your whole body'
      ]
    },
    {
      'title': 'Gratitude Practice',
      'description': 'Cultivate positive mindset through appreciation',
      'type': 'mindfulness',
      'icon': FontAwesomeIcons.heart,
      'color': const Color(0xFFE74C3C),
      'steps': [
        'Think of someone special',
        'Recall a happy memory',
        'Name something in nature',
        'Appreciate your strength',
        'Feel the gratitude'
      ]
    },
    {
      'title': 'Visualization',
      'description': 'Create a peaceful mental sanctuary',
      'type': 'meditation',
      'icon': FontAwesomeIcons.mountain,
      'color': const Color(0xFF9B59B6),
      'steps': [
        'Close your eyes gently',
        'Picture a calm place',
        'Add sensory details',
        'Immerse yourself fully',
        'Stay in this space'
      ]
    },
    {
      'title': 'Thought Release',
      'description': 'Let go of intrusive thoughts mindfully',
      'type': 'mindfulness',
      'icon': FontAwesomeIcons.feather,
      'color': const Color(0xFF34495E),
      'steps': [
        'Notice your thoughts',
        'Don\'t judge them',
        'Imagine them floating away',
        'Return to the present',
        'Continue observing'
      ]
    }
  ];

  Future<void> _fetchUserProgress() async {
    if (_currentUser == null) return;

    try {
      final docSnapshot = await _firestore
          .collection('user_progress')
          .doc(_currentUser!.uid)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          _userProgress = docSnapshot.data() ?? {};
          _dailyStreak = _userProgress['daily_streak'] ?? 0;
        });
      }
    } catch (e) {
      print('Error fetching user progress: $e');
    }
  }

  Future<void> _updateUserProgress(Map<String, dynamic> exerciseData) async {
    if (_currentUser == null) return;

    try {
      await _firestore
          .collection('user_progress')
          .doc(_currentUser!.uid)
          .set({
        'completed_exercises': FieldValue.arrayUnion([exerciseData]),
        'last_exercise_timestamp': FieldValue.serverTimestamp(),
        'daily_streak': FieldValue.increment(1)
      }, SetOptions(merge: true));

      // Log exercise completion event
      await _analytics.logEvent(
        name: 'exercise_completed',
        parameters: {
          'exercise_type': exerciseData['type'],
          'exercise_title': exerciseData['title']
        },
      );
    } catch (e) {
      print('Error updating user progress: $e');
    }
  }

  void _startExercise(Map<String, dynamic> exercise) {
    setState(() {
      _currentExercise = {
        ...exercise,
        'currentStage': 0,
      };
      _isExerciseActive = true;
    });

    // Log exercise start event
    _analytics.logEvent(
      name: 'exercise_started',
      parameters: {
        'exercise_type': exercise['type'],
        'exercise_title': exercise['title']
      },
    );

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
    if (_currentExercise != null) {
      _updateUserProgress(_currentExercise!);
    }

    setState(() {
      _isExerciseActive = false;
      _currentExercise = null;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _currentExercise != null
            ? _ExerciseWidget(
          exercise: _currentExercise!,
          isActive: _isExerciseActive,
          onStop: _stopExercise,
        )
            : LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth * 0.05,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    _buildWellnessCard(context, constraints),
                    SizedBox(height: constraints.maxHeight * 0.03),
                    _buildExercisesGrid(constraints),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mental Wellness Exercises',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWellnessCard(BuildContext context, BoxConstraints constraints) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(constraints.maxWidth * 0.05),
      decoration: BoxDecoration(
        color: const Color(0xFF1DC38E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: constraints.maxWidth * 0.05,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Keep up the great work!',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: constraints.maxWidth * 0.035,
                ),
              ),
            ],
          ),
          _buildProgressIndicator(constraints),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(BoxConstraints constraints) {
    double size = constraints.maxWidth * 0.15;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: 0.75,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: size * 0.1,
          ),
          Center(
            child: Text(
              '75%',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.3,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesGrid(BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose an Exercise',
          style: TextStyle(
            fontSize: constraints.maxWidth * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: constraints.maxHeight * 0.02),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.maxWidth > 600 ? 3 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: _exercises.length,
          itemBuilder: (context, index) {
            final exercise = _exercises[index];
            return _buildExerciseCard(exercise, constraints);
          },
        ),
      ],
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise, BoxConstraints constraints) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _startExercise(exercise),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(constraints.maxWidth * 0.03),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                exercise['color'],
                exercise['color'].withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                exercise['icon'],
                size: constraints.maxWidth * 0.1,
                color: Colors.white,
              ),
              SizedBox(height: constraints.maxHeight * 0.01),
              Text(
                exercise['title'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: constraints.maxWidth * 0.035,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: constraints.maxHeight * 0.005),
              Text(
                exercise['type'].toString().toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: constraints.maxWidth * 0.025,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate()
        .fade(duration: const Duration(milliseconds: 500))
        .scale(duration: const Duration(milliseconds: 500));
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
    return LayoutBuilder(
        builder: (context, constraints) {
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(constraints.maxWidth * 0.05),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
          Row(
          children: [
          IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onStop,
        ),
        const SizedBox(width: 8),
        Text(
          exercise['title'],
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        ],
      ),
    SizedBox(height: constraints.maxHeight * 0.05),
    Text(
    exercise['description'],
    style: Theme.of(context).textTheme.titleMedium,
    textAlign: TextAlign.center,
    ),
    SizedBox(height: constraints.maxHeight * 0.05),
    Container(
    height: constraints.maxWidth * 0.6,
    width: constraints.maxWidth * 0.6,
    decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
    exercise['color'],
    exercise['color'].withOpacity(0.8),
    ],
    ),
    boxShadow: [
    BoxShadow(
    color: exercise['color'].withOpacity(0.3),
    blurRadius: 15,
    spreadRadius: 5,
    ),
    ],
    ),
    child: Center(
    child: Padding(
    padding: EdgeInsets.all(constraints.maxWidth * 0.05),
    child: Text(
    _getInstructionForStage(exercise),
    style: TextStyle(
    color: Colors.white,
    fontSize: constraints.maxWidth * 0.045,
    fontWeight: FontWeight.bold,
    ),
    textAlign: TextAlign.center,
    ),
    ),
    ),
    ).animate()
        .fade(duration: const Duration(milliseconds: 500))
        .scale(duration: const Duration(milliseconds: 500)),

    SizedBox(height: constraints.maxHeight * 0.05),
    ElevatedButton.icon(
    onPressed: onStop,
    icon: const Icon(Icons.stop_circle_outlined),
    label: const Text('End Session'),
    style: ElevatedButton.styleFrom(
    backgroundColor: exercise['color'],
    padding: EdgeInsets.symmetric(
    horizontal: constraints.maxWidth * 0.08,
    vertical: constraints.maxWidth * 0.03,
    ),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30),
    ),
    ),
    ),
              ],
          ),
        ),
      );
        },
    );
  }

  String _getInstructionForStage(Map<String, dynamic> exercise) {
    List<String> steps = exercise['steps'];
    int currentStage = exercise['currentStage'];
    if (currentStage < steps.length) {
      return steps[currentStage];
    } else {
      return 'Well done!';
    }
  }
}

// Optional: Add this data model class for better type safety
class MentalHealthActivity {
  final IconData icon;
  final String title;
  final String description;
  final String type;
  final Color color;
  final List<String> steps;

  MentalHealthActivity({
    required this.icon,
    required this.title,
    required this.description,
    required this.type,
    required this.color,
    required this.steps,
  });

  Map<String, dynamic> toMap() {
    return {
      'icon': icon,
      'title': title,
      'description': description,
      'type': type,
      'color': color,
      'steps': steps,
    };
  }
}

// Optional: Add these theme constants for consistent styling
class AppTheme {
  static const primaryColor = Color(0xFF1DC38E);
  static const secondaryColor = Color(0xFF4A90E2);
  static const backgroundColor = Colors.white;

  static final cardShadow = BoxShadow(
    color: Colors.grey.withOpacity(0.1),
    spreadRadius: 1,
    blurRadius: 4,
    offset: const Offset(0, 2),
  );

  static const gradientColors = [
    Color(0xFF1DC38E),
    Color(0xFF4A90E2),
    Color(0xFFF5A623),
    Color(0xFFE74C3C),
    Color(0xFF9B59B6),
    Color(0xFF34495E),
  ];
}