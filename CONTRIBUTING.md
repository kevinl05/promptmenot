# Contributing to PromptMeNot

Thanks for your interest in PromptMeNot! Whether you're adding new detection patterns, fixing bugs, or improving docs, contributions are welcome.

## Table of Contents

- [Development Setup](#development-setup)
- [Architecture Overview](#architecture-overview)
- [Adding New Patterns](#adding-new-patterns)
- [Testing](#testing)
- [Code Style](#code-style)
- [Submitting Changes](#submitting-changes)
- [Reporting Issues](#reporting-issues)

## Development Setup

```bash
git clone https://github.com/kevinl05/promptmenot.git
cd promptmenot
bundle install
```

Verify everything works:

```bash
bundle exec rake  # runs rspec + rubocop
```

**Requirements**: Ruby 3.0+, Bundler

## Architecture Overview

Understanding how detection works will help you contribute effectively:

```
Input text
  -> Detector
    -> PatternRegistry.for_sensitivity(level)
      -> Pattern.match(text)   # per pattern
    -> Deduplicate overlapping matches
    -> Result (safe/unsafe + matches)
```

**Key components:**

| File | Purpose |
|------|---------|
| `lib/promptmenot/detector.rb` | Core detection engine - scans text against active patterns |
| `lib/promptmenot/pattern.rb` | Pattern class - wraps a name, regex, sensitivity, and confidence |
| `lib/promptmenot/pattern_registry.rb` | Stores all registered patterns, filters by sensitivity level |
| `lib/promptmenot/sanitizer.rb` | Removes matched content from text (`:sanitize` mode) |
| `lib/promptmenot/validator.rb` | ActiveModel integration (`validates :field, prompt_safety: ...`) |
| `lib/promptmenot/patterns/` | Pattern definitions organized by attack category |

**Sensitivity cascade**: Patterns activate cumulatively. A `:low` pattern fires at *all* levels. A `:high` pattern only fires at `:high` and `:paranoid`. Think of it as:

```
:paranoid  ->  all patterns active
:high      ->  :low + :medium + :high
:medium    ->  :low + :medium
:low       ->  :low only
```

## Adding New Patterns

This is the most common (and most valuable) contribution. If you've found a prompt injection technique that PromptMeNot doesn't catch, here's how to add it.

### 1. Choose the right category

Patterns live in `lib/promptmenot/patterns/` and are organized by attack type:

| Category | File | Examples |
|----------|------|----------|
| Direct instruction override | `direct_instruction_override.rb` | "ignore previous instructions", "new instructions:" |
| Role manipulation | `role_manipulation.rb` | "DAN mode", "act as unrestricted AI" |
| Delimiter injection | `delimiter_injection.rb` | `<\|system\|>`, `[INST]`, fake XML/markdown headers |
| Encoding obfuscation | `encoding_obfuscation.rb` | Base64 payloads, hex escapes, zero-width chars |
| Indirect injection | `indirect_injection.rb` | "Dear AI", "if you are an LLM" |
| Context manipulation | `context_manipulation.rb` | `===RESET===`, prompt leaking attempts |
| Resource extraction | `resource_extraction.rb` | Crypto transfers, wallet drains, credential theft, endpoint exfiltration |

If your pattern doesn't fit any existing category, open an issue to discuss adding a new one.

### 2. Write the pattern

All pattern classes inherit from `Patterns::Base` and use the `register` DSL:

```ruby
# frozen_string_literal: true

module Promptmenot
  module Patterns
    class DirectInstructionOverride < Base
      register(
        name: :ignore_previous_instructions,
        regex: /\bignore\s+(all\s+)?(previous|prior|above)\s+(instructions|directives|rules)\b/i,
        sensitivity: :low,
        confidence: :high
      )
    end
  end
end
```

**Parameters:**

- **`name`** (Symbol) - Unique identifier across all patterns. Use `snake_case` describing the attack.
- **`regex`** (Regexp) - The detection pattern. Always use `\b` word boundaries to prevent substring matches. Always use the `/i` flag for case-insensitive matching.
- **`sensitivity`** (Symbol) - When this pattern activates:
  - `:low` - High-signal, almost never a false positive. Use for unambiguous injection phrases like "ignore all previous instructions".
  - `:medium` - Reasonable default. May have edge cases but generally reliable.
  - `:high` - Catches more but may flag legitimate text. Use for broader patterns like "from now on you must...".
  - `:paranoid` - Maximum coverage, higher false positive rate. Use for patterns that catch things like encoded content that *could* be legitimate.
- **`confidence`** (Symbol) - How certain we are that a match is actually an injection:
  - `:high` - The matched text is almost certainly an injection attempt.
  - `:medium` - Likely an injection, but could appear in normal text.
  - `:low` - Suspicious but may need human review.

### 3. Guidelines for good patterns

**DO:**
- Use `\b` word boundaries to anchor matches
- Use non-capturing groups `(?:...)` when you don't need captures
- Test against realistic false positives (see [Testing](#testing))
- Keep regexes readable - complex patterns should have comments
- Consider multilingual variations if applicable

**DON'T:**
- Write overly broad patterns that match normal English (e.g., don't match just "ignore" alone)
- Duplicate existing patterns - check the registry first
- Use lookbehinds/lookaheads unless necessary (they hurt performance)
- Forget the `/i` flag - injections come in all cases

### 4. Sensitivity/confidence decision guide

Ask yourself:

> "If a user submitted this text in a normal form, would it ever appear naturally?"

- **Never** (e.g., "ignore all previous instructions") -> `:low` sensitivity, `:high` confidence
- **Rarely** (e.g., "new instructions:") -> `:medium` sensitivity, `:medium` confidence
- **Sometimes** (e.g., "from now on you will") -> `:high` sensitivity, `:medium` confidence
- **Often** (e.g., encoded Base64 content) -> `:paranoid` sensitivity, `:low` confidence

## Testing

Every pattern needs tests. No exceptions.

### Running tests

```bash
# Full suite
bundle exec rspec

# Specific pattern tests
bundle exec rspec spec/promptmenot/patterns/direct_instruction_override_spec.rb

# Run a single test by line number
bundle exec rspec spec/promptmenot/patterns/direct_instruction_override_spec.rb:19
```

### Writing pattern tests

Pattern specs follow a consistent structure with two sections: **detections** (unsafe text that should be caught) and **false positive resistance** (safe text that should pass).

```ruby
# frozen_string_literal: true

RSpec.describe Promptmenot::Patterns::YourCategory do
  let(:patterns) { described_class.patterns }

  describe "pattern registration" do
    it "registers patterns" do
      expect(patterns).not_to be_empty
    end

    it "all patterns have correct category" do
      patterns.each do |pattern|
        expect(pattern.category).to eq(:your_category)
      end
    end
  end

  describe "detections" do
    [
      "your injection example here",
      "another variant of the attack",
    ].each do |injection|
      it "detects: #{injection[0..50]}" do
        result = Promptmenot.detect(injection, sensitivity: :high)
        expect(result).to be_unsafe, "Expected '#{injection}' to be detected as unsafe"
      end
    end
  end

  describe "false positive resistance" do
    [
      "Normal sentence that looks similar but is safe",
      "Another benign example using similar words",
    ].each do |safe_text|
      it "allows: #{safe_text[0..50]}" do
        result = Promptmenot.detect(safe_text, sensitivity: :medium)
        expect(result).to be_safe, "Expected '#{safe_text}' to pass but got: #{result.patterns_detected}"
      end
    end
  end
end
```

**Important testing notes:**

- Detection tests use `sensitivity: :high` to ensure patterns are active
- False positive tests use `sensitivity: :medium` (the default) to ensure safe text isn't wrongly flagged at normal settings
- The custom matchers `be_safe` and `be_unsafe` are defined in `spec/spec_helper.rb`
- Include at least 3-5 detection examples covering variations (caps, spacing, phrasing)
- Include at least 3-5 false positive examples with similar-looking but safe text
- `Promptmenot.reset!` runs automatically between tests (configured in spec_helper)

## Code Style

We use RuboCop. Run it before submitting:

```bash
bundle exec rubocop        # check
bundle exec rubocop -a     # auto-fix
```

Key conventions:

- **Frozen string literals** required in all files (`# frozen_string_literal: true`)
- **Double quotes** for strings
- **Max line length**: 120 characters (relaxed for regex patterns in pattern files)
- **Max method length**: 20 lines
- **Max class length**: 150 lines

## Submitting Changes

1. **Fork** the repository
2. **Create a branch**: `git checkout -b feature/detect-new-attack-type`
3. **Write your code and tests**
4. **Run the full suite**: `bundle exec rake`
5. **Commit** with a clear message:
   ```
   feat: add detection for [attack type]

   Adds N patterns to detect [description].
   Includes M safe-text cases for false positive resistance.
   ```
6. **Push** to your fork: `git push origin feature/detect-new-attack-type`
7. **Open a Pull Request** against `main`

### Commit message format

We loosely follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` new patterns, features, or capabilities
- `fix:` bug fixes or false positive corrections
- `docs:` documentation changes
- `test:` test-only changes
- `chore:` build, CI, or maintenance tasks

### PR checklist

Before submitting, make sure:

- [ ] All tests pass (`bundle exec rspec`)
- [ ] RuboCop is clean (`bundle exec rubocop`)
- [ ] New patterns have both detection and false-positive tests
- [ ] Sensitivity and confidence levels are justified
- [ ] No overly broad regexes that would cause false positives at `:medium`

## Reporting Issues

### Bugs

Open an issue with:

- Clear description of the problem
- Steps to reproduce
- Expected vs. actual behavior
- Ruby and Rails version (`ruby -v`, `rails -v`)
- PromptMeNot version (`Promptmenot::VERSION`)

### False Positives

If PromptMeNot is flagging legitimate text:

- Include the exact text being flagged
- The sensitivity level you're using
- Which pattern(s) matched (check `result.matches`)

### Missed Injections

If you've found an injection that gets through:

- Include the injection text
- The sensitivity level you tested at
- Bonus points if you include a PR with the fix!

## License

All contributions are made under the [MIT License](LICENSE.txt).
