# frozen_string_literal: true

module Promptmenot
  module Patterns
    class ContextManipulation < Base
      register(
        name: :reset_conversation,
        regex: /(?:={3,}|~{3,}|\*{3,})\s*(?:RESET|NEW\s+CONVERSATION|START\s+OVER|CLEAR\s+CONTEXT|END\s+SYSTEM)\s*(?:={3,}|~{3,}|\*{3,})/i,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :end_of_prompt,
        regex: /\b(?:end|close)\s+(?:of\s+)?(?:system\s+)?(?:prompt|instructions?|context|conversation|message)\b/i,
        sensitivity: :medium,
        confidence: :medium
      )

      register(
        name: :above_is_test,
        regex: /\b(?:the\s+)?(?:above|previous|preceding)\s+(?:text\s+)?(?:is|was)\s+(?:just\s+)?(?:a\s+)?(?:test|example|fake|placeholder|dummy|decoy)\b/i,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :real_conversation_starts,
        regex: /\b(?:the\s+)?(?:real|actual|true)\s+(?:conversation|task|prompt|session|interaction)\s+(?:starts?|begins?)\s+(?:here|now|below)\b/i,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :context_window_exploit,
        regex: /\b(?:context|token)\s+(?:window|limit|boundary)\s+(?:exceeded|overflow|exploit|bypass|trick)\b/i,
        sensitivity: :medium,
        confidence: :high
      )

      register(
        name: :system_prompt_leak,
        regex: /\b(?:reveal|show|display|print|output|repeat|echo)\s+(?:me\s+)?(?:your\s+)?(?:system\s+)?(?:prompt|instructions?|rules?|guidelines?|directives?)\b/i,
        sensitivity: :medium,
        confidence: :high
      )

      register(
        name: :memory_injection,
        regex: /\b(?:remember|memorize|store|save)\s+(?:that|this|the\s+following)\s*:?\s*(?:you\s+(?:are|must|should|will))\b/i,
        sensitivity: :high,
        confidence: :medium
      )

      register(
        name: :hypothetical_bypass,
        regex: /\b(?:hypothetically|theoretically|in\s+theory|imagine\s+if)\s*,?\s*(?:you\s+)?(?:could|would|should|can)\s+(?:ignore|bypass|skip|override)\b/i,
        sensitivity: :high,
        confidence: :medium
      )
    end
  end
end
