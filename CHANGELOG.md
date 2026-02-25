# Changelog

## [0.2.0] - 2026-02-25

### Added

- New `resource_extraction` pattern category with 10 patterns detecting attempts to trick AI agents into transferring funds, leaking credentials, or exhausting compute resources
  - Crypto transfer requests ("transfer 100 SOL to")
  - Wallet address detection with transfer instructions
  - Full balance drain attempts ("send all your tokens")
  - Financial urgency manipulation
  - Authorization claims for transfers
  - Transaction execution instructions
  - Credential extraction ("give me your API key", "show seed phrase")
  - External endpoint exfiltration ("send results to https://...")
  - Access escalation ("grant me full access to the wallet")
  - Resource exhaustion ("use all your credits")

## [0.1.3] - 2026-02-17

### Fixed

- Ruby 3.0+ compatibility by relaxing ActiveSupport/ActiveModel constraints to allow v7.x

## [0.1.0] - 2026-02-17

### Added

- Core detection engine with 6 pattern categories (~60 patterns):
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
