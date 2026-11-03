import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../resource/values/BharatStrings.dart';

part 'ProfileApi.g.dart';

@RestApi(baseUrl: BharatStrings.baseUrl)
abstract class ProfileApi {
  factory ProfileApi(Dio dio) = _ProfileApi;

  @GET("/getProfile")
  Future<HttpResponse> getUserList(
    @Header('authorization') String token,
  );

  @POST("/updateProfile")
  Future<HttpResponse> updateUser(
      @Header('authorization') String token, @Body() Map<String, String> data);

  @GET("/getInvoice")
  Future<HttpResponse> fetchInvoice(
      @Header('authorization') String token,
      );
}
