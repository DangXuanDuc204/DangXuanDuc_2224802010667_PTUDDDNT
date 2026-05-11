class Todo {
  const Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.isDone,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final bool isDone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      isDone: json['isDone'] == true,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()),
    );
  }
}
