

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posterapp/dashboard/data/api/DashboardApi.dart';
import 'package:posterapp/dashboard/data/model/CardModel.dart';
import 'package:posterapp/dashboard/data/model/LanguageModel.dart';
import 'package:posterapp/dashboard/data/model/TagListModel.dart';
import 'package:posterapp/payment/data/api/PaymentApi.dart';

import '../../main.dart';
import '../../core/database/BharatStorage.dart';
import '../../resource/functions/LogOut.dart';
import '../../resource/values/DownloadShare.dart';
import '../../resource/values/Status.dart';
import 'package:posterapp/core/network/dio_client.dart';

class DashboardViewModel extends GetxController {
  final api = DashboardApi(buildDio());

  final payApi = PaymentApi(buildDio());
  RxInt selectedPageIndex = 0.obs;
  RxInt selectedCategory = 0.obs;
  RxBool isSelected = false.obs;
  RxInt selectedCardIndex = (-1).obs;

  RxList<String> images = <String>[].obs;
  RxBool isLoading = true.obs;
  RxBool isError = false.obs;
  RxString avatarPath = ''.obs;
  final PageController controller = PageController();
  final PageController bdaycontroller = PageController();
  final PageController politicalcontroller = PageController();
  final PageController framecontroller = PageController();


  RxList<PostDatum> cards = <PostDatum>[].obs;
  RxList<Datums> laguageList = <Datums>[].obs;
  RxString errorStatusCode = "Error".obs;
  RxString errorStatusMessage = "Error".obs;
  RxList<TagName> tags = <TagName>[].obs;
  RxDouble videoHeight = 100.0.obs;
  RxDouble videoWidth = 100.0.obs;
  RxString partyIcon = ''.obs;
  RxString tagFieldName = "other".obs;

  PageController editController = PageController();
  RxInt editIndex = 0.obs;
  RxDouble stars = 0.0.obs;
  RxInt visibleWidgetIndex = 0.obs;
  RxInt newIndex = 0.obs;
  RxInt selectedIndex = 0.obs;
  Rx<String?> name = BharatStorage.getUserName().obs;
  Rx<String?> desc = BharatStorage.getUserDesc().obs;
  Rx<String?> profileImage = BharatStorage.getUserImage().obs;
  RxString tagId = ''.obs;

  // Search
  RxString searchQuery = ''.obs;
  RxBool isSearchFocused = false.obs;
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> searchSuggestions = [
    {'icon': Icons.alarm, 'label': 'Alarm', 'color': Colors.orange},
    {'icon': Icons.wallpaper, 'label': 'Wallpaper', 'color': Colors.blue},
    {'icon': Icons.music_note, 'label': 'Ringtone', 'color': Colors.purple},
    {'icon': Icons.self_improvement, 'label': 'Mantra', 'color': Colors.green},
    // {'icon': Icons.temple_hindu, 'label': 'Temple', 'color': Colors.orange},
    // {'icon': Icons.landscape, 'label': 'Landscape', 'color': Colors.teal},
    // {'icon': Icons.pets, 'label': 'Animals', 'color': Colors.brown},
    // {'icon': Icons.star, 'label': 'Popular', 'color': Colors.amber},
    // {'icon': Icons.new_releases, 'label': 'New', 'color': Colors.red},
  ];

  List<Map<String, dynamic>> get filteredSuggestions {
    if (searchQuery.value.isEmpty) return searchSuggestions;
    return searchSuggestions
        .where((s) => s['label']
            .toString()
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  RxString tagApiError = "".obs;
  RxString cardApiError = "".obs;
  RxString languageListApiError = "".obs;
  final rxTagRequestStatus = Status.initial.obs;
  final rxCardRequestStatus = Status.initial.obs;
  final rxLangListRequestStatus = Status.initial.obs;
  RxBool isSubsribed = false.obs;

  PageController swipeController = PageController();

  void setTagRxRequestStatus(Status value) => rxTagRequestStatus.value = value;

  void setCardRxRequestStatus(Status value) =>
      rxCardRequestStatus.value = value;

  void setLangRxRequestStatus(Status value) =>
      rxLangListRequestStatus.value = value;

  Future<void> getTag() async {
    setTagRxRequestStatus(Status.loading);

    try {
      String token = BharatStorage.getAuthKey() ?? '';
      appLocale = BharatStorage.getLanguage() ?? 'en';

      final res = await api.getTagList('Bearer $token', appLocale);

      if (res.response.statusCode == 200) {
        TagModel model = TagModel.fromJson(res.data);
        if (model.tagName.isEmpty) {
          tags.clear();
          tags.refresh();
        } else {
          tags.clear();
          tags.refresh();
          tags.assignAll(model.tagName);
          selectedIndex.refresh();
          tagId.refresh();
          tagFieldName.value = 'other';
          tagFieldName.refresh();
          tagId.value =
              model.tagName[dashCtr.selectedIndex.value].id.toString();

          fetchCards(dashCtr.tagId.value, '0');

        }

        setTagRxRequestStatus(Status.completed);
      } else if (res.response.statusCode == 401) {
        logOutUser(false);
      } else {
        setTagRxRequestStatus(Status.error);
        tagApiError.value =
            "${res.response.statusCode.toString()}\n${res.response.statusMessage}";
        // log("error${error}");

        tagApiError.refresh();
      }
    } catch (error) {
      setTagRxRequestStatus(Status.error);
      tagApiError.value = "$error";
    }
  }

  Future<void> fetchCards(String id, String partyId) async {
    setCardRxRequestStatus(Status.loading);

    try {
      final token = BharatStorage.getAuthKey() ?? '';
      final appLocale = BharatStorage.getLanguage() ?? 'en';

      final response =
      await api.getCardData(id, partyId, 'Bearer $token', appLocale);

      final statusCode = response.response?.statusCode;


      if (statusCode == 200) {
        final model = CardModel.fromJson(response.data);
        cards.assignAll(model.postData ?? []);
        setCardRxRequestStatus(Status.completed);
      }
      else if (statusCode == 401) {
        logOutUser(false);
      }
      else {

        handleError(
          statusCode?.toString() ?? "Unknown",
          response.response?.statusMessage ?? "Something went wrong",
        );
      }
    } catch (e) {
      handleError("Exception", e.toString());
    }
  }



//--------------API CALLS ABOVE--------------------------------------------------
//-------------------------------------------------------------------------------
  void handleError(String statusCode, String statusMessage) {
    errorStatusCode.value = statusCode;
    errorStatusMessage.value = statusMessage;
    setCardRxRequestStatus(Status.error);
  }

  void updateIndex(int index) {
    selectedIndex.value = index;
    selectedIndex.refresh();
  }

  void updateEditIndex(int index) {
    editIndex.value = index;
    editIndex.refresh();
  }

  void onTapInkWell() {
    int desiredPageIndex = 1;
    controller.animateToPage(
      desiredPageIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void onInit() {
    super.onInit();
    swipeController.addListener(_onScroll);

  }

  int saltIndex = 1;

  void _onScroll() {
    double scrollPosition = swipeController.position.pixels;

    double itemWidth = Get.size.width;
    int newIndex = (scrollPosition / itemWidth).round();

    if (newIndex != visibleWidgetIndex) {
      visibleWidgetIndex = newIndex as RxInt;
    }
  }





  @override
  void dispose() {
    controller.dispose();
    swipeController.dispose();

    super.dispose();
  }



}
