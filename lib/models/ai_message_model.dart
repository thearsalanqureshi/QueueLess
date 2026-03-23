enum AiMessageRole { assistant, user }

class AiMessageModel {
  const AiMessageModel({
    required this.role,
    required this.text,
    required this.createdAt,
  });

  final AiMessageRole role;
  final String text;
  final DateTime createdAt;
}
