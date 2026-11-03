import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../resource/values/BharatStrings.dart';

part 'WallpaperApi.g.dart';

@RestApi(baseUrl: BharatStrings.baseUrl)
abstract class WallpaperApi {
  factory WallpaperApi(Dio dio) = _WallpaperApi;

  @GET('/getWallpaper')
  Future<HttpResponse> getWallpaper(
    @Header('authorization') String token,
    @Header('language') String language,
    @Query("god_id") String id,
  );
}
