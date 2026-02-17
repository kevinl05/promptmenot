# frozen_string_literal: true

module Promptmenot
  module Patterns
    class RoleManipulation < Base
      # HIGH CONFIDENCE — specific jailbreak terminology

      register(
        name: :dan_jailbreak,
        regex: /\b(you\s+are\s+)?D\.?A\.?N\.?\b.*\b(do\s+anything|no\s+(restrictions?|limitations?|rules?))\b/i,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :jailbreak_keyword,
        regex: /\bjailbreak\s*(mode|prompt|enabled|activated|engaged)\b/i,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :developer_mode,
        regex: /\b(developer|dev|maintenance|debug|god|admin)\s+mode\s*(enabled|activated|engaged|on|override)\b/i,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :act_as_evil,
        regex: /\b(act|behave|function|operate|respond)\s+(as|like)\s+(an?\s+)?(unrestricted|unfiltered|uncensored|evil|malicious|unethical|amoral)\b/i,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :pretend_no_restrictions,
        regex: /\bpretend\s+(that\s+)?(you\s+)?(have\s+)?(no|don'?t\s+have\s+any)\s+(restrictions?|limitations?|rules?|filters?|guidelines?)\b/i,
        sensitivity: :medium,
        confidence: :high
      )

      register(
        name: :you_are_now_ai,
        regex: /\byou\s+are\s+now\s+(a\s+)?(new|different|unrestricted|unfiltered|special|custom)\s+(ai|assistant|bot|model|system|chatbot)\b/i,
        sensitivity: :medium,
        confidence: :high
      )

      register(
        name: :sudo_mode,
        regex: /\bsudo\s+(mode|access|override|command|prompt)\b/i,
        sensitivity: :medium,
        confidence: :medium
      )

      register(
        name: :without_restrictions,
        regex: /\b(respond|answer|reply|act|behave|write)\s+(without|with\s+no)\s+(any\s+)?(restrictions?|limitations?|filters?|censorship|safeguards?|guardrails?)\b/i,
        sensitivity: :medium,
        confidence: :high
      )

      register(
        name: :roleplay_unrestricted,
        regex: /\b(roleplay|role\s*-?\s*play|pretend|simulate)\b.*\b(no\s+(rules?|limits?|restrictions?)|unrestricted|anything\s+goes)\b/i,
        sensitivity: :high,
        confidence: :medium
      )

      register(
        name: :persona_switch,
        regex: /\b(switch|change|adopt|assume)\s+(to|into|a)\s+(new\s+)?(persona|personality|character|identity|role)\s+(that|which|where|with)\b/i,
        sensitivity: :paranoid,
        confidence: :low
      )
    end
  end
end
