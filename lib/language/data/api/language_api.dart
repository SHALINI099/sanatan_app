import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../resource/values/BharatStrings.dart';
part 'language_api.g.dart';

@RestApi(baseUrl: BharatStrings.baseUrl)
abstract class LanguageApi {
  factory LanguageApi(Dio dio) = _LanguageApi;

  @GET("/getLanguageList")
  Future<HttpResponse> getLanguage(
      @Header('authorization') String token,
      );



  @POST("/updateLanguage")
  Future<HttpResponse> updateLang(
      @Header('authorization') String token,
      @Body() Map<String, String> data);

}