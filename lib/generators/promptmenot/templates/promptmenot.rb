# frozen_string_literal: true

Promptmenot.configure do |config|
  # Default sensitivity level for all validations.
  # Options: :low, :medium (default), :high, :paranoid
  # config.sensitivity = :medium

  # Default mode for the prompt_safety validator.
  # :reject  — adds a validation error (default)
  # :sanitize — strips matched content from the field
  # config.mode = :reject

  # Replacement text used in sanitize mode.
  # config.replacement_text = "[removed]"

  # Callback fired whenever an injection is detected.
  # config.on_detect = ->(result) { Rails.logger.warn("Prompt injection: #{result.summary}") }

  # Register custom patterns:
  # config.add_pattern(
  #   name: :my_custom_pattern,
  #   regex: /my custom regex/i,
  #   category: :custom,
  #   sensitivity: :medium,
  #   confidence: :high
  # )
end
