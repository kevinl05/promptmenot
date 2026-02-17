# frozen_string_literal: true

module Promptmenot
  module Patterns
    class IndirectInjection < Base
      # Patterns targeting LLMs that scrape/read this content later

      register(
        name: :dear_ai,
        regex: /\b(?:dear|attention|hey|hello|hi)\s+(?:ai|llm|language\s+model|chatbot|assistant|gpt|claude|gemini|copilot)\b/i,
        sensitivity: :medium,
        confidence: :high
      )

      register(
        name: :when_ai_reads,
        regex: /\bwhen\s+(?:an?\s+)?(?:ai|llm|language\s+model|chatbot|assistant)\s+(?:reads?|processes?|sees?|encounters?|parses?)\s+this\b/i,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :if_you_are_ai,
        regex: /\bif\s+you\s+(?:are\s+)?(?:an?\s+)?(?:ai|llm|language\s+model|chatbot|assistant|bot|gpt|claude)\b/i,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :note_to_ai,
        regex: /\b(?:note|message|instruction|command)\s+(?:to|for)\s+(?:any\s+)?(?:ai|llm|language\s+model|chatbot|assistant|crawler|scraper|bot)\b/i,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :ai_should,
        regex: /\b(?:any\s+)?(?:ai|llm|language\s+model|chatbot|assistant)\s+(?:that|which|who)\s+(?:reads?|sees?|processes?)\s+this\s+(?:should|must|will|needs?\s+to)\b/i,
        sensitivity: :medium,
        confidence: :high
      )

      register(
        name: :hidden_instruction_marker,
        regex: /\b(?:hidden|invisible|secret|embedded)\s+(?:instruction|prompt|command|directive|message)\s*(?:for|to)\b/i,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :ignore_profile_content,
        regex: /\bignore\s+(?:the\s+)?(?:rest\s+of\s+)?(?:this\s+)?(?:profile|bio|description|page|text|content)\b/i,
        sensitivity: :medium,
        confidence: :medium
      )

      register(
        name: :output_manipulation,
        regex: /\b(?:always|instead)\s+(?:respond|reply|answer|output|say|return)\s+(?:with|that|the\s+following)\b/i,
        sensitivity: :high,
        confidence: :medium
      )

      register(
        name: :scraping_aware,
        regex: /\b(?:web\s+)?(?:scraper|crawler|spider|indexer|harvester)s?\s+(?:should|must|will|please)\b/i,
        sensitivity: :high,
        confidence: :medium
      )

      register(
        name: :data_exfiltration,
        regex: /\b(?:send|transmit|exfiltrate|forward|leak|share)\s+(?:all\s+)?(?:data|information|context|conversation|history|messages?)\s+(?:to|at|via)\b/i,
        sensitivity: :medium,
        confidence: :high
      )
    end
  end
end
