import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../resource/values/BharatStrings.dart';

part 'post_api.g.dart';

@RestApi(baseUrl: BharatStrings.baseUrl)
abstract class PostApi {
  factory PostApi(Dio dio) = _PostApi;

  @GET("/getPostData")
  Future<HttpResponse> getPostData(
      @Header('authorization') String token,
      @Header('language') String locale,
      @Query("god_id") String id,
      );


  @GET("/getAllData")
  Future<HttpResponse> getAllData(
      @Header('authorization') String token,
      @Header('language') String locale,
      @Query("god_id") String id,
      );


}
