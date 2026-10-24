/// Saved or backend-provided assistant template shown in the assistant gallery.
class AssistantTemplate {
  /// Creates an assistant template.
  const AssistantTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.promptIntent,
    required this.promptTemplate,
    required this.isPremium,
    required this.isCustom,
    required this.isPinned,
    required this.updatedAt,
  });

  /// Stable identifier.
  final String id;

  /// User-facing name.
  final String name;

  /// Short description of what the assistant does.
  final String description;

  /// Prompt intent or execution purpose.
  final String promptIntent;

  /// Full prompt template or system instruction.
  final String promptTemplate;

  /// Whether the assistant should be premium-gated.
  final bool isPremium;

  /// Whether the assistant was created by the user.
  final bool isCustom;

  /// Whether the assistant is pinned for quick access.
  final bool isPinned;

  /// Last mutation time.
  final DateTime updatedAt;

  AssistantTemplate copyWith({
    String? id,
    String? name,
    String? description,
    String? promptIntent,
    String? promptTemplate,
    bool? isPremium,
    bool? isCustom,
    bool? isPinned,
    DateTime? updatedAt,
  }) {
    return AssistantTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      promptIntent: promptIntent ?? this.promptIntent,
      promptTemplate: promptTemplate ?? this.promptTemplate,
      isPremium: isPremium ?? this.isPremium,
      isCustom: isCustom ?? this.isCustom,
      isPinned: isPinned ?? this.isPinned,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'description': description,
      'promptIntent': promptIntent,
      'promptTemplate': promptTemplate,
      'isPremium': isPremium,
      'isCustom': isCustom,
      'isPinned': isPinned,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static AssistantTemplate fromJson(Map<String, Object?> json) {
    return AssistantTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      promptIntent: json['promptIntent'] as String,
      promptTemplate: json['promptTemplate'] as String? ??
          json['promptIntent'] as String? ??
          '',
      isPremium: json['isPremium'] as bool? ?? false,
      isCustom: json['isCustom'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
