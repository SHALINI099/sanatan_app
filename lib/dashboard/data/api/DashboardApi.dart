import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../resource/values/BharatStrings.dart';

part 'DashboardApi.g.dart';

@RestApi(baseUrl: BharatStrings.baseUrl)
abstract class DashboardApi {
  factory DashboardApi(Dio dio) = _DashboardApi;

  @GET("/getCardList")
  Future<HttpResponse> getCardData(
    @Query("tagId") String id,
    @Query("partyId") String partyid,
    @Header('authorization') String token,
    @Header('language') String locale,
  );

  @GET("/getTagList")
  Future<HttpResponse> getTagList(
    @Header('authorization') String token,
    @Header('language') String locale,
  );


}
