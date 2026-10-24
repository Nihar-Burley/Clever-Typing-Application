import '../../domain/entities/tone_option.dart';
import '../../domain/entities/writing_tool.dart';

abstract final class WritingToolApiMapper {
  static String toolName(WritingTool tool) {
    return switch (tool) {
      WritingTool.grammarCorrection => 'grammar_correction',
      WritingTool.toneRewrite => 'tone_rewrite',
      WritingTool.paraphrase => 'paraphrase',
      WritingTool.shorten => 'shorten',
      WritingTool.expand => 'expand',
      WritingTool.simplify => 'simplify',
      WritingTool.humanize => 'humanize',
      WritingTool.summarize => 'summarize',
      WritingTool.captionGeneration => 'caption_generation',
      WritingTool.emailDraft => 'email_draft',
    };
  }

  static String toneName(ToneOption tone) {
    return switch (tone) {
      ToneOption.neutral => 'neutral',
      ToneOption.professional => 'professional',
      ToneOption.friendly => 'friendly',
      ToneOption.formal => 'formal',
      ToneOption.persuasive => 'persuasive',
    };
  }
}
