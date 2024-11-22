import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GoalsProgressPage extends StatelessWidget {
  const GoalsProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xFF1DC38E),
        scaffoldBackgroundColor: Colors.grey[50],
        fontFamily: 'SF Pro Display',
      ),
      home: MentalHealthHome(),
    );
  }
}

class MentalHealthHome extends StatelessWidget {
  final List<MentalHealthActivity> activities = [
    MentalHealthActivity(
      icon: Icons.self_improvement,
      title: 'Morning Meditation',
      time: '06:30',
      subtitle: '15 min mindfulness',
      completed: true,
    ),
    MentalHealthActivity(
      icon: Icons.create,
      title: 'Gratitude Journal',
      time: '07:30',
      subtitle: 'Write 3 grateful moments',
      completed: true,
    ),
    MentalHealthActivity(
      icon: Icons.padding,
      title: 'Breathing Exercise',
      time: '10:30',
      subtitle: '5-5-5 breathing technique',
      completed: false,
    ),
  ];

  MentalHealthHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
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
                    _buildTodayActivities(context, constraints),
                    SizedBox(height: constraints.maxHeight * 0.03),
                    _buildAchievements(context, constraints),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('dd MMMM, yyyy').format(DateTime.now()),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your Mindful Journey',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(Icons.person_outline, color: Colors.grey[800]),
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
                'Daily Wellness',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: constraints.maxWidth * 0.05,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'You\'re doing great!',
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

  Widget _buildTodayActivities(BuildContext context, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Wellness Activities',
          style: TextStyle(
            fontSize: constraints.maxWidth * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: constraints.maxHeight * 0.02),
        ...activities.map((activity) => _buildActivityItem(
          activity,
          constraints,
        )),
      ],
    );
  }

  Widget _buildActivityItem(
      MentalHealthActivity activity, BoxConstraints constraints) {
    return Container(
      margin: EdgeInsets.only(bottom: constraints.maxHeight * 0.02),
      padding: EdgeInsets.all(constraints.maxWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(constraints.maxWidth * 0.02),
            decoration: BoxDecoration(
              color: const Color(0xFF1DC38E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity.icon,
              color: const Color(0xFF1DC38E),
              size: constraints.maxWidth * 0.06,
            ),
          ),
          SizedBox(width: constraints.maxWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontSize: constraints.maxWidth * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  activity.subtitle,
                  style: TextStyle(
                    fontSize: constraints.maxWidth * 0.035,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                activity.time,
                style: TextStyle(
                  fontSize: constraints.maxWidth * 0.035,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Icon(
                activity.completed
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                color:
                activity.completed ? const Color(0xFF1DC38E) : Colors.grey[400],
                size: constraints.maxWidth * 0.05,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(BuildContext context, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Achievements',
          style: TextStyle(
            fontSize: constraints.maxWidth * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: constraints.maxHeight * 0.02),
        _buildAchievementGrid(constraints),
      ],
    );
  }

  Widget _buildAchievementGrid(BoxConstraints constraints) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      mainAxisSpacing: constraints.maxWidth * 0.04,
      crossAxisSpacing: constraints.maxWidth * 0.04,
      children: [
        _buildAchievementCard(
          'Mindfulness Master',
          '7 days meditation streak',
          Icons.self_improvement,
          true,
          constraints,
        ),
        _buildAchievementCard(
          'Gratitude Guru',
          '30 journal entries',
          Icons.favorite,
          true,
          constraints,
        ),
        _buildAchievementCard(
          'Breathing Expert',
          '50 breathing sessions',
          Icons.air,
          false,
          constraints,
        ),
        _buildAchievementCard(
          'Mood Tracker',
          'Track for 14 days',
          Icons.psychology,
          false,
          constraints,
        ),
      ],
    );
  }

  Widget _buildAchievementCard(String title, String description, IconData icon,
      bool unlocked, BoxConstraints constraints) {
    return Container(
      padding: EdgeInsets.all(constraints.maxWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: constraints.maxWidth * 0.08,
            color: unlocked ? const Color(0xFF1DC38E) : Colors.grey[400],
          ),
          SizedBox(height: constraints.maxHeight * 0.01),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: constraints.maxWidth * 0.035,
              fontWeight: FontWeight.bold,
              color: unlocked ? Colors.grey[800] : Colors.grey[400],
            ),
          ),
          SizedBox(height: constraints.maxHeight * 0.005),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: constraints.maxWidth * 0.03,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class MentalHealthActivity {
  final IconData icon;
  final String title;
  final String time;
  final String subtitle;
  final bool completed;

  MentalHealthActivity({
    required this.icon,
    required this.title,
    required this.time,
    required this.subtitle,
    required this.completed,
  });
}