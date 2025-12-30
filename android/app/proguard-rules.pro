# Flutter wrapper
-keep class io.flutter.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.**NativeViewAccessibilityDelegate { *; }
-keep class io.flutter.BuildConfig { *; }

# Flutter's code
-keep class io.flutter.plugin.editing.** { *; }
-keep class io.flutter.plugin.platform.** { *; }
-keep class io.flutter.plugin.common.** { *; }

# Our application classes
-keep class org.gooseprjkt.opornik.** { *; }

# Preserve native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Prevent renaming of native methods
-keepclasseswithmembernames class * {
    public static <methods>;
}

# Keep AndroidX annotations
-keep @androidx.annotation.Keep class *
-keepclassmembers @androidx.annotation.Keep class * { *; }

# Keep custom Flutter plugins if any
-keep class * extends io.flutter.plugin.common.PluginRegistry$Registrar { *; }

# Remove logging and debugging code from release builds
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

-dontwarn com.bumptech.glide.**

# Keep classes for URL launcher
-keep class androidx.browser.** { *; }

# Play Core library for dynamic feature modules / splits
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-keep interface com.google.android.play.core.tasks.** { *; }

-dontwarn com.google.android.play.core.**

# Keep Flutter's DeferredComponent and related classes
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-keep class io.flutter.embedding.android.** { *; }

# Keep Flutter's application class
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }