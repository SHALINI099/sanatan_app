import 'package:get_storage/get_storage.dart';

/// Typed facade over [GetStorage] for every value the app persists locally.
///
/// Keys are private so the rest of the app can only reach a value through its
/// accessor pair, which keeps key spelling and value types in one place.
class BharatStorage {
  BharatStorage._();

  static const String _identityToken = 'identification_token';
  static const String _auth = 'auth_token';
  static const String _name = 'name';
  static const String _number = 'mobile_number';
  static const String _avatar = 'avatar';
  static const String _desc = 'desc';
  static const String _date = 'date';
  static const String _subId = 'subId';
  static const String _isOnboarding = 'is_onboarding';
  static const String _address = 'address';
  static const String _facebookId = 'facebookId';
  static const String _twitterId = 'twitterId';
  static const String _isSubscribed = 'isSubscribed';
  static const String _razorPaySubscriptionId = 'razorPaySubscriptionId';
  static const String _subscriptionIdPhonepe = 'subscriptionId';
  static const String _transactionIdPhonepe = 'transactionId';
  static const String _merchantSubscriptionId = 'merchantSubscriptionId';
  static const String _paymentType = 'paymentType';
  static const String _paymentAmount = 'paymentAmount';
  static const String _trial = 'trial';
  static const String _apiKey = 'apiKey';
  static const String _secretKey = 'secretKey';
  static const String _language = 'language';

  static final GetStorage _storage = GetStorage();

  static Future<void> _write(String key, Object value) =>
      _storage.write(key, value);

  static T? _read<T>(String key) => _storage.read<T>(key);

  /// Wipes every persisted value. Used on logout.
  static Future<void> eraseAllData() => _storage.erase();

  // ---- Identity & session -------------------------------------------------

  static Future<void> setUserInfoKey(String token) =>
      _write(_identityToken, token);
  static String? getUserInfoKey() => _read(_identityToken);

  static Future<void> setAuthKey(String token) => _write(_auth, token);
  static String? getAuthKey() => _read(_auth);

  static Future<void> setApi(String api) => _write(_apiKey, api);
  static String? getApi() => _read(_apiKey);

  static Future<void> setSecret(String secret) => _write(_secretKey, secret);
  static String? getSecret() => _read(_secretKey);

  static Future<void> setOnboarded(bool onboarded) =>
      _write(_isOnboarding, onboarded);
  static bool? getOnboarded() => _read(_isOnboarding);

  static Future<void> setLanguage(String code) => _write(_language, code);
  static String? getLanguage() => _read(_language);

  // ---- Profile ------------------------------------------------------------

  static Future<void> setUserName(String name) => _write(_name, name);
  static String? getUserName() => _read(_name);

  static Future<void> setnumber(String mobile) => _write(_number, mobile);
  static String? getnumber() => _read(_number);

  static Future<void> setUserImage(String url) => _write(_avatar, url);
  static String? getUserImage() => _read(_avatar);

  static Future<void> setUserDesc(String desc) => _write(_desc, desc);
  static String? getUserDesc() => _read(_desc);

  static Future<void> setAddress(String address) => _write(_address, address);
  static String? getAddress() => _read(_address);

  static Future<void> setFacebookId(String id) => _write(_facebookId, id);
  static String? getFacebookId() => _read(_facebookId);

  static Future<void> setTwitterId(String id) => _write(_twitterId, id);
  static String? getTwitterId() => _read(_twitterId);

  static Future<void> setDate(String date) => _write(_date, date);
  static String? getDate() => _read(_date);

  // ---- Subscription & payments -------------------------------------------

  static Future<void> setSubscription(bool subscribed) =>
      _write(_isSubscribed, subscribed);
  static bool? getSubscription() => _read(_isSubscribed);

  static Future<void> setTrial(bool trial) => _write(_trial, trial);
  static bool? getTrial() => _read(_trial);

  static Future<void> setSubscriptionId(String id) => _write(_subId, id);
  static String? getSubscriptionId() => _read(_subId);

  static Future<void> setRazorPaySubscriptionId(String id) =>
      _write(_razorPaySubscriptionId, id);
  static String? getRazorPaySubscriptionId() => _read(_razorPaySubscriptionId);

  static Future<void> setPhonePeSubscriptionId(String id) =>
      _write(_subscriptionIdPhonepe, id);
  static String? getPhonePeSubscriptionId() => _read(_subscriptionIdPhonepe);

  static Future<void> setPhonePeTransactionId(String id) =>
      _write(_transactionIdPhonepe, id);
  static String? getPhonePeTransactionId() => _read(_transactionIdPhonepe);

  static Future<void> setPhonePeMerchantSubscriptionId(String id) =>
      _write(_merchantSubscriptionId, id);
  static String? getPhonePeMerchantSubscriptionId() =>
      _read(_merchantSubscriptionId);

  static Future<void> setPhonePePaymentType(String type) =>
      _write(_paymentType, type);
  static String? getPhonePePaymentType() => _read(_paymentType);

  static Future<void> setPhonePePaymentAmount(String amount) =>
      _write(_paymentAmount, amount);
  static String? getPhonePePaymentAmount() => _read(_paymentAmount);
}
