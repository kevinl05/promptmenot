# frozen_string_literal: true

module Promptmenot
  module Patterns
    class DirectInstructionOverride < Base
      # HIGH CONFIDENCE — very specific injection phrases

      register(
        name: :ignore_previous_instructions,
        regex: /\bignore\s+(all\s+)?(previous|prior|above|earlier|preceding)\s+(instructions|directives|rules|prompts|guidelines)\b/i,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :disregard_instructions,
        regex: /\bdisregard\s+(all\s+)?(previous|prior|above|earlier|your)\s+(instructions|directives|rules|prompts|guidelines)\b/i,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :forget_instructions,
        regex: /\bforget\s+(all\s+)?(previous|prior|above|earlier|your)\s+(instructions|directives|rules|prompts|context)\b/i,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :override_instructions,
        regex: /\b(override|overwrite|replace)\s+(all\s+)?(previous|prior|your|system)\s+(instructions|directives|rules|prompts)\b/i,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :do_not_follow,
        regex: /\bdo\s+not\s+follow\s+(any\s+)?(previous|prior|above|your|original)\s+(instructions|directives|rules)\b/i,
        sensitivity: :medium,
        confidence: :high
      )

      # MEDIUM CONFIDENCE — contextual phrases

      register(
        name: :new_instructions,
        regex: /\b(new|updated|revised|real)\s+instructions\s*:/i,
        sensitivity: :medium,
        confidence: :medium
      )

      register(
        name: :instead_do,
        regex: /\binstead\s*,?\s+(you\s+)?(should|must|will|need\s+to)\s+(now\s+)?(do|follow|obey|respond|output)\b/i,
        sensitivity: :medium,
        confidence: :medium
      )

      register(
        name: :stop_being,
        regex: /\bstop\s+being\s+(a\s+)?(helpful|safe|responsible|ethical|cautious|careful)\b/i,
        sensitivity: :medium,
        confidence: :high
      )

      register(
        name: :from_now_on_imperative,
        regex: /\bfrom\s+now\s+on\s*,?\s+you\s+(will|must|should|shall|need\s+to)\b/i,
        sensitivity: :high,
        confidence: :medium
      )

      register(
        name: :actual_task,
        regex: /\b(the\s+)?(actual|real|true)\s+(task|instruction|objective|goal|purpose)\s+(is|was)\b/i,
        sensitivity: :high,
        confidence: :medium
      )

      register(
        name: :important_override,
        regex: /\b(important|critical|urgent)\s*[:\-!]\s*(ignore|disregard|forget|override)\b/i,
        sensitivity: :medium,
        confidence: :high
      )

      register(
        name: :do_anything_now,
        regex: /\bdo\s+anything\s+now\b/i,
        sensitivity: :medium,
        confidence: :high
      )
    end
  end
end
