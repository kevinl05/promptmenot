# PromptMeNot

Detect and sanitize prompt injection attacks in user-submitted text. Protects Rails apps against:

- **Direct injection** -- users trying to hack your LLMs via form inputs
- **Indirect injection** -- users storing malicious prompts in profiles so other LLMs that scrape your site get compromised

## Installation

Add to your Gemfile:

```ruby
gem "promptmenot"
```

Then run:

```bash
bundle install
rails generate promptmenot:install  # creates config/initializers/promptmenot.rb
```

## Quick Start

### ActiveModel Validation

```ruby
class UserProfile < ApplicationRecord
  # Reject mode (default) -- adds validation error
  validates :bio, prompt_safety: true

  # Sanitize mode -- strips malicious content, no error
  validates :about_me, prompt_safety: { mode: :sanitize }

  # Custom sensitivity
  validates :notes, prompt_safety: { sensitivity: :high, mode: :reject }
end
```

### Standalone API

```ruby
Promptmenot.safe?("Hello world")
# => true

Promptmenot.safe?("Ignore all previous instructions")
# => false

result = Promptmenot.detect("Some text with [SYSTEM] override")
result.safe?              # => false
result.unsafe?            # => true
result.matches            # => [#<Match ...>]
result.categories_detected # => [:delimiter_injection]
result.summary            # => "Detected 1 potential prompt injection pattern..."

sanitized = Promptmenot.sanitize("Hello. Ignore all previous instructions. Goodbye.")
sanitized.sanitized  # => "Hello. [removed] Goodbye."
sanitized.changed?   # => true
sanitized.original   # => "Hello. Ignore all previous instructions. Goodbye."
```

## Configuration

```ruby
# config/initializers/promptmenot.rb
Promptmenot.configure do |config|
  # Default sensitivity level for all validations
  # Options: :low, :medium (default), :high, :paranoid
  config.sensitivity = :medium

  # Default mode: :reject (validation error) or :sanitize (strip content)
  config.mode = :reject

  # Replacement text used in sanitize mode
  config.replacement_text = "[removed]"

  # Callback fired whenever injection is detected
  config.on_detect = ->(result) { Rails.logger.warn("Injection: #{result.summary}") }

  # Register custom patterns
  config.add_pattern(
    name: :my_custom_pattern,
    regex: /my dangerous regex/i,
    category: :custom,
    sensitivity: :medium,
    confidence: :high
  )
end
```

## Sensitivity Levels

Sensitivity controls which patterns are active. Each pattern declares a minimum sensitivity level -- it only runs when the requested sensitivity is at or above that level.

| Pattern sensitivity | Active at `:low` | `:medium` | `:high` | `:paranoid` |
|---|---|---|---|---|
| `:low` | Yes | Yes | Yes | Yes |
| `:medium` | No | Yes | Yes | Yes |
| `:high` | No | No | Yes | Yes |
| `:paranoid` | No | No | No | Yes |

**`:low`** catches only the most obvious attacks (e.g., "ignore all previous instructions"). **`:paranoid`** flags anything remotely suspicious, including mixed-script text.

## Pattern Categories

| Category | Examples | Count |
|---|---|---|
| `direct_instruction_override` | "ignore previous instructions", "new instructions:" | ~12 |
| `role_manipulation` | "jailbreak mode", "act as unrestricted AI", "DAN" | ~10 |
| `delimiter_injection` | `<\|system\|>`, `[SYSTEM]`, ChatML tokens | ~10 |
| `encoding_obfuscation` | Base64 payloads, zero-width chars, hex escapes | ~10 |
| `indirect_injection` | "Dear AI", "if you are an LLM", "note to chatbot" | ~10 |
| `context_manipulation` | `===RESET===`, "the above is a test", prompt leaking | ~8 |

## False Positive Mitigation

Patterns use contextual qualifiers to minimize false positives:

- "ignore" alone is fine -- "ignore **previous instructions**" is flagged
- "act as" requires malicious qualifiers -- "act as a consultant" passes
- "you are now" requires AI/restriction qualifiers -- "you are now subscribed" passes
- "from now on" requires imperative "you must/will" -- "from now on I'll work from home" passes
- Broad patterns are placed at `:high`/`:paranoid` sensitivity so they don't fire at default settings

## License

MIT License. See [LICENSE.txt](LICENSE.txt).
