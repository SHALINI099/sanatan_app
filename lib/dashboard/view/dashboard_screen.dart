import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:posterapp/core/storage/app_spacing.dart';
import 'package:posterapp/core/database/BharatStorage.dart';
import 'package:upgrader/upgrader.dart';
import '../../alarm/view/alarm_screen.dart';
import '../../core/storage/app_dimensions.dart';
import '../../core/theme/app_colors.dart';
import '../../language/view/language_page.dart';
import '../../mantra/view/mantra_screen.dart';
import '../../myProfile/viewmodel/my_profile_view_model.dart';
import '../../payment/view/payment_screen.dart';
import '../../post/view/all_post_Screen.dart';
import '../../post/viewmodel/post_view_model.dart';
import '../../resource/values/DownloadShare.dart';
import '../../resource/widgets/helper/DynamicButton.dart';
import '../../ringtone/view/ringtone_screen.dart';
import '../../wallpaper/view/wallpaper_screen.dart';
import '../viewmodel/dashboard_view_model.dart';
import 'drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DashboardViewModel dashCtr = Get.put(DashboardViewModel());
  MyProfileViewModel profileCtr = Get.put(MyProfileViewModel());
  PostViewModel postCtrl = Get.put(PostViewModel());

  final ScrollController _scrollCtrl = ScrollController();
  final RxBool _showTopButton = false.obs;

  Future<void> ratingPage() async {
    if (dashCtr.isSubsribed.value == true) {
      final dateString = BharatStorage.getDate();

      final now = DateTime.now();

      if (dateString == null) {
        BharatStorage.setDate(now.toIso8601String());
        showRatingPopup(context);
        return;
      }

      final pastDate = DateTime.parse(dateString);

      final difference = now.difference(pastDate).inHours;

      if (difference >= 168) {
        BharatStorage.setDate(now.toIso8601String());
        showRatingPopup(context);
      } else {}
    } else {}
  }

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      _showTopButton.value = _scrollCtrl.offset > 300;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileCtr.userData();
      postCtrl.getAllPost();
      if (!(BharatStorage.getSubscription() ?? false)) {
        Get.to(() => PaymentScreen());
      }
      Future.delayed(Duration.zero, () {
        ratingPage();
      });

      profileCtr.avatar.value = BharatStorage.getUserImage() ?? '';
      profileCtr.nameCtr.value.text = BharatStorage.getUserName() ?? '';
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollCtrl.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
        dialogStyle: Platform.isIOS
            ? UpgradeDialogStyle.cupertino
            : UpgradeDialogStyle.material,
        barrierDismissible: false,
        showLater: false,
        showIgnore: false,
        upgrader: Upgrader(
          durationUntilAlertAgain: const Duration(seconds: 1),
        ),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.bgColor,
          drawer: BuildDrawer(
            profileCtr: profileCtr,
          ),
          body: SafeArea(
            child: Stack(
              children: [
                /// MAIN SCROLLABLE CONTENT
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// FIXED HEADER
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                            child: Obx(() {
                              final imgUrl = profileCtr.avatar.value;
                              return CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.orange.shade100,
                                backgroundImage: imgUrl.isNotEmpty
                                    ? NetworkImage(imgUrl)
                                    : null,
                                child: imgUrl.isEmpty
                                    ? const Icon(Icons.person,
                                        color: Colors.orange)
                                    : null,
                              );
                            }),
                          ),
                          AppSpacing.width(12),
                          Expanded(
                            child: Obx(() {
                              final name = profileCtr.nameCtr.value.text.trim();
                              final displayName = name.isEmpty ? 'Guest' : name;
                              return Text(
                                "Hey $displayName ✨",
                                style: TextStyle(
                                    fontSize: AppDimensions.fontSize18,
                                    fontWeight: AppDimensions.fontWeight600),
                                overflow: TextOverflow.ellipsis,
                              );
                            }),
                          ),
                          Obx(() => _showTopButton.value
                              ? InkWell(
                                  onTap: _scrollToTop,
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primaryColor,
                                          AppColors.primaryColor
                                              .withValues(alpha: 0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryColor
                                              .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.keyboard_arrow_up_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Top",
                                          textAlign: TextAlign.center,
                                          style: AppDimensions.inter(
                                            fontWeight:
                                                AppDimensions.fontWeight600,
                                            fontSize: 14,
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink()),
                          IconButton(
                              onPressed: () {
                                Get.bottomSheet(
                                  FractionallySizedBox(
                                      heightFactor: 0.8, child: LanguagePage()),
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                );
                              },
                              icon: Icon(
                                Icons.g_translate,
                                size: 30,
                              )),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// SEARCH FIELD
                            TextField(
                              controller: dashCtr.searchController,
                              onChanged: (value) {
                                dashCtr.searchQuery.value = value;
                              },
                              onTap: () {
                                dashCtr.isSearchFocused.value = true;
                              },
                              onTapOutside: (_) {
                                FocusManager.instance.primaryFocus?.unfocus();

                                Future.delayed(
                                    const Duration(milliseconds: 150), () {
                                  if (!dashCtr.isSearchFocused.value) return;
                                  dashCtr.searchController.clear();
                                  dashCtr.searchQuery.value = '';
                                  dashCtr.isSearchFocused.value = false;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Search wallpapers, ringtones...",
                                hintStyle: TextStyle(color: AppColors.grey),
                                prefixIcon: Icon(Icons.search,
                                    color: AppColors.primaryColor),
                                suffixIcon:
                                    Obx(() => dashCtr.isSearchFocused.value
                                        ? IconButton(
                                            icon: Icon(Icons.close,
                                                color: AppColors.grey),
                                            onPressed: () {
                                              dashCtr.searchController.clear();
                                              dashCtr.searchQuery.value = '';
                                              dashCtr.isSearchFocused.value =
                                                  false;
                                              FocusScope.of(context).unfocus();
                                            },
                                          )
                                        : const SizedBox.shrink()),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                      color: AppColors.grey
                                          .withValues(alpha: 0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                      color: AppColors.primaryColor,
                                      width: 1.5),
                                ),
                              ),
                            ),

                            AppSpacing.height(4),

                            /// GRID OPTIONS
                            Obx(() {
                              final items = <_DashCard>[
                                _DashCard("⏰", "Alarm", () => AlarmScreen()),
                                _DashCard("📿", "Mantra", () => MantraScreen()),
                                _DashCard("🖼️", "Wallpaper",
                                    () => WallpaperScreen()),
                                _DashCard(
                                    "🎵", "Ringtone", () => RingtoneScreen()),
                              ];
                              return Column(
                                children: [
                                  for (var r = 0; r < items.length; r += 2) ...[
                                    if (r > 0) AppSpacing.height(8),
                                    Row(
                                      children: [
                                        for (var c = 0; c < 2; c++) ...[
                                          if (c > 0) AppSpacing.width(12),
                                          Expanded(
                                            child: buildCard(
                                              items[r + c].emoji,
                                              items[r + c].title,
                                              dashCtr.selectedCardIndex.value ==
                                                  r + c,
                                              () {
                                                dashCtr.selectedCardIndex
                                                    .value = r + c;
                                                Get.to(items[r + c].screen);
                                              },
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ],
                              );
                            }),

                            AppSpacing.height(7),

                            AllPostsScreen()
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                /// SEARCH SUGGESTIONS OVERLAY
                Obx(() {
                  if (!dashCtr.isSearchFocused.value) {
                    return const SizedBox.shrink();
                  }

                  return Positioned(
                    top: 140,
                    left: 16,
                    right: 16,
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      child: Builder(builder: (context) {
                        final suggestions = dashCtr.filteredSuggestions;

                        if (suggestions.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: Text(
                                "No results found",
                                style: TextStyle(
                                    color: AppColors.grey, fontSize: 14),
                              ),
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.all(12),
                          child: GridView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: suggestions.length,
                            itemBuilder: (context, index) {
                              final item = suggestions[index];
                              return GestureDetector(
                                onTap: () {
                                  dashCtr.searchController.text = item['label'];
                                  dashCtr.searchQuery.value = item['label'];
                                  dashCtr.isSearchFocused.value = false;
                                  FocusScope.of(context).unfocus();

                                  if (item['label'] == 'Wallpaper') {
                                    Get.to(() => WallpaperScreen());
                                  } else if (item['label'] == 'Ringtone') {
                                    Get.to(() => RingtoneScreen());
                                  } else if (item['label'] == 'Mantra') {
                                    Get.to(() => MantraScreen());
                                  } else if (item['label'] == 'Alarm') {
                                    Get.to(() => AlarmScreen());
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: (item['color'] as Color)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: (item['color'] as Color)
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        item['icon'] as IconData,
                                        color: item['color'] as Color,
                                        size: 28,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item['label'],
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: item['color'] as Color,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ],
            ),
          ),
        ));
  }

  /// CARD WIDGET
  Widget buildCard(
      String emoji, String title, bool isSelected, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.grey.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            AppSpacing.width(8),
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

void showRatingPopup(BuildContext context) async {
  final InAppReview inAppReview = InAppReview.instance;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Center(
          child: Text(
            "Rate Om shanti",
            style: TextStyle(fontSize: 18),
          ),
        ),
        content: RatingBar.builder(
          initialRating: dashCtr.stars.value,
          minRating: 1,
          itemCount: 5,
          unratedColor: AppColors.grey,
          itemBuilder: (context, index) {
            return Icon(
              Icons.star,
              color: Colors.yellow.shade800,
            );
          },
          onRatingUpdate: (newStars) {
            dashCtr.stars.value = newStars; // Update the stars value
          },
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DynamicButton(
                text: "Cancel",
                height: 40,
                color: AppColors.white,
                onTap: () {
                  Get.back();
                },
              ),
              AppSpacing.width(10),
              DynamicButton(
                text: "Ok",
                height: 40,
                color: AppColors.white,
                onTap: () async {
                  // Close the dialog first so no BuildContext is used after
                  // the async availability check.
                  Get.back();
                  if (dashCtr.stars.value <= 3.0) return;
                  if (await inAppReview.isAvailable()) {
                    Future.delayed(
                      const Duration(seconds: 2),
                      inAppReview.requestReview,
                    );
                  }
                },
              ),
            ],
          ),
        ],
      );
    },
  );
  //   },
  // );
}

class _DashCard {
  final String emoji;
  final String title;
  final Widget Function() screen;
  const _DashCard(this.emoji, this.title, this.screen);
}
