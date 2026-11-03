# Razorpay — Direct UPI (customui-core) and standard checkout.
#
# STATUS NOTE (playbook 1.4): this module currently builds release with
# `minifyEnabled false`, so R8 does NOT run and these rules are dormant today.
# The moment minification is switched on they become load-bearing on the money path.
# Confirm with: ls -la build/app/outputs/mapping/release/mapping.txt
-keep class com.razorpay.** { *; }
-keepattributes JavascriptInterface
-keepclasseswithmembers class * {
    public void onPayment*(...);
}
-dontwarn com.razorpay.**
-keep class proguard.annotation.** { *; }
-dontwarn proguard.annotation.**