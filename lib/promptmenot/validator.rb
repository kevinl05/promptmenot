# frozen_string_literal: true

require "active_model"

class PromptSafetyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil? || value.to_s.strip.empty?

    sensitivity = options.fetch(:sensitivity, Promptmenot.configuration.sensitivity)
    mode = options.fetch(:mode, Promptmenot.configuration.mode)

    case mode.to_sym
    when :reject
      validate_reject(record, attribute, value, sensitivity)
    when :sanitize
      validate_sanitize(record, attribute, value, sensitivity)
    end
  end

  private

  def validate_reject(record, attribute, value, sensitivity)
    detector = Promptmenot::Detector.new(sensitivity: sensitivity)
    result = detector.detect(value)
    return if result.safe?

    message = options[:message] || :prompt_injection_detected
    record.errors.add(attribute, message)
  end

  def validate_sanitize(record, attribute, value, sensitivity)
    replacement = options.fetch(:replacement, Promptmenot.configuration.replacement_text)
    sanitizer = Promptmenot::Sanitizer.new(sensitivity: sensitivity, replacement: replacement)
    sanitize_result = sanitizer.sanitize(value)
    return unless sanitize_result.changed?

    record.send(:"#{attribute}=", sanitize_result.sanitized)
  end
end
