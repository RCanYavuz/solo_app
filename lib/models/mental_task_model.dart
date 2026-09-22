// lib/models/mental_task_model.dart

class MentalTask {
  final String id;
  String title;
  String category; // "Book", "Coding", "Language", "Exam", "Skill", "General"
  int targetMinutes;
  int completedMinutes;
  int rewardExp;
  int rewardInt;
  int rewardPer;
  bool isCompleted;
  String? bookTitle;
  int? targetPages;
  int completedPages;
  String? notes;

  MentalTask({
    required this.id,
    required this.title,
    this.category = "General",
    this.targetMinutes = 25,
    this.completedMinutes = 0,
    this.rewardExp = 80,
    this.rewardInt = 1,
    this.rewardPer = 1,
    this.isCompleted = false,
    this.bookTitle,
    this.targetPages,
    this.completedPages = 0,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'targetMinutes': targetMinutes,
    'completedMinutes': completedMinutes,
    'rewardExp': rewardExp,
    'rewardInt': rewardInt,
    'rewardPer': rewardPer,
    'isCompleted': isCompleted,
    if (bookTitle != null) 'bookTitle': bookTitle,
    if (targetPages != null) 'targetPages': targetPages,
    'completedPages': completedPages,
    if (notes != null) 'notes': notes,
  };

  factory MentalTask.fromJson(Map<String, dynamic> json) => MentalTask(
    id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    title: json['title'] ?? '',
    category: json['category'] ?? 'General',
    targetMinutes: json['targetMinutes'] ?? 25,
    completedMinutes: json['completedMinutes'] ?? 0,
    rewardExp: json['rewardExp'] ?? 80,
    rewardInt: json['rewardInt'] ?? 1,
    rewardPer: json['rewardPer'] ?? 1,
    isCompleted: json['isCompleted'] ?? false,
    bookTitle: json['bookTitle'],
    targetPages: json['targetPages'],
    completedPages: json['completedPages'] ?? 0,
    notes: json['notes'],
  );

  MentalTask copyWith({
    String? id,
    String? title,
    String? category,
    int? targetMinutes,
    int? completedMinutes,
    int? rewardExp,
    int? rewardInt,
    int? rewardPer,
    bool? isCompleted,
    String? bookTitle,
    int? targetPages,
    int? completedPages,
    String? notes,
  }) {
    return MentalTask(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      completedMinutes: completedMinutes ?? this.completedMinutes,
      rewardExp: rewardExp ?? this.rewardExp,
      rewardInt: rewardInt ?? this.rewardInt,
      rewardPer: rewardPer ?? this.rewardPer,
      isCompleted: isCompleted ?? this.isCompleted,
      bookTitle: bookTitle ?? this.bookTitle,
      targetPages: targetPages ?? this.targetPages,
      completedPages: completedPages ?? this.completedPages,
      notes: notes ?? this.notes,
    );
  }
}
