import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../resource/values/BharatStrings.dart';

part 'alarm_api.g.dart';

@RestApi(baseUrl: BharatStrings.baseUrl)
abstract class AlarmApi {
  factory AlarmApi(Dio dio) = _AlarmApi;

  @GET("/getAlarm")
  Future<HttpResponse> getAlarm(
      @Header('authorization') String token,
      @Header('language') String locale,
      @Query("god_id") String id,
      );


}
