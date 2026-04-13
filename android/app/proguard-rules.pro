# Drift (Moor) rules
-keep class * extends androidx.room.RoomDatabase
-keep class * extends dd.drift.** { *; }
-dontwarn dd.drift.**

# Sqlite3 rules
-keep class org.sqlite.** { *; }
-dontwarn org.sqlite.**

# Keep models/entities
-keep class com.bocl.wordflow.features.**.data.models.** { *; }
-keep class com.bocl.wordflow.features.**.domain.entities.** { *; }

# General Flutter ProGuard rules are handled by the Flutter tool, 
# but we add specific ones for reflection-heavy libraries.

# Freezed/JsonSerializable
-keep class * implements java.io.Serializable { *; }
-keepclassmembers class * {
    @json_serializable.JsonSerializable *;
}
