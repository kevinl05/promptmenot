# PromptMeNot

[![Build Status](https://github.com/kevinl05/promptmenot/actions/workflows/ci.yml/badge.svg)](https://github.com/kevinl05/promptmenot/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/promptmenot.svg)](https://rubygems.org/gems/promptmenot)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ruby 3.0+](https://img.shields.io/badge/Ruby-3.0%2B-red.svg)](https://www.ruby-lang.org/)

Detect and sanitize prompt injection attacks in Rails apps. Protects against direct injection (users hacking your LLMs via form inputs) and indirect injection (malicious prompts stored in user content for other LLMs to scrape). ~60 detection patterns across 6 attack categories with configurable sensitivity levels.

---

### What it catches

| Attack type | Description |
|---|---|
| **Direct injection** | Users trying to override LLM instructions via form inputs (e.g., "ignore all previous instructions") |
| **Indirect injection** | Malicious prompts stored in profiles, comments, or posts that target LLMs scraping or processing your site |
| **Delimiter attacks** | Fake system tokens, ChatML tags, and XML/markdown boundaries injected into text |
| **Obfuscation** | Base64-encoded payloads, zero-width characters, hex escapes, and other encoding tricks |

### What it doesn't do

> PromptMeNot is a **supplemental defense layer**, not a silver bullet.

It uses pattern matching to catch known injection techniques, which means:

- **It can be bypassed.** Sufficiently creative or novel attacks may evade detection. Prompt injection is an evolving problem and no regex-based approach will catch everything.
- **It's not a replacement for other safeguards.** You should still use system prompts with clear boundaries, output filtering, least-privilege API access, and human review where appropriate.
- **It won't prevent all LLM misuse.** It focuses on the input side. It doesn't monitor or constrain what your LLM outputs.

Think of it like input validation for SQL injection: you still use parameterized queries, but rejecting `'; DROP TABLE users--` at the front door doesn't hurt. PromptMeNot is that front door check for prompt injection.

### Defense in depth

For production apps, pair PromptMeNot with other layers:

| Layer | What to do |
|---|---|
| **Structural isolation** | Wrap user input in XML delimiters (`<user_input>...</user_input>`) so the LLM treats it as data, not instructions |
| **System prompt design** | Explicitly tell the model to ignore instructions found inside user content |
| **Output validation** | Check LLM responses for leaked system prompts, PII, or unexpected behavior before returning them to users |
| **Least-privilege access** | Restrict what your LLM can do (read-only DB access, scoped API keys, no `eval`) |

PromptMeNot handles the fast, cheap first pass. It catches the known attacks before they cost you an API call. The layers above handle the rest.

---

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
  # Reject mode (default) — adds validation error
  validates :bio, prompt_safety: true

  # Sanitize mode — strips malicious content, no error
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

Sensitivity controls which patterns are active. Each pattern declares a minimum sensitivity level and only runs when the requested sensitivity is at or above that level.

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

- "ignore" alone is fine, but "ignore **previous instructions**" is flagged
- "act as" requires malicious qualifiers, so "act as a consultant" passes
- "you are now" requires AI/restriction qualifiers, so "you are now subscribed" passes
- "from now on" requires imperative "you must/will", so "from now on I'll work from home" passes
- Broad patterns are placed at `:high`/`:paranoid` sensitivity so they don't fire at default settings

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Setting up development environment
- Running tests and linting
- Adding new patterns
- Reporting issues

## License

MIT License. See [LICENSE.txt](LICENSE.txt).
