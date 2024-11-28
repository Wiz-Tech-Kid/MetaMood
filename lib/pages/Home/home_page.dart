import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:hacks/pages/Home/chatbot.dart';
import 'package:hacks/pages/Home/settings.dart';
import 'package:hacks/pages/Home/exercises_page.dart';
import 'package:hacks/pages/Home/journal_page.dart';
import 'package:hacks/pages/Home/goals_progress.dart';

const primaryGreen = Color(0xFF4CAF50);
const secondaryGreen = Color(0xFF388E3C);
const backgroundColor = Color(0xFFF5F5F5);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      const ChatbotPage(),
      const JournalPage(),
      const ExercisesPage(),
      MentalHealthHome(),
      const SettingsPage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        title: ("Home"),
        activeColorPrimary: primaryGreen,
        inactiveColorPrimary: secondaryGreen,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.book),
        title: ("Journal"),
        activeColorPrimary: primaryGreen,
        inactiveColorPrimary: secondaryGreen,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.fitness_center),
        title: ("Exercises"),
        activeColorPrimary: primaryGreen,
        inactiveColorPrimary: secondaryGreen,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.flag),
        title: ("Goals & Progress"),
        activeColorPrimary: primaryGreen,
        inactiveColorPrimary: secondaryGreen,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.settings),
        title: ("Settings"),
        activeColorPrimary: primaryGreen,
        inactiveColorPrimary: secondaryGreen,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      backgroundColor: backgroundColor, // Background color of the navbar
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      decoration: NavBarDecoration(
        colorBehindNavBar: backgroundColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      navBarStyle: NavBarStyle.style12, // Choose the style here
    );
  }
}

// Example screens for demonstration purposes
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Home Screen"));
  }
}

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Journal Screen"));
  }
}

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Exercises Screen"));
  }
}

class GoalsProgressScreen extends StatelessWidget {
  const GoalsProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Goals & Progress Screen"));
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Settings Screen"));
  }
}