# **Project Overview: WordFlow**

**WordFlow** is a specialized vocabulary-building application designed for language learners who consume video content. It automates the process of extracting, counting, and tracking new English words from video scripts.

---

## **Getting Started**

### **Prerequisites**
- **Flutter:** 3.19.0 or later (install from [flutter.dev](https://flutter.dev/docs/get-started/install))
- **Dart:** 3.10.0+ (included with Flutter)

### **1. Clone the Repository**
```bash
git clone https://github.com/abdullahbokl/word-flow.git
cd word-flow
```

### **2. Install Dependencies**
```bash
flutter pub get
```

### **3. Generate Code (Build Runner)**
```bash
dart run build_runner build --delete-conflicting-outputs
```

Or use the Makefile:
```bash
make gen
```

### **4. Run the App**
Using Makefile (recommended):
```bash
make run
```

Or manually:
```bash
flutter run
```

### **5. Run Tests**
```bash
make test
```

**Test Coverage Reports:**
- Location: `coverage/lcov.info`
- View in browser: `genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html`

### **6. Build for Release**

**Android APK:**
```bash
make build-android
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**iOS App (no code signing):**
```bash
make build-ios
# Output: build/ios/Release-iphoneos/Runner.app
```

### **Makefile Commands Reference**
```bash
make help              # Show all available commands
make run               # Run app
make gen               # Generate data models/DI/Router
make test              # Run tests with coverage
make lint              # Run static analyzer
make build-android     # Build release APK
make build-ios         # Build release iOS app
make clean             # Remove build artifacts
```

### **Troubleshooting**

| Error | Solution |
|-------|----------|
| `dart_define.json` not found | Run `make setup` to create it from example |
| `SUPABASE_URL is empty` | Check `dart_define.json` has correct URL (DEBUG mode will throw) |
| Build errors with generated files | Run `make clean && make gen` |
| Tests fail with coverage assertion | Target 70%+ coverage or adjust threshold in CI config |
| iOS build on non-macOS | Use `make build-ios` on macOS only; `--no-codesign` skips signing |

---

## **1. Core Logic & Features**
The application follows a **"Script-to-Lexicon"** workflow:
* **Script Ingestion:** Users paste a full video script into the app.
* **Frequency Analysis:** The app parses the text to find unique words and calculates how many times each word appears (e.g., "Development": 15 occurrences).
* **Knowledge Tracking:** Users can mark words as "Known." Once a word is marked, the app remembers this status globally.
* **Filtering:** When a new script is added, the app automatically hides words the user already knows, displaying only the "New/Unknown" vocabulary.
* **Cumulative Counting:** Word frequencies are additive. If a word appears in multiple scripts, its `total_count` increments across the entire database.

---

## **2. Technical Stack**
* **Frontend:** Flutter (Dart).
* **State Management:** BLoC / Cubit.
* **Local Storage:** SQLite (used as the primary source of truth for offline-first).
* **Functional Programming:** fpdart (Sealed classes + `Either<Failure, Success>`).
* **Structured Logging:** Talker (replacing `debugPrint`).

---

## **3. Architecture & Best Practices**
The project strictly adheres to **Clean Architecture** principles to ensure scalability and testability:
* **Domain Layer:** Contains Entities, Use Cases, and Repository Interfaces.
* **Data Layer:** Contains Repositories implementations, Data Sources (Remote/Local), and DTOs (Models).
* **Presentation Layer:** Contains UI Widgets and BLoC/Cubit logic.

### **Key Engineering Standards:**
* **Offline-First:** The app performs all read/write operations on the local SQLite database to ensure 0ms latency and complete privacy.
* **Atomic Design:** UI is built using small, reusable widgets. Helper methods that return widgets are strictly forbidden; specialized `Stateless` or `Stateful` widgets are used instead.
* **Performance:** Heavy text processing is offloaded to **Background Isolates** to maintain 60 FPS. Exit animations for list items use `AnimatedList` for a smooth user experience.


<- Chore: optimize library state management and improve the consistency of optimistic CI test: do not merge - 2026-03-30T22:10:24Z -->
