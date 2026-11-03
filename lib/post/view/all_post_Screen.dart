import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posterapp/post/viewmodel/post_view_model.dart';
import 'package:posterapp/post/widget/alarm_card.dart';
import 'package:posterapp/post/widget/greeting_card.dart';
import 'package:posterapp/post/widget/ringtone_card.dart';

import '../widget/mantra_card.dart';
import '../widget/wallpaper_card.dart';

class AllPostsScreen extends StatelessWidget {
  AllPostsScreen({super.key});

  final postCtrl = Get.put(PostViewModel());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (postCtrl.allPostModel.value == null) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final posts = postCtrl.allPostModel.value!.data;

      return ListView.builder(
        itemCount: posts.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final post = posts[index];

          switch (post.type) {
            case 'arti':
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    post.data.title,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              );
            case 'alarm':
              return AlarmCard(post: post);
            case 'post':
              return GreetingCard.fromDatum(post);

            case 'wallpaper':
              return WallpaperCard(post: post);
            case 'ringtone':
              return RingtoneCard(post: post);
            case 'mantra':
              return MantraCard(post: post);

            default:
              return const SizedBox();
          }
        },
      );
    });
  }
}
