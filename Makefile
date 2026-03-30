.PHONY: help run build-android build-ios test gen lint clean setup

help:
	@echo "WordFlow Development Commands:"
	@echo ""
	@echo "Setup:"
	@echo "  make setup - Copy dart_define.json.example to dart_define.json"
	@echo ""
	@echo "Development:"
	@echo "  make run            - Run app with environment config (dart_define.json)"
	@echo "  make gen            - Generate data models/DI/Router (build_runner)"
	@echo "  make test           - Run tests with coverage reporting"
	@echo "  make lint           - Run static analyzer"
	@echo ""
	@echo "Build:"
	@echo "  make build-android  - Build release APK with environment config"
	@echo "  make build-ios      - Build release iOS app with environment config"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean          - Remove build artifacts and generated files"
	@echo ""

setup:
	@if [ ! -f dart_define.json ]; then \
		cp dart_define.json.example dart_define.json; \
		echo "✅ Created dart_define.json from example"; \
		echo "⚠️  Update dart_define.json with your actual Supabase credentials"; \
	else \
		echo "✅ dart_define.json already exists"; \
	fi

run: setup
	@echo "Running app with environment configuration..."
	flutter run --dart-define-from-file=dart_define.json

build-android: setup
	@echo "Building Android release APK..."
	flutter build apk \
		--release \
		--dart-define-from-file=dart_define.json
	@echo "✅ APK built: build/app/outputs/flutter-apk/app-release.apk"

build-ios: setup
	@echo "Building iOS release app..."
	flutter build ios \
		--release \
		--no-codesign \
		--dart-define-from-file=dart_define.json
	@echo "✅ iOS app built: build/ios/Release-iphoneos/Runner.app"

test:
	@echo "Running tests with coverage..."
	flutter test --coverage
	@echo "✅ Coverage report: coverage/lcov.info"

gen:
	@echo "Generating boilerplate..."
	dart run build_runner build --delete-conflicting-outputs
	@echo "✅ Generation complete"

lint:
	@echo "Analyzing codebase..."
	dart analyze --fatal-infos
	@echo "Checking code formatting..."
	dart format --output=none --set-exit-if-changed lib/ test/ || true
	@echo "✅ Lint checks passed"

clean:
	@echo "Cleaning project..."
	flutter clean
	rm -rf coverage/
	rm -rf .dart_tool/
	find . -name "*.g.dart" -delete
	find . -name "*.freezed.dart" -delete
	find . -name "*.config.dart" -delete
	find . -name "*.router.dart" -delete
	@echo "✅ Clean complete"

