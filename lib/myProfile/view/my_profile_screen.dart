import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:posterapp/resource/values/image_controller.dart';
import 'package:posterapp/resource/values/select_Image.dart';
import 'package:posterapp/resource/widgets/helper/DynamicButton.dart';

import '../../core/theme/app_colors.dart';
import '../../resource/values/BharatDimension.dart';
import '../viewmodel/my_profile_view_model.dart';
import 'edit_profile_screen.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> with TickerProviderStateMixin {
  MyProfileViewModel profileCtr = Get.put(MyProfileViewModel());

  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 3, vsync: this);

    return Scaffold(
        body: Obx(
      () => SafeArea(
        child: Stack(children: [
          Column(
            children: [
              SizedBox(
                height: 230,
                child: Stack(
                  children: [
                    Image.asset("assets/images/profileImg.png"),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                        onTap: () {
                          selectImage(context, imgCtr);
                        },
                        child: profileCtr.avatar.value.isEmpty
                            ? Icon(
                                Icons.account_circle,
                                size: 100,
                                color: AppColors.primaryColor,
                              )
                            : Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 4)),
                                child: ClipOval(
                                  child: Image.network(
                                    profileCtr.avatar.value,
                                    fit: BoxFit.cover,
                                    errorBuilder: (BuildContext context,
                                        Object error, StackTrace? stackTrace) {
                                      return Icon(
                                        Icons.person,
                                        color: AppColors
                                            .primaryColor, // Customize the color as needed
                                        size:
                                            48.0, // Customize the size as needed
                                      );
                                    },
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      } else {
                                        return Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    (loadingProgress
                                                            .expectedTotalBytes ??
                                                        1)
                                                : null,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  profileCtr.nameCtr.value.text,
                  style: BharatDimension.fontFamily(
                      fontSize: 16, color: Colors.black),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25),
                child: Align(
                  alignment: Alignment.center,
                  child: DynamicButton(
                    text: "editProfile".tr,
                    height: 45,
                    leadingIcon: Icons.edit,
                    showLeading: true,
                    onTap: () {
                      Get.to(const EditProfile());
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: TabBar(
                  controller: tabController,
                  padding: EdgeInsets.zero,
                  // labelPadding: EdgeInsets.zero,
                  tabs: [
                    Tab(
                      child: Text(
                        "createdQuotes".tr,
                      ),
                    ),
                    Tab(
                      child: Text(
                        "fav".tr,
                      ),
                    ),
                    Tab(
                      child: Text(
                        "download".tr,
                      ),
                    ),
                  ],
                  unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
                  indicatorColor: const Color(0xFF00244E),
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: const Color(0xFF1D1D1D),
                  isScrollable: true,
                  labelStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                  onTap: (index) async {},
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 7, right: 7, top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                    )),
                // InkWell(
                //   onTap: () {
                //     Get.to(const SettingsScreen());
                //   },
                //   child: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: Icon(
                //       Icons.settings,
                //     ),
                //   ),
                // )
              ],
            ),
          ),
          // Align(alignment: Alignment.topCenter,
          //   child: GestureDetector(
          //     onTap: () {
          //       selectImage(context, imageController);
          //     },
          //     child: profileCtr.avatar.value.isEmpty
          //         ? Icon(
          //             Icons.account_circle,
          //             size: 100,
          //           )
          //         : Container(
          //           height: 100,
          //           width: 100,
          //           decoration: BoxDecoration(
          //               shape: BoxShape.circle,
          //               border:
          //                   Border.all(color: Colors.white, width: 4)),
          //           child: ClipOval(
          //             child: Image.network(
          //               profileCtr.avatar.value,
          //               fit: BoxFit.cover,
          //               loadingBuilder: (BuildContext context,
          //                   Widget child,
          //                   ImageChunkEvent? loadingProgress) {
          //                 if (loadingProgress == null) {
          //                   return child;
          //                 } else {
          //                   return Center(
          //                     child: CircularProgressIndicator(
          //                       color: Colors.white,
          //                       value: loadingProgress
          //                                   .expectedTotalBytes !=
          //                               null
          //                           ? loadingProgress
          //                                   .cumulativeBytesLoaded /
          //                               (loadingProgress
          //                                       .expectedTotalBytes ??
          //                                   1)
          //                           : null,
          //                     ),
          //                   );
          //                 }
          //               },
          //             ),
          //           ),
          //         ),
          //   ),
          // ),
        ]),
      ),
    ));
  }
}
