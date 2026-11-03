import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../resource/values/BharatStrings.dart';

part 'PaymentApi.g.dart';

@RestApi(baseUrl: BharatStrings.paymentUrl)
abstract class PaymentApi {
  factory PaymentApi(Dio dio) = _PaymentApi;


  @POST("/paymentService/v1/getSubscriptionPlans?app_name=sanatan")
  Future<HttpResponse> updateTransactionData(
      @Header('authorization') String authToken,
      @Body() Map<String, dynamic> data);

  @GET("/paymentService/v1/getSubscriptionPlans?app_name=com.alnico.sanatanapp")
  Future<HttpResponse> getPaymentDetails(
      @Header('authorization') String token,
      );





  @POST("/paymentService/v1/createSubscription")
  Future<HttpResponse> createSub(
      @Header('authorization') String token,
      @Body() Map<String, dynamic> data
      );

  @GET('/paymentService/v1/checkSubscriptionStatus')
  Future<HttpResponse> getSubscriptionData(
      @Header('authorization') String token,
      @Query("subscriptionId") String subscriptionId,
      @Query("mobile_number") String mobileNumber,
      @Query("app_name") String appName,
      );
}
