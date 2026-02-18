# Contributing to Promptmenot

We'd love your help improving Promptmenot! Here's how to contribute:

## Development Setup

```bash
git clone https://github.com/promptmenot/promptmenot.git
cd promptmenot
bundle install
```

## Running Tests

```bash
# Run full test suite
bundle exec rspec

# Run specific test file
bundle exec rspec spec/promptmenot/detector_spec.rb

# Run with coverage
bundle exec rspec --coverage
```

## Code Quality

```bash
# Run RuboCop linter
bundle exec rubocop

# Auto-fix offenses
bundle exec rubocop -a
```

## Making Changes

1. **Fork** the repository on GitHub
2. **Create a branch** for your feature: `git checkout -b feature/my-feature`
3. **Make your changes** and add tests
4. **Ensure all tests pass**: `bundle exec rspec`
5. **Ensure code is clean**: `bundle exec rubocop -a`
6. **Commit** with clear messages: `git commit -am 'Add new pattern for X'`
7. **Push** to your fork: `git push origin feature/my-feature`
8. **Open a PR** on GitHub

## Adding New Patterns

New injection attack patterns go in `lib/promptmenot/patterns/`.

See existing pattern files for the DSL. Each pattern registers with:
- `name` — unique identifier
- `regex` — detection pattern
- `sensitivity` — `:low`, `:medium`, `:high`, or `:paranoid`
- `confidence` — `:high`, `:medium`, or `:low`

Always include tests in `spec/promptmenot/patterns/`.

## Reporting Issues

Found a bug or have a suggestion? Open an issue on GitHub with:
- Clear description of the problem
- Steps to reproduce (if applicable)
- Expected vs. actual behavior
- Ruby/Rails version info

## License

All contributions are made under the MIT license.
