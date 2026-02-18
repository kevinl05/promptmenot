# Agents Reference Guide

This document provides operational knowledge for AI agents and developers working on PromptMeNot.

## Project Overview

- **Project Name:** PromptMeNot
- **Type:** Ruby gem (Rails plugin)
- **Framework:** ActiveModel / ActiveSupport (>= 6.0)
- **Language:** Ruby >= 3.0
- **Package Manager:** Bundler
- **Test Framework:** RSpec
- **Linter:** RuboCop

---

## Getting Started

```bash
# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Run linter
bundle exec rubocop
```

---

## Build & Release

### Build the Gem

```bash
# Build .gem file
gem build promptmenot.gemspec

# Install locally for testing
gem install promptmenot-*.gem
```

### Release

```bash
# Bump version in lib/promptmenot/version.rb, then:
gem build promptmenot.gemspec
gem push promptmenot-*.gem
```

---

## Architecture

### Pattern System

Patterns are registered via a DSL in `lib/promptmenot/patterns/*.rb`. Each pattern declares:
- **name** — unique identifier
- **category** — which pattern category it belongs to
- **regex** — the detection regex
- **sensitivity** — minimum sensitivity level to activate (`:low`, `:medium`, `:high`, `:paranoid`)
- **confidence** — how confident the match is (`:high`, `:medium`, `:low`)

### Sensitivity Levels (Filter-Based)

Each pattern declares its minimum sensitivity. At runtime, only patterns at or below the requested level are active:

| Pattern sensitivity | Active at :low | :medium | :high | :paranoid |
|---|---|---|---|---|
| :low | Yes | Yes | Yes | Yes |
| :medium | No | Yes | Yes | Yes |
| :high | No | No | Yes | Yes |
| :paranoid | No | No | No | Yes |

### Detection Flow

1. `Detector` receives text + sensitivity level
2. `PatternRegistry` filters patterns by sensitivity
3. Each pattern's regex runs against the text
4. Overlapping matches are deduplicated
5. `Result` object is returned (safe?/unsafe?, matches, categories)

### Modes

- **reject** — adds ActiveModel validation error (default)
- **sanitize** — strips matched content from the field value

---

## Common Scripts Reference

```bash
# Development
bundle install               # Install dependencies
bundle console               # Open IRB with gem loaded (if configured)

# Testing
bundle exec rspec            # Run full test suite
bundle exec rspec spec/promptmenot/detector_spec.rb  # Run single spec

# Linting
bundle exec rubocop          # Run linter
bundle exec rubocop -a       # Auto-fix offenses
```

---

## Key File Locations

| File | Purpose |
|---|---|
| `lib/promptmenot.rb` | Root entry point, convenience API |
| `lib/promptmenot/version.rb` | Gem version |
| `lib/promptmenot/configuration.rb` | Global config DSL |
| `lib/promptmenot/detector.rb` | Core detection engine |
| `lib/promptmenot/sanitizer.rb` | Content sanitization |
| `lib/promptmenot/validator.rb` | ActiveModel validator |
| `lib/promptmenot/pattern_registry.rb` | Central pattern registry |
| `lib/promptmenot/patterns/` | All pattern category definitions |
| `lib/promptmenot/railtie.rb` | Rails auto-config |
| `config/locales/en.yml` | I18n error messages |
| `promptmenot.gemspec` | Gem specification |
| `spec/` | All test specs |

---

## Troubleshooting

### Bundle Install Fails

**Symptom:** Dependency resolution errors

```bash
# Remove lockfile and retry
rm Gemfile.lock && bundle install
```

### RSpec Can't Find Patterns

**Symptom:** Tests pass but no patterns are detected

Check that all pattern files in `lib/promptmenot/patterns/` are required in `lib/promptmenot.rb`.

---

## Related Documentation

- `README.md` - Usage examples, configuration guide, pattern reference
- `CHANGELOG.md` - Version history
