import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posterapp/wallpaper/view/wallpaper_screen.dart';

import '../../core/theme/app_colors.dart';
import '../viewmodel/ringtone_view_model.dart';

class RingtoneTabScreen extends StatefulWidget {
  const RingtoneTabScreen({super.key});

  @override
  State<RingtoneTabScreen> createState() => _RingtoneTabScreenState();
}

class _RingtoneTabScreenState extends State<RingtoneTabScreen>
    with SingleTickerProviderStateMixin {
  final RingtoneViewModel controller = Get.put(RingtoneViewModel());
  late TabController _tabController;

  @override
  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    if (_tabController.index == 0) {
      controller.getRingtoneList();
    }

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;

      if (_tabController.index == 0) {
      } else if (_tabController.index == 1) {}
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          tabs: const [
            Tab(
              text: "Ringtone",
            ),
            Tab(text: "Wallpaper"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // RingtoneScreen(controller: controller),
              WallpaperScreen()
            ],
          ),
        ),
      ],
    );
  }
}
