# frozen_string_literal: true

module Promptmenot
  module Patterns
    class EncodingObfuscation < Base
      # HIGH CONFIDENCE — encoding tricks used in injection

      register(
        name: :base64_payload,
        regex: /\b(?:base64|decode|atob|decode64)\s*[:(]\s*["']?[A-Za-z0-9+\/]{20,}={0,2}["']?\s*\)?/i,
        sensitivity: :medium,
        confidence: :high
      )

      register(
        name: :hex_escape_sequence,
        regex: /(?:\\x[0-9a-fA-F]{2}){4,}/,
        sensitivity: :medium,
        confidence: :medium
      )

      register(
        name: :unicode_escape_sequence,
        regex: /(?:\\u[0-9a-fA-F]{4}){4,}/,
        sensitivity: :medium,
        confidence: :medium
      )

      register(
        name: :zero_width_chars,
        regex: /[\u200B\u200C\u200D\u2060\uFEFF]{2,}/,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :homoglyph_mixed_scripts,
        regex: /[\u0400-\u04FF].*[a-zA-Z]|[a-zA-Z].*[\u0400-\u04FF]/,
        sensitivity: :paranoid,
        confidence: :low
      )

      register(
        name: :rot13_reference,
        regex: /\brot13\s*[:(]/i,
        sensitivity: :medium,
        confidence: :medium
      )

      register(
        name: :reverse_text_instruction,
        regex: /\b(?:reverse|backwards?|mirror)\s+(?:the\s+)?(?:text|string|message|output|this)\b/i,
        sensitivity: :high,
        confidence: :low
      )

      register(
        name: :char_code_sequence,
        regex: /(?:chr|char|fromCharCode)\s*\(\s*\d{2,3}\s*\)(?:\s*\+\s*(?:chr|char|fromCharCode)\s*\(\s*\d{2,3}\s*\)){2,}/i,
        sensitivity: :medium,
        confidence: :high
      )

      register(
        name: :invisible_unicode_abuse,
        regex: /[\u00AD\u034F\u17B4\u17B5\u180E\u200E\u200F\u202A-\u202E\u2061-\u2064]{2,}/,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :leetspeak_injection,
        regex: /\b[1!]gn[0o]r[3e]\s+[1!]n[5s]truct[1!][0o]n[5s]\b/i,
        sensitivity: :high,
        confidence: :medium
      )
    end
  end
end
