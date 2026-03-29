# WordFlow Synchronization Strategy

WordFlow uses an **offline-first, bidirectional synchronization** system with **Last-Write-Wins (LWW)** conflict resolution to ensure data consistency across multiple devices.

## 1. Conflict Resolution (LWW)
In a distributed system, conflicts occur when the same record is modified on different devices. WordFlow resolves these using the `last_updated` timestamp.

### Remote (Push-Sync)
When a client pushes an update to Supabase, it calls a stored procedure `upsert_word_lww`.
- **Rule**: An update is only applied if `incoming.last_updated > existing.last_updated`.
- **Implementation**: Handled via PostgreSQL `ON CONFLICT DO UPDATE` with a `WHERE` clause.

### Local (Pull-Sync)
When a client fetches updates from remote:
- **Rule**: Local record is only overwritten if `remote.last_updated > local.last_updated`.
- **Fallback**: If the local version is newer (Device B made a local edit while Device A's update was syncing), the remote change is ignored locally until Device B pushes its newer version.

## 2. Merging Semantics
Beyond timestamps, specific fields have custom merge rules:
- **`total_count`**: Historically additive. During local merges (like adopt-guest), counts are summed. During sync, LWW applies.
- **`is_known`**: Logical OR. If a word is marked as known on any device, it is considered known globally.

## 3. Pull Sync Delta Fetching
To minimize bandwidth, clients track a `lastPullTimestamp` per user.
- **Initial Sync**: Fetches all words for the user.
- **Delta Sync**: Fetches only words where `last_updated >= lastPullTimestamp`.
- **Note**: `shared_preferences` is used to persist these timestamps locally.

## 4. Loop Prevention
Local updates triggered by a Pull Sync **MUST NOT** be added to the `word_sync_queue`. This prevents an infinite loop where Device A's pull triggers a push, which Device B then pulls, and so on.

## 5. Security
- **Row-Level Security (RLS)**: Enforced on Supabase to ensure users can only read/write their own `user_id` rows.
- **Auth Guards**: Synchronisation is only active for authenticated users. Guest data is stored locally with a `null` `user_id`.
