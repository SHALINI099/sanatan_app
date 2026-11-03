import 'package:facebook_app_events/facebook_app_events.dart';

class BharatStrings {
  /*=========================Staging Start==============================================*/

/*=========================Staging End=================================================*/

/*=========================Production Start============================================*/

  static const String baseUrl = "http://174.138.122.39:3000/sanatan/v1";
  static const String paymentUrl = "http://174.138.122.39:3000/";


  static const bool isdebugEnable = true;

/*=========================Production End=============================================*/
  static final facebookAppEvents = FacebookAppEvents();
  static const String phonePeUrl =
      "https://api-preprod.phonepe.com/apis/pg-sandbox";
  static const String contentType = "application/json";
  static const String bankError = "Something happen wrong";
}
