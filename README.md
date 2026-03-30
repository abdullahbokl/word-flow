# **Project Overview: WordFlow**

**WordFlow** is a specialized vocabulary-building application designed for language learners who consume video content. It automates the process of extracting, counting, and tracking new English words from video scripts.

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
* **Backend:** Supabase (PostgreSQL + Auth).
* **API Client:** Supabase Client for all remote operations (replaces Dio).
* **Functional Programming:** fpdart (Sealed classes + `Either<Failure, Success>`).
* **Error Reporting:** Sentry (integrated into Auth and Sync flows).
* **Structured Logging:** Talker (replacing `debugPrint`).

---

## **3. Architecture & Best Practices**
The project strictly adheres to **Clean Architecture** principles to ensure scalability and testability:
* **Domain Layer:** Contains Entities, Use Cases, and Repository Interfaces.
* **Data Layer:** Contains Repositories implementations, Data Sources (Remote/Local), and DTOs (Models).
* **Presentation Layer:** Contains UI Widgets and BLoC/Cubit logic.

### **Key Engineering Standards:**
* **Offline-First:** The app performs all read/write operations on the local SQLite database first to ensure 0ms latency and offline availability.
* **Background Sync:** Local data is synchronized with Supabase in the background when an internet connection is available.
* **Atomic Design:** UI is built using small, reusable widgets. Helper methods that return widgets are strictly forbidden; specialized `Stateless` or `Stateful` widgets are used instead.
* **Performance:** Heavy text processing is offloaded to **Background Isolates** to maintain 60 FPS. Exit animations for list items use `AnimatedList` for a smooth user experience.

---

## **4. The "Guest-to-Auth" Workflow**
* **Guest Mode:** New users can fully use the app. Data is stored locally with a `null` or `GUEST` user ID.
* **Onboarding/Migration:** When a user creates an account, a migration service moves all local records to the Supabase cloud, linking them to the new User ID. This ensures users never lose their vocabulary progress.

<- Chore: optimize library state management and improve the consistency of optimistic CI test: do not merge - 2026-03-30T22:10:24Z -->
