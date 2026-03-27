# WordFlow performance benchmark (repeatable)

## Goal
Make jank regressions obvious and easy to reproduce while iterating.

## Scenario A: Large script analysis
- Run in profile mode on a physical device:

```bash
flutter run --profile
```

- Enable the performance overlay in Flutter inspector (or add `showPerformanceOverlay: true` temporarily in `MaterialApp` when debugging).
- Paste a large script (aim for 10k–50k tokens / several pages).
- Tap **Analyze**.

**Watch for**
- Long “UI thread” spikes during/after analysis (should be mostly isolate + background DB work now).
- Frame build/raster bars staying mostly under budget.

## Scenario B: Rapid optimistic toggles
- After Scenario A results render, quickly mark 50–200 words as known.

**Watch for**
- Tap-to-animation latency (should stay crisp).
- No hitching when many writes are queued.

## Scenario C: Library scroll
- Open **Library**.
- Scroll from top → bottom → top quickly.

**Watch for**
- Smooth scroll with minimal frame drops.
- No periodic stutter (polling-based “streams” were removed).

## Scenario D: Sync queue badge responsiveness (authenticated user)
- Sign in.
- Trigger some local changes (toggle known / add / delete).

**Watch for**
- Pending count updates immediately (reactive queue count).
- Sync action clears the queue without UI polling.

