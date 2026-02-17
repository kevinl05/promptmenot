# frozen_string_literal: true

module Promptmenot
  module Patterns
    class DelimiterInjection < Base
      # HIGH CONFIDENCE — ChatML and API delimiters

      register(
        name: :chatml_system,
        regex: /<\|(?:system|im_start|im_end|endoftext)\|>/i,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :system_tag,
        regex: /\[(?:SYSTEM|INST|\/INST|SYS|\/SYS)\]/i,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :xml_system_tags,
        regex: /<\/?(?:system|instructions?|prompt|context|assistant|user)\s*>/i,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :anthropic_delimiters,
        regex: /\b(?:Human|Assistant|System)\s*:/i,
        sensitivity: :high,
        confidence: :medium
      )

      register(
        name: :triple_dash_separator,
        regex: /^-{3,}\s*(?:system|instructions?|prompt|context)\s*-{3,}$/im,
        sensitivity: :medium,
        confidence: :high
      )

      register(
        name: :triple_hash_separator,
        regex: /^#{3,}\s*(?:system|instructions?|prompt|context|new\s+conversation)\s*#{3,}$/im,
        sensitivity: :medium,
        confidence: :high
      )

      register(
        name: :begin_end_block,
        regex: /\b(?:BEGIN|START)\s*(?:SYSTEM|INSTRUCTIONS?|PROMPT|HIDDEN)\b/i,
        sensitivity: :medium,
        confidence: :high
      )

      register(
        name: :markdown_system_header,
        regex: /^#+\s*(?:system\s+(?:prompt|message|instructions?)|hidden\s+instructions?)\s*$/im,
        sensitivity: :medium,
        confidence: :high
      )

      register(
        name: :bracket_role,
        regex: /\{\{(?:system|instructions?|prompt|context)\}\}/i,
        sensitivity: :medium,
        confidence: :high
      )

      register(
        name: :llama_tokens,
        regex: /<\|(?:begin_of_text|end_of_text|start_header_id|end_header_id|eot_id)\|>/i,
        sensitivity: :low,
        confidence: :high
      )
    end
  end
end
