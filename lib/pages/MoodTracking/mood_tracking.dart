import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

// Models
class ChatMessage {
  final String text;
  final DateTime timestamp;
  final bool isUser;

  ChatMessage({
    required this.text,
    DateTime? timestamp,
    required this.isUser,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatSentiment {
  final String text;
  final DateTime timestamp;
  final double sentimentScore;
  final Map<String, double> emotions;

  ChatSentiment({
    required this.text,
    required this.timestamp,
    required this.sentimentScore,
    required this.emotions,
  });
}

class MoodData {
  final DateTime date;
  final double mood;
  final double energy;

  MoodData({
    required this.date,
    required this.mood,
    required this.energy,
  });
}

class MoodScore {
  final String emoji;
  final double score;
  final double trend;
  final String lastUpdate;

  MoodScore({
    required this.emoji,
    required this.score,
    required this.trend,
    required this.lastUpdate,
  });
}

class MoodTrackingPage extends StatefulWidget {
  final List<ChatMessage> chatHistory;

  const MoodTrackingPage({
    super.key,
    required this.chatHistory,
  });

  @override
  MoodTrackingPageState createState() => MoodTrackingPageState();
}

class MoodTrackingPageState extends State<MoodTrackingPage> {
  late List<ChatSentiment> _sentimentAnalysis;
  late Map<String, MoodScore> _moodScores;
  late List<MoodData> _weeklyTrend;
  int _selectedTimeRange = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _analyzeChatHistory();
    _calculateMoodScores();
    _generateWeeklyTrend();
  }

  void _analyzeChatHistory() {
    _sentimentAnalysis = widget.chatHistory.map((message) {
      return _analyzeMessageSentiment(message);
    }).toList();
  }

  ChatSentiment _analyzeMessageSentiment(ChatMessage message) {
    double sentimentScore = _analyzeSentiment(message.text);

    return ChatSentiment(
      text: message.text,
      timestamp: message.timestamp,
      sentimentScore: sentimentScore,
      emotions: _generateEmotions(sentimentScore),
    );
  }

  double _analyzeSentiment(String text) {
    final positiveWords = {'happy', 'good', 'great', 'awesome', 'love'};
    final negativeWords = {'sad', 'bad', 'awful', 'hate', 'angry'};

    text = text.toLowerCase();
    double score = 0;

    for (final word in text.split(' ')) {
      if (positiveWords.contains(word)) score += 0.2;
      if (negativeWords.contains(word)) score -= 0.2;
    }

    return score.clamp(-1.0, 1.0);
  }

  Map<String, double> _generateEmotions(double baseScore) {
    final random = math.Random();
    return {
      'Joy': math.max(0, baseScore),
      'Sadness': math.max(0, -baseScore),
      'Anxiety': random.nextDouble() * 0.5,
      'Anger': random.nextDouble() * 0.3,
      'Neutral': 0.5,
    };
  }

  void _calculateMoodScores() {
    final now = DateTime.now();
    _moodScores = {
      'Happy': MoodScore(
        emoji: '😊',
        score: 0.8,
        trend: 0.05,
        lastUpdate: '2h ago',
      ),
      'Neutral': MoodScore(
        emoji: '😐',
        score: 0.5,
        trend: -0.02,
        lastUpdate: '4h ago',
      ),
      'Sad': MoodScore(
        emoji: '😔',
        score: 0.2,
        trend: 0.03,
        lastUpdate: '6h ago',
      ),
    };
  }

  void _generateWeeklyTrend() {
    final random = math.Random();
    _weeklyTrend = List.generate(7, (index) {
      return MoodData(
        date: DateTime.now().subtract(Duration(days: 6 - index)),
        mood: 0.4 + random.nextDouble() * 0.4,
        energy: 0.3 + random.nextDouble() * 0.5,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[50]!,
              Colors.blue[100]!,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.all(20.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildTimeRangeSelector(),
                    const SizedBox(height: 20),
                    _buildCurrentMoodCard(),
                    const SizedBox(height: 20),
                    _buildWeeklyTrendCard(),
                    const SizedBox(height: 20),
                    _buildMoodBreakdownCard(),
                    const SizedBox(height: 20),
                    _buildRecentChatsCard(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Colors.green;
      case 'sad':
        return Colors.blue;
      case 'angry':
        return Colors.red;
      case 'neutral':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Add these methods to the MoodTrackingPageState class

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Mood Insights',
          style: TextStyle(
            color: Colors.blue[900],
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue[50]!,
                Colors.blue[100]!,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTimeRangeButton('Daily', 0),
            _buildTimeRangeButton('Weekly', 1),
            _buildTimeRangeButton('Monthly', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeButton(String label, int index) {
    final isSelected = _selectedTimeRange == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: TextButton(
        onPressed: () => setState(() => _selectedTimeRange = index),
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue[600] : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blue[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentMoodCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Mood',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                Text(
                  DateFormat('MMM d, HH:mm').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _moodScores.entries
                  .take(3)
                  .map((entry) => _buildEnhancedMoodIndicator(
                entry.value.emoji,
                entry.key,
                entry.value.score,
                entry.value.trend,
                entry.value.lastUpdate,
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedMoodIndicator(
      String emoji,
      String label,
      double score,
      double trend,
      String lastUpdate,
      ) {
    final trendColor = trend >= 0 ? Colors.green : Colors.red;
    final trendIcon = trend >= 0 ? Icons.arrow_upward : Icons.arrow_downward;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 28)),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(trendIcon, size: 12, color: trendColor),
            Text(
              '${(trend * 100).abs().toStringAsFixed(1)}%',
              style: TextStyle(
                color: trendColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          lastUpdate,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyTrendCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood & Energy Trends',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: LineChart(_createLineChartData()),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildChartLegend('Mood', Colors.blue[600]!),
                const SizedBox(width: 20),
                _buildChartLegend('Energy', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  LineChartData _createLineChartData() {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value >= 0 && value < _weeklyTrend.length) {
                return Text(
                  DateFormat('E').format(_weeklyTrend[value.toInt()].date),
                  style: const TextStyle(fontSize: 12),
                );
              }
              return const Text('');
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        _createLineChartBarData(
          _weeklyTrend
              .asMap()
              .entries
              .map((entry) => FlSpot(
            entry.key.toDouble(),
            entry.value.mood,
          ))
              .toList(),
          Colors.blue[600]!,
        ),
        _createLineChartBarData(
          _weeklyTrend
              .asMap()
              .entries
              .map((entry) => FlSpot(
            entry.key.toDouble(),
            entry.value.energy,
          ))
              .toList(),
          Colors.orange,
        ),
      ],
    );
  }

  LineChartBarData _createLineChartBarData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: 4,
          color: color,
          strokeWidth: 2,
          strokeColor: Colors.white,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.1),
      ),
    );
  }

  Widget _buildMoodBreakdownCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Distribution',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 20),
            ..._moodScores.entries.map((entry) => Column(
              children: [
                Row(
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.value.emoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    Text(
                      '${(entry.value.score * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: entry.value.score,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(_getMoodColor(entry.key)),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentChatsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Chat Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: math.min(5, _sentimentAnalysis.length),
              itemBuilder: (context, index) {
                final sentiment = _sentimentAnalysis[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getSentimentColor(sentiment.sentimentScore),
                    child: Text(
                      _getSentimentEmoji(sentiment.sentimentScore),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text(
                    sentiment.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    DateFormat('MMM d, HH:mm').format(sentiment.timestamp),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Text(
                    '${(sentiment.sentimentScore * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: _getSentimentColor(sentiment.sentimentScore),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getSentimentColor(double score) {
    if (score > 0.3) return Colors.green;
    if (score < -0.3) return Colors.red;
    return Colors.orange;
  }

  String _getSentimentEmoji(double score) {
    if (score > 0.3) return '😊';
    if (score < -0.3) return '😔';
    return '😐';
  }
}