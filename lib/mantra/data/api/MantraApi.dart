import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../resource/values/BharatStrings.dart';

part 'MantraApi.g.dart';

@RestApi(baseUrl: BharatStrings.baseUrl)
abstract class MantraApi {
  factory MantraApi(Dio dio) = _MantraApi;

  @GET("/getMantra")
  Future<HttpResponse> getMantra(
      @Header('authorization') String token,
      @Header('language') String locale,
      @Query("god_id") String id,
  );


}
