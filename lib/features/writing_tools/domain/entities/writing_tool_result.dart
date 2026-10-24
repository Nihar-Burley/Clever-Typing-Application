import 'tone_option.dart';
import 'writing_tool.dart';

class WritingToolResult {
  const WritingToolResult({
    required this.tool,
    required this.outputText,
    this.tone,
    this.detectedLanguage,
    this.summaryBullets = const <String>[],
  });

  final WritingTool tool;
  final String outputText;
  final ToneOption? tone;
  final String? detectedLanguage;
  final List<String> summaryBullets;
}
