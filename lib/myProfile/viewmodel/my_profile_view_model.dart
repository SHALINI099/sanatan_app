
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:posterapp/myProfile/data/api/ProfileApi.dart';
import 'package:posterapp/core/database/BharatStorage.dart';
import 'package:posterapp/resource/values/DownloadShare.dart';
import '../../resource/functions/LogOut.dart';
import '../../resource/values/Status.dart';
import '../data/model/GetProfileModel.dart';
import 'package:posterapp/core/network/dio_client.dart';

class MyProfileViewModel extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isError = false.obs;
  RxString errorStatusCode = "Error".obs;
  RxString errorStatusMessage = "Error".obs;
  RxString avatar = ''.obs;
  final nameCtr = TextEditingController().obs;
  final mobileCtr = TextEditingController().obs;
  final addCtr = TextEditingController().obs;
  final fbCtr = TextEditingController().obs;
  final instaCtr = TextEditingController().obs;
  final twitterCtr = TextEditingController().obs;
  final descCtr = TextEditingController().obs;
  RxString urlDownload = ''.obs;

  RxString getApiError = "".obs;
  RxString postApiError = "".obs;
  final rxgetRequestStatus = Status.initial.obs;
  final rxpostRequestStatus = Status.initial.obs;

  void setgetRxRequestStatus(Status value) => rxgetRequestStatus.value = value;

  void setpostRxRequestStatus(Status value) =>
      rxpostRequestStatus.value = value;

  final api = ProfileApi(buildDio());


  Rxn<GetProfileModel> profileModel = Rxn<GetProfileModel>();

  Future<void> userData() async {
    setgetRxRequestStatus(Status.loading);
    try {
      String token = BharatStorage.getAuthKey() ?? '';
      final res = await api.getUserList('Bearer $token');
      if (res.response.statusCode == 200) {
        profileModel.value = GetProfileModel.fromJson(res.data);
        final data = profileModel.value?.data;
        if (data != null) {
          nameCtr.value.text = data.name;
          mobileCtr.value.text = data.mobileNumber;
          addCtr.value.text = data.address ?? '';
          descCtr.value.text = data.description ?? '';
          fbCtr.value.text = data.fbId ?? '';
          instaCtr.value.text = data.instaId ?? '';
          twitterCtr.value.text = data.twiterId ?? '';
          avatar.value = data.avatar ?? '';
          nameCtr.refresh();
          BharatStorage.setUserName(data.name);
          BharatStorage.setLanguage(data.language??'hi');
          BharatStorage.setTrial(data.has_trial);
          if(data.subscriptionType=='success'){
           BharatStorage.setSubscription(true);
            dashCtr.isSubsribed.value = true;
          }else{
            BharatStorage.setSubscription(false);
            dashCtr.isSubsribed.value = false;
          }

        }
        setgetRxRequestStatus(Status.completed);
      }
      else if (res.response.statusCode == 401) {
        logOutUser(false);
      }
      else {
        setgetRxRequestStatus(Status.error);
        getApiError.value =
            "${res.response.statusCode.toString()}\n${res.response.statusMessage}";
        getApiError.refresh();
      }
    } catch (error) {
      setgetRxRequestStatus(Status.error);
    }
  }

  /// update user profile api
  Future<void> updateUser() async {
    try {
      setpostRxRequestStatus(Status.loading);
      String token = BharatStorage.getAuthKey() ?? '';
      final res = await api.updateUser('Bearer $token', {
        "name": nameCtr.value.text.trim(),
        "mobile_number": mobileCtr.value.text,
        "avatar": avatar.value,
        "description": descCtr.value.text.trim(),
        "address": addCtr.value.text.trim(),
        "fb_id": fbCtr.value.text.trim(),
        "insta_id": instaCtr.value.text.trim(),
        "twiter_id": twitterCtr.value.text.trim()
      });
      if (res.response.statusCode == 200) {
        await setLocalData();
        EasyLoading.show(status: "uploaded");
        setpostRxRequestStatus(Status.completed);
      }
      else if (res.response.statusCode == 401) {
        logOutUser(false);
      }
      else {
        setpostRxRequestStatus(Status.error);
      }
    } catch (error) {
      setpostRxRequestStatus(Status.error);
    }
  }

  /// update avatar
  Future<void> updateAvatar(String newAvatar) async {
    try {
      String token = BharatStorage.getAuthKey() ?? '';
      final res = await api.updateUser('Bearer $token', {
        "name": nameCtr.value.text.trim(),
        "mobile_number": mobileCtr.value.text,
        "avatar": newAvatar,
        "description": descCtr.value.text.trim(),
        "address": addCtr.value.text.trim(),
        "fb_id": fbCtr.value.text.trim(),
        "insta_id": instaCtr.value.text.trim(),
        "twiter_id": twitterCtr.value.text.trim(),
      });
      if (res.response.statusCode == 200) {
        avatar.value = newAvatar;
        await setLocalData();
        EasyLoading.showSuccess("Uploaded");
        EasyLoading.dismiss();
      }
      else if (res.response.statusCode == 401) {
        logOutUser(false);
      }
      else {

      }
    } catch(error) {

    }
  }

  Future<void> setLocalData() async {
    await BharatStorage.setAddress(addCtr.value.text);
    await BharatStorage.setFacebookId(fbCtr.value.text);
    await BharatStorage.setTwitterId(twitterCtr.value.text);
    await BharatStorage.setUserImage(avatar.value);
    await BharatStorage.setUserName(nameCtr.value.text.trim());
    await BharatStorage.setUserDesc(descCtr.value.text.trim());
  }
}
