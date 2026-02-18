# Changelog

## [0.1.0] - 2026-02-17

### Added

- Core detection engine with 6 pattern categories (~60 patterns)
  - Direct instruction override
  - Role manipulation
  - Delimiter injection
  - Encoding obfuscation
  - Indirect injection
  - Context manipulation
- Filter-based sensitivity levels: `:low`, `:medium`, `:high`, `:paranoid`
- Two operating modes: `:reject` (validation error) and `:sanitize` (strip content)
- ActiveModel validator (`prompt_safety`)
- Standalone API (`Promptmenot.safe?`, `.detect`, `.sanitize`)
- Global configuration DSL with custom pattern support
- Detection callbacks
- Rails generator (`rails g promptmenot:install`)
- I18n support for error messages
