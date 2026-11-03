import 'dart:developer';

import 'package:get/get.dart';
import 'package:posterapp/post/data/api/post_api.dart';

import '../../core/database/BharatStorage.dart';
import '../../resource/functions/LogOut.dart';
import '../../resource/values/Status.dart';
import '../data/model/AllPostModel.dart';
import '../data/model/PostModel.dart';
import 'package:posterapp/core/network/dio_client.dart';

class PostViewModel extends GetxController{
  final api = PostApi(buildDio());

  /// API status
  final rxPostRequestStatus = Status.initial.obs;
  final rxAllPostRequestStatus = Status.initial.obs;

  /// Reactive model (nullable)
  var postModel = Rxn<PostModel>();
  var allPostModel = Rxn<AllPostModel>();

  void setPost(Status value) =>
      rxPostRequestStatus.value = value;

  void setAllPost(Status value) =>
      rxAllPostRequestStatus.value = value;



  Future<void> getPostData() async {
    setPost(Status.loading);

    try {
      String? token = BharatStorage.getAuthKey();

      if (token == null || token.isEmpty) {
        logOutUser(false);
        return;
      }

      final language = BharatStorage.getLanguage() ?? 'en';

      final res = await api.getPostData('Bearer $token', language, '0');

      if (res.response.statusCode == 200) {
        postModel.value =
            PostModel.fromJson(res.data);

        setPost(Status.completed);

      } else if (res.response.statusCode == 401) {
        logOutUser(false);
        setPost(Status.completed);

      } else {
        setPost(Status.error);
      }

    } catch (error) {
      setPost(Status.error);
    }
  }


  Future<void> getAllPost() async {
    setAllPost(Status.loading);

    try {
      String? token = BharatStorage.getAuthKey();

      if (token == null || token.isEmpty) {
        logOutUser(false);
        return;
      }

      final language = BharatStorage.getLanguage() ?? 'en';

      final res = await api.getAllData('Bearer $token', language, '0');

      if (res.response.statusCode == 200) {
        allPostModel.value =
            AllPostModel.fromJson(res.data);
log("sldkjhbfg ${allPostModel.value}");

        setAllPost(Status.completed);

      } else if (res.response.statusCode == 401) {
        logOutUser(false);
        setAllPost(Status.completed);

      } else {
        setAllPost(Status.error);
      }

    } catch (error) {
      log("sldkjhbfg ${error.toString()}");

      setAllPost(Status.error);
    }
  }

}