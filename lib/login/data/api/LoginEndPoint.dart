import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../resource/values/BharatStrings.dart';
part 'LoginEndPoint.g.dart';

@RestApi(baseUrl: BharatStrings.baseUrl)
abstract class LoginEndPoint {
  factory LoginEndPoint(Dio dio) = _LoginEndPoint;

  @POST("/login")
  Future<HttpResponse> loginPhone(@Body() Map<String, dynamic> data);

  @POST("/verifyOtp")
  Future<HttpResponse> otpVerify(@Body() Map<String, String> data);

  @POST("//onboarding")
  Future<HttpResponse> onboardUser(
      @Header('authorization') String token, @Body() Map<String, String> data);

}
