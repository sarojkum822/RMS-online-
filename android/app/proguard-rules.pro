# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# General
-dontwarn io.flutter.**
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }

# Gson (if used transitively or directly)
-keep class com.google.gson.** { *; }
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.stream.** { *; }

# Prevent TypeToken obfuscation
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.common.reflect.TypeToken { *; }
-keep class * extends com.google.common.reflect.TypeToken

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-keep public class com.google.android.gms.ads.AdActivity

# Google ML Kit (Text Recognition)
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**
-keep class com.google_mlkit_text_recognition.** { *; }
