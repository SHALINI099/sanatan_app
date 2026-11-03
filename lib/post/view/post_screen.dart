import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:posterapp/core/theme/app_colors.dart';
import 'package:posterapp/myProfile/viewmodel/my_profile_view_model.dart';
import 'package:posterapp/post/viewmodel/post_view_model.dart';

import '../../core/database/BharatStorage.dart';
import '../../payment/view/payment_screen.dart';
import '../../resource/values/DownloadShare.dart';
import '../../resource/widgets/helper/DynamicButton.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final PostViewModel postCtrl = Get.put(PostViewModel());
  final MyProfileViewModel profileCtr = Get.put(MyProfileViewModel());

  final PageController _pageCtrl = PageController();

  final Map<int, GlobalKey> _keys = {};

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    if (postCtrl.postModel.value == null) {
      postCtrl.getPostData();
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  GlobalKey _keyFor(int i) {
    return _keys.putIfAbsent(i, () => GlobalKey());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        // actions: [
        //   IconButton(
        //     tooltip: 'Download',
        //     onPressed: () {
        //       DownloadShare.downloadPost(
        //         context,
        //         _keyFor(_currentIndex),
        //       );
        //     },
        //     icon: const Icon(Icons.download),
        //   ),
        //   IconButton(
        //     tooltip: 'Share',
        //     onPressed: () {
        //       final post =
        //       postCtrl.postModel.value!.postData[_currentIndex];
        //
        //       DownloadShare.sharePost(
        //         _keyFor(_currentIndex),
        //         post.sharingContent ?? '',
        //       );
        //     },
        //     icon: const Icon(Icons.share),
        //   ),
        // ],
      ),

      body: Obx(() {
        if (postCtrl.postModel.value == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final posts = postCtrl.postModel.value!.postData;

        return PageView.builder(
          controller: _pageCtrl,
          itemCount: posts.length,
          scrollDirection: Axis.vertical,



          itemBuilder: (context, index) {
            final card = posts[index];

            return Padding(
              padding: const EdgeInsets.all(12),

              child: Column(
                children: [
                  RepaintBoundary(
                    key: _keyFor(index),

                    child: Card(
                      color: AppColors.primaryColor,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Column(
                        mainAxisSize: MainAxisSize.min,

                        children: [

                          /// IMAGE
                          CachedNetworkImage(
                            imageUrl: card.postUrl ?? '',

                            fit: BoxFit.cover,

                            placeholder: (context, url) {
                              return SizedBox(
                                height: 300,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              );
                            },

                            errorWidget: (context, url, error) {
                              return const SizedBox(
                                height: 300,
                                child: Icon(Icons.error),
                              );
                            },
                          ),

                          /// TITLE / TEXT
                          Obx(() {
                            final avatar = profileCtr.avatar.value;
                            final name = profileCtr.nameCtr.value.text;
                            return Container(
                              height: Get.height * 0.09,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipOval(
                                    child: avatar.isEmpty
                                        ? Container(
                                      width: 65,
                                      height: 65,
                                      color: Colors.white,
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.person,
                                          color: AppColors.primaryColor),
                                    )
                                        : CachedNetworkImage(
                                      imageUrl: avatar,
                                      width: 65,
                                      height: 65,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Container(
                                        width: 44,
                                        height: 44,
                                        color: Colors.white,
                                        alignment: Alignment.center,
                                        child: const Icon(Icons.person,
                                            color: AppColors.primaryColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })
                        ],
                      ),
                    ),
                  ),
                  DynamicButton(
                    text: "share",
                    height: 45,
                    width: Get.width * 0.4,
                    backgroundColor: AppColors.primaryColor,
                    color: AppColors.white,
                    leadingIcon: Icons.share,
                    iconColor: AppColors.white,
                    showLeading: true,
                    onTap: () {
                      if (BharatStorage.getSubscription() == true) {
                        final post =
                           postCtrl.postModel.value!.postData[_currentIndex];
                        DownloadShare.sharePost(
                                  _keyFor(_currentIndex),
                                  post.sharingContent ?? '',
                                );
                      } else {
                        Get.to(() => PaymentScreen());
                      }
                    },
                  ).paddingSymmetric(vertical: 50),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}