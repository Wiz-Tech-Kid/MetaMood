class Achievement {
  final String id;
  final String title;
  final String description;
  final int iconCode;
  final bool unlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconCode,
    required this.unlocked,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'iconCode': iconCode,
      'unlocked': unlocked,
    };
  }

  static Achievement fromMap(String id, Map<String, dynamic> map) {
    return Achievement(
      id: id,
      title: map['title'],
      description: map['description'],
      iconCode: map['iconCode'],
      unlocked: map['unlocked'],
    );
  }
}