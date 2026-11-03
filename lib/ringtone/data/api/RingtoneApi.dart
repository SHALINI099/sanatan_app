import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../resource/values/BharatStrings.dart';

part 'RingtoneApi.g.dart';


@RestApi(baseUrl: BharatStrings.baseUrl)
abstract class RingtoneApi {
  factory RingtoneApi(Dio dio) = _RingtoneApi;

  @GET("/getRingtone")
  Future<HttpResponse> getRingtone(
    @Header('authorization') String token,
    @Header('language') String language,
      @Query("god_id") String id,

      );
}
