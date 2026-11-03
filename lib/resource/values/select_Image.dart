
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'BharatDimension.dart';
import 'image_controller.dart';

void selectImage(BuildContext context, ImageController imgCtr) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
    builder: ((context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select Image",
                      style:BharatDimension.fontFamily(

                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                        size: 25,
                      ),
                    ),
                  ],
                ),
              ),

              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    await imgCtr.pickFromCamera();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        const Icon(Icons.camera_alt),
                        Text(
                          "Camera".tr,
                          style: BharatDimension.fontFamily(
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    Get.back();
                    await imgCtr.pickFromGallery();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        const Icon(Icons.camera_alt),
                        Text(
                          "Gallery".tr,
                          style: BharatDimension.fontFamily(
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 20,),
            ],
          ),
        ),
      );
    }),
  );
}