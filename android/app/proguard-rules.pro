# Stripe SDK keep rules
-keep class com.stripe.** { *; }
-dontwarn com.stripe.**

# Keep Kotlin Parcelize annotations
-keepclassmembers class ** implements android.os.Parcelable {
    public static final ** CREATOR;
}
-keep @kotlinx.parcelize.Parcelize class * { *; }
-dontwarn kotlinx.parcelize.**

# Keep annotations
-keepattributes *Annotation*
