.PHONY: gen test lint clean help

help:
	@echo "WordFlow Development Commands:"
	@echo "  make gen   - Generate data models/DI/Router (build_runner)"
	@echo "  make test  - Run tests with coverage reporting"
	@echo "  make lint  - Run static analyzer"
	@echo "  make clean - Remove build artifacts and generated files"

gen:
	@echo "Generating boilerplate..."
	dart run build_runner build --delete-conflicting-outputs

test:
	@echo "Running tests with coverage..."
	flutter test --coverage

lint:
	@echo "Analyzing codebase..."
	flutter analyze --no-fatal-infos

clean:
	@echo "Cleaning project..."
	flutter clean
	rm -rf coverage/
	find . -name "*.g.dart" -delete
	find . -name "*.freezed.dart" -delete
	find . -name "*.config.dart" -delete
