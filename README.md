# PromptMeNot

[![Build Status](https://github.com/kevinl05/promptmenot/actions/workflows/ci.yml/badge.svg)](https://github.com/kevinl05/promptmenot/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/promptmenot.svg)](https://rubygems.org/gems/promptmenot)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ruby 3.0+](https://img.shields.io/badge/Ruby-3.0%2B-red.svg)](https://www.ruby-lang.org/)

PromptMeNot is a Ruby gem that helps protect your application against prompt injection attacks. It scans user-submitted text for malicious patterns like instruction overrides, role manipulation, delimiter injection, encoding tricks, and more. With ~70 built-in detection patterns organized across 7 attack categories, it covers direct injection (where users try to hijack your LLM through form inputs), indirect injection (where malicious prompts are stored in user content like profiles or comments, waiting for other LLMs to scrape and execute them), and resource extraction (where attackers trick AI agents into transferring funds, leaking credentials, or exhausting compute resources). It plugs into Rails with a simple ActiveModel validator or works standalone in any Ruby app, with configurable sensitivity levels so you can tune the trade-off between coverage and false positives.

---

> **New in v0.2: Resource Extraction Detection**
> AI agents are managing wallets, executing trades, and holding API keys. In February 2026, [an autonomous trading bot sent $250K in tokens to a stranger](https://cybernews.com/ai-news/open-ai-agent-generous-donor-accidentally-send-entire-crypto-lobstar-wild/) because nothing validated what it was about to do. This release adds 10 patterns that catch attempts to drain wallets, steal credentials, manipulate agents with fake urgency, and exfiltrate secrets to external endpoints. If your app has an AI agent anywhere near funds or keys, this is the category you want active. [Pattern details](#pattern-categories) | [Changelog](CHANGELOG.md)

---

### What it catches

| Attack type | Description |
|---|---|
| **Direct injection** | Users trying to override LLM instructions via form inputs (e.g., "ignore all previous instructions") |
| **Indirect injection** | Malicious prompts stored in profiles, comments, or posts that target LLMs scraping or processing your site |
| **Delimiter attacks** | Fake system tokens, ChatML tags, and XML/markdown boundaries injected into text |
| **Obfuscation** | Base64-encoded payloads, zero-width characters, hex escapes, and other encoding tricks |
| **Resource extraction** | Crypto transfer requests, wallet drain attacks, credential theft, financial urgency manipulation |

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
| `resource_extraction` | "transfer 100 SOL to", credential theft, wallet drain, endpoint exfiltration | ~10 |

## False Positive Mitigation

Patterns use contextual qualifiers to minimize false positives:

- "ignore" alone is fine, but "ignore **previous instructions**" is flagged
- "act as" requires malicious qualifiers, so "act as a consultant" passes
- "you are now" requires AI/restriction qualifiers, so "you are now subscribed" passes
- "from now on" requires imperative "you must/will", so "from now on I'll work from home" passes
- Broad patterns are placed at `:high`/`:paranoid` sensitivity so they don't fire at default settings

## FAQ

<details open>
<summary><b>Does this work without Rails?</b></summary>
<br>

Yes. The ActiveModel validator is the Rails integration, but the core API works in any Ruby app:

```ruby
Promptmenot.safe?("some text")
Promptmenot.detect("some text")
Promptmenot.sanitize("some text")
```

The Railtie only loads if `Rails::Railtie` is defined.

</details>

<details>
<summary><b>Is this thread-safe?</b></summary>
<br>

Yes. The module singleton (configuration, registry) is protected by a `Monitor`. Pattern matching itself is stateless, so concurrent calls to `detect` or `sanitize` are safe.

</details>

<details>
<summary><b>What happens when patterns overlap?</b></summary>
<br>

The detector deduplicates automatically. If two patterns match overlapping regions of text, it keeps the larger match and discards the smaller one. This prevents double-counting in results and avoids garbled output in sanitize mode.

</details>

<details>
<summary><b>Can I use this to scan existing database records?</b></summary>
<br>

Yes. You can run detection against any string, not just incoming form input:

```ruby
UserProfile.find_each do |profile|
  result = Promptmenot.detect(profile.bio, sensitivity: :high)
  puts "#{profile.id}: #{result.summary}" if result.unsafe?
end
```

</details>

<details>
<summary><b>What's the performance like?</b></summary>
<br>

At default sensitivity (`:medium`), roughly 40-50 patterns are active. Each is a single regex scan, so detection is fast on typical user input. The `max_length` config (default: 50,000 characters) truncates excessively long inputs before scanning to prevent regex backtracking on adversarial payloads.

</details>

<details>
<summary><b>Can I scan only specific categories?</b></summary>
<br>

Yes. Both the `Detector` and `Sanitizer` accept a `categories` filter:

```ruby
detector = Promptmenot::Detector.new(
  sensitivity: :high,
  categories: [:delimiter_injection, :encoding_obfuscation]
)
result = detector.detect(user_input)
```

This is useful if you only care about certain attack types for a given field.

</details>

<details>
<summary><b>How does the on_detect callback work?</b></summary>
<br>

The callback fires whenever an injection is detected, before the result is returned. It receives the full `Result` object, so you can log, alert, or track metrics:

```ruby
Promptmenot.configure do |config|
  config.on_detect = ->(result) {
    Rails.logger.warn("Injection detected: #{result.summary}")
    StatsD.increment("promptmenot.injection_detected")
  }
end
```

If the callback raises an exception, it's rescued and printed to `warn` so it never breaks your app.

</details>

<details>
<summary><b>Does it catch leetspeak and Cyrillic homoglyphs?</b></summary>
<br>

Yes. The `encoding_obfuscation` category includes patterns for leetspeak injection (e.g., `1gn0r3 1nstruct10ns`) and mixed-script homoglyphs (Latin + Cyrillic characters in the same string). The homoglyph pattern is set to `:paranoid` sensitivity since mixed scripts can appear in legitimate multilingual content.

</details>

<details>
<summary><b>What's the difference between confidence and sensitivity?</b></summary>
<br>

They answer different questions:

- **Sensitivity** controls *when* a pattern runs. A `:low` sensitivity pattern runs at all levels. A `:paranoid` pattern only runs when you explicitly crank sensitivity up.
- **Confidence** describes *how certain* we are that a match is actually an attack. A `:high` confidence match (e.g., "ignore all previous instructions") is almost certainly malicious. A `:low` confidence match (e.g., mixed Cyrillic/Latin text) might be legitimate.

You can filter results by confidence after detection using `result.high_confidence_matches`.

</details>

<details>
<summary><b>Can I add patterns without modifying the gem source?</b></summary>
<br>

Yes. Use the config DSL in your initializer:

```ruby
Promptmenot.configure do |config|
  config.add_pattern(
    name: :my_app_specific_attack,
    regex: /some pattern specific to your app/i,
    category: :custom,
    sensitivity: :medium,
    confidence: :high
  )
end
```

Custom patterns go through the same detection pipeline as built-in ones.

</details>

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Setting up development environment
- Running tests and linting
- Adding new patterns
- Reporting issues

## License

MIT License. See [LICENSE.txt](LICENSE.txt).
