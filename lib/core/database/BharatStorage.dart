
import 'package:get_storage/get_storage.dart';


class BharatStorage {
  static String IdentityToken = "identification_token";
  static String auth = "auth_token";
  static String name = "name";
  static String number = "mobile_number";
  static String Avatar = "avatar";
  static String Desc = "desc";
  static String partyMember = 'partyMember';
  static String date = 'date';
  static String subId = 'subId';

  static String isOnboarding = "is_onboarding";
  static String address = "address";
  static String facebookId = "facebookId";
  static String twitterId = "twitterId";
  static String isSubscribed = "isSubscribed";
  static String razorPaySubscriptionId = "razorPaySubscriptionId";
  static String subscriptionData = "subscriptionData";
  static String subscriptionIdPhonepe = "subscriptionId";
  static String transactionIdPhonepe = "transactionId";
  static String merchantSubscriptionId = "merchantSubscriptionId";
  static String paymentType = "paymentType";
  static String paymentAmount = "paymentAmount";
  static String trial = 'trial';
  static String apiKey = "apiKey";
  static String secretKey = "secretKey";
  static String language = "language";

  static GetStorage storage = GetStorage();

  ///address
  static setAddress(String aa) async {
    await storage.write(address, aa);
  }

  static String? getAddress() {
    return storage.read(address);
  }
  static setDate(String Date) async {
    await storage.write(date, Date);
  }

  static String? getDate() {
    return storage.read(date);
  }
  static setApi(String api) async {
    await storage.write(apiKey, api);
  }

  static String? getApi() {
    return storage.read(apiKey);
  }
  ///user razor Pay SubscriptionId
  /// subscription id
  static setSubscriptionId(String sub) async {
    await storage.write(subId, sub);
  }

  static String? getSubscriptionId() {
    return storage.read(subId);
  }

  static setSecret(String api) async {
    await storage.write(secretKey, api);
  }

  static String? getSecret() {
    return storage.read(secretKey);
  }
  ///facebook
  static setFacebookId(String facebook) async {
    await storage.write(facebookId, facebook);
  }

  static String? getFacebookId() {
    return storage.read(facebookId);
  }

  static setUserDesc(String desc) async {
    await storage.write(Desc, desc);
  }

  static String? getUserDesc() {
    return storage.read(Desc);
  }

  ///twitter
  static setTwitterId(String twitter) async {
    await storage.write(twitterId, twitter);
  }

  static String? getTwitterId() {
    return storage.read(twitterId);
  }



  ///identify token
  static setUserInfoKey(String Token) async {
    await storage.write(IdentityToken, Token);
  }

  static String? getUserInfoKey() {
    return storage.read(IdentityToken);
  }

  ///auth token
  static setAuthKey(String AuthToken) async {
    await storage.write(auth, AuthToken);
  }

  static String? getAuthKey() {
    return storage.read(auth);
  }

  ///user number
  static setnumber(String mobNum) async {
    await storage.write(number, mobNum);
  }

  static String? getnumber() {
    return storage.read(number);
  }



  ///user razor Pay SubscriptionId
  static setRazorPaySubscriptionId(String id) async {
    await storage.write(razorPaySubscriptionId, id);
  }

  static String? getRazorPaySubscriptionId() {
    return storage.read(razorPaySubscriptionId);
  }

  ///username
  static setUserName(String Name) async {
    await storage.write(name, Name);
  }

  static String? getUserName() {
    return storage.read(name);
  }

  ///image
  static setUserImage(String img) async {
    await storage.write(Avatar, img);
  }

  static String? getUserImage() {
    return storage.read(Avatar);
  }


  ///onboarding
  static setOnboarded(bool onboard) async {
    await storage.write(isOnboarding, onboard);
  }

  static bool? getOnboarded() {
    return storage.read(isOnboarding);
  }

  static eraseAllData() async {
    await storage.erase();
  }

  ///user razor Pay SubscriptionId
  static setPhonePeSubscriptionId(String id) async {
    await storage.write(subscriptionIdPhonepe, id);
  }

  static String? getPhonePeSubscriptionId() {
    return storage.read(subscriptionIdPhonepe);
  }

  static setPhonePeTransactionId(String id) async {
    await storage.write(transactionIdPhonepe, id);
  }

  static String? getPhonePeTransactionId() {
    return storage.read(transactionIdPhonepe);
  }

  static setPhonePeMerchantSubscriptionId(String id) async {
    await storage.write(merchantSubscriptionId, id);
  }

  static String? getPhonePeMerchantSubscriptionId() {
    return storage.read(merchantSubscriptionId);
  }

  static setPhonePePaymentType(String id) async {
    await storage.write(paymentType, id);
  }

  static String? getPhonePePaymentType() {
    return storage.read(paymentType);
  }

  static setPhonePePaymentAmount(String id) async {
    await storage.write(paymentAmount, id);
  }

  static String? getPhonePePaymentAmount() {
    return storage.read(paymentAmount);
  }

  /// is Subscribed
  static setSubscription(bool subs) async {
    await storage.write(isSubscribed, subs);
  }

  static bool? getSubscription() {
    return storage.read(isSubscribed);
  }

  /// is Subscribed

  static setLanguage(String subs) async {
    await storage.write(language, subs);
  }

  static String? getLanguage() {
    return storage.read(language);
  }


  static setTrial(bool Trial) async {
    await storage.write(trial, Trial);
  }

  static bool? getTrial() {
    return storage.read(trial);
  }
}
