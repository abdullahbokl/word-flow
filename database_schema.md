# Word-Flow Database Schema

This diagram visualizes the relationships between the different tables in the `word-flow` local database.

```mermaid
erDiagram
    Words {
        int id PK
        string word UNIQUE
        int frequency
        bool isKnown
        datetime createdAt
        datetime updatedAt
        string meaning OPTIONAL
        string description OPTIONAL
    }

    AnalyzedTexts {
        int id PK
        string title
        string content
        int totalWords
        int uniqueWords
        datetime createdAt
    }

    TextWordEntries {
        int textId FK
        int wordId FK
        int localFrequency
    }

    Words ||--o{ TextWordEntries : "appears in"
    AnalyzedTexts ||--o{ TextWordEntries : "contains"
```

### **Table Definitions**

1.  **Words**: Stores unique vocabulary items across all texts.
    *   `meaning` and `description` are new optional fields for user notes.
    *   `frequency` tracks how many times the word has appeared across all analyzed texts.
    *   `isKnown` marks if the user has mastered the word.

2.  **AnalyzedTexts**: Stores the source text that was processed.
    *   Acts as a history record for previous searches and readings.

3.  **TextWordEntries**: A junction table linking Words to the AnalyzedTexts they belong to.
    *   `localFrequency` tracks how many times a word appeared in a *specific* text.
