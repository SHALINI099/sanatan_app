import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:posterapp/core/database/BharatStorage.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../view/verify_payment_page.dart';

class RazorPayViewModel extends GetxController {
  late Razorpay razorPay;

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    Get.to(() => const VerifyPaymentPage())?.then((_) {
      Fluttertoast.showToast(
          msg: "Payment Success", gravity: ToastGravity.CENTER);
      BharatStorage.setSubscriptionId("");
    });
  }

  void handlePaymentError(PaymentFailureResponse response) {
    // Backing out of the checkout sheet arrives here as an ERROR, not as a distinct
    // "cancelled" event. Sending that user to "Verifying Payment" is wrong twice over: no
    // payment was ever attempted, so the page polls a subscription that cannot change, and
    // the user is stuck watching a spinner for something they deliberately dismissed.
    // Straight back to the paywall instead.
    if (response.code == Razorpay.PAYMENT_CANCELLED) {
      Fluttertoast.showToast(
          msg: "Payment cancelled", gravity: ToastGravity.CENTER);
      return;
    }

    // Any OTHER failure still verifies. A client-side error (network drop, TLS) can land
    // after the mandate was actually authorised, so the server is still the authority.
    Get.to(() => const VerifyPaymentPage())?.then((_) {
      Fluttertoast.showToast(
          msg: "Payment Failed", gravity: ToastGravity.CENTER);
    });
  }

  void handleExternalWallet(ExternalWalletResponse response) {}

  void openCheckout(String subscriptionId, String rzpKey, String planId) async {
    var options = {
      'key': rzpKey,
      'subscription_id': subscriptionId,
      'description': planId,
      'recurring': true,
      'prefill': {
        'contact': BharatStorage.getnumber() ?? "",
        'email': '${BharatStorage.getnumber()!}@om shanti.app'
      },
      'method': ['upi', 'wallet', 'card', 'netbanking'],
      'upi': {
        'flow': 'intent',
        'apps': [
          'com.google.android.apps.nbu.paisa.user',
          'net.one97.paytm',
          'com.phonepe.app'
        ]
      }
    };
    try {
      razorPay.open(options);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}