# frozen_string_literal: true

module Promptmenot
  module Patterns
    class ResourceExtraction < Base
      register(
        name: :crypto_transfer_request,
        regex: /\b(?:transfer|send|move|withdraw)\s+\d+(?:\.\d+)?\s*(?:SOL|ETH|BTC|USDC|USDT|XRP|MATIC|AVAX|DOT|ADA|BNB|DOGE|tokens?|coins?)\s+(?:to|into|towards)\b/i,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :wallet_address_with_instruction,
        regex: /\b(?:transfer|send|move|withdraw|deposit)\b.{0,80}(?:0x[0-9a-fA-F]{20,}|[13][a-km-zA-HJ-NP-Z1-9]{25,34}|[1-9A-HJ-NP-Za-km-z]{32,44})\b/i,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :full_balance_drain,
        regex: /\b(?:send|transfer|move|withdraw|drain|sweep)\s+(?:all|entire|whole|every|full|remaining|total)\s+(?:of\s+)?(?:your\s+|my\s+|the\s+)?(?:balance|funds?|tokens?|holdings?|assets?|coins?|crypto|portfolio|wallet)\b/i,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :financial_urgency_manipulation,
        regex: /\b(?:urgent(?:ly)?|immediate(?:ly)?|right\s+now|asap|time[- ]sensitive|quickly|hurry|before\s+it'?s?\s+too\s+late|window\s+closing)\b.{0,60}\b(?:transfer|send|pay|wire|withdraw|transaction|funds?|money|payment)\b/i,
        sensitivity: :medium,
        confidence: :medium
      )

      register(
        name: :authorization_claim_for_transfer,
        regex: /\b(?:i(?:'m|\s+am)\s+authorized|i\s+have\s+(?:authorization|permission|approval)|(?:authorized|approved|cleared)\s+(?:to|for)\s+(?:receive|collect|access|withdraw))\b.{0,40}\b(?:funds?|tokens?|payment|money|transfer|wallet|assets?)\b/i,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :execute_transaction_instruction,
        regex: /\b(?:execute|submit|place|perform|make|initiate|process)\s+(?:a\s+)?(?:swap|trade|sell\s+order|buy\s+order|transaction|transfer|market\s+order|limit\s+order|exchange)\b/i,
        sensitivity: :medium,
        confidence: :medium
      )

      register(
        name: :credential_extraction,
        regex: /\b(?:give|show|tell|send|share|reveal|display|output|print|provide|paste)\s+(?:me\s+)?(?:your\s+|the\s+)?(?:API\s+key|secret\s+key|private\s+key|seed\s+phrase|mnemonic|recovery\s+phrase|password|credentials?|auth\s+token|access\s+token|wallet\s+key)\b/i,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :external_endpoint_exfiltration,
        regex: %r{\b(?:send|post|submit|forward|transmit|upload|push|pipe)\s+(?:the\s+)?(?:results?|output|response|keys?|tokens?|credentials?|secrets?|data)\s+(?:to|at|via)\s+(?:https?://|webhook|endpoint|external)}i,
        sensitivity: :low,
        confidence: :high
      )

      register(
        name: :grant_access_escalation,
        regex: /\b(?:grant|give|provide|allow|enable)\s+(?:me\s+)?(?:full|admin|root|owner|unlimited|unrestricted|complete)?\s*(?:access|control|permissions?|privileges?)\s+(?:to|over|for)\s+(?:the\s+)?(?:wallet|account|funds?|system|database|keys?|credentials?|resources?)\b/i,
        sensitivity: :medium,
        confidence: :high
      )

      register(
        name: :resource_exhaustion,
        regex: /\b(?:use|exhaust|consume|burn\s+through|deplete|drain|spend|max\s+out)\s+(?:all\s+)?(?:(?:your|the|my|available|remaining)\s+)?(?:credits?|quota|budget|compute|resources?|API\s+(?:calls?|requests?)|rate\s+limit|tokens?|capacity)\b/i,
        sensitivity: :medium,
        confidence: :high
      )
    end
  end
end
