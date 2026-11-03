import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:posterapp/alarm/viewmodel/alram_view_model.dart';
import 'package:posterapp/core/storage/app_spacing.dart';
import 'package:posterapp/login/viewmodel/login_view_model.dart';
import 'package:ringtone_set_plus/ringtone_set_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../payment/view/payment_screen.dart';
import '../../resource/values/Status.dart';
import '../../resource/widgets/helper/RetryState.dart';
import '../../core/database/BharatStorage.dart';
import '../../ringtone/viewmodel/audio_ringtone_view_model.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  late final AudioRingtoneViewModel audioCtr;
  late final AlarmViewModel controller;

  // Saffron / amber devotional palette — matches MantraTile.
  static const _bgStart = Color(0xFFFFF4E0);
  static const _bgEnd = Color(0xFFFFE0B3);
  static const _accent = Color(0xFFE67E22);

  @override
  void initState() {
    super.initState();
    audioCtr = Get.put(AudioRingtoneViewModel());
    // AlarmViewModel.onInit() issues the fetch; don't call it again here or
    // two concurrent requests race to write the status.
    controller = Get.put(AlarmViewModel());
  }

  @override
  void dispose() {
    audioCtr.stopAudio();
    Get.delete<AlarmViewModel>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(BharatStorage.getSubscription()==true){
      dashCtr.isSubsribed.value=true;
    }else{
      dashCtr.isSubsribed.value=false;
    }
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.arrow_back)),
        title: Text("Alarm List"),
      ),
      body: Obx(() {
        final status = controller.rxAlarmRequestStatus.value;

        if (status == Status.initial || status == Status.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (status == Status.error) {
          return RetryState(
            message: controller.errorMessage.value.isEmpty
                ? "Something went wrong"
                : controller.errorMessage.value,
            onRetry: controller.getAlarmList,
          );
        }

        final model = controller.alarmListModel.value;

        if (model == null || model.postData.isEmpty) {
          return RetryState(
            message: "No Alarms Found",
            icon: Icons.alarm_off_outlined,
            iconColor: AppColors.grey,
            onRetry: controller.getAlarmList,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: model.postData.length,
          itemBuilder: (context, index) {
            final post = model.postData[index];

            return Obx(() {
              final isExpanded = audioCtr.playingIndex.value == index;
              final isPlaying = audioCtr.isPlaying.value && isExpanded;

              return InkWell(
                borderRadius: BorderRadius.circular(20),

                /// TAP FULL CARD
                onTap: () {
                  if (BharatStorage.getSubscription() == true) {
                    audioCtr.playingIndex.value = index; // open card instantly
                    audioCtr.playPause(index, post.alarmUrl);
                  } else {
                    Get.to(() => const PaymentScreen());
                  }
                },

                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_bgStart, _bgEnd],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _accent.withValues(alpha: 0.22),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _accent.withValues(alpha: 0.25),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _accent.withValues(alpha: 0.18),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Image.network(
                                post.thumbnail,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.music_note_outlined,size: 30,);
                                },
                              ),
                            ),
                          ),
                          AppSpacing.width(14),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                    color: Colors.black87,
                                  ),
                                ),
                                AppSpacing.height(4),
                                Text(
                                  post.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.35,
                                    color:
                                        AppColors.grey.withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// PLAY / PAUSE BUTTON
                          Material(
                            color: _accent,
                            shape: const CircleBorder(),
                            elevation: 3,
                            shadowColor: _accent.withValues(alpha: 0.5),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {
                                if (BharatStorage.getSubscription() == true) {
                                  audioCtr.playPause(index, post.alarmUrl);
                                } else {
                                  Get.to(() => const PaymentScreen());
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 22,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      /// EXPANDED CONTROLS
                      if (isExpanded)
                        Obx(() {
                          final duration = audioCtr.duration.value.inSeconds.toDouble();
                          final position = audioCtr.position.value.inSeconds.toDouble();

                          return Column(
                            children: [
                              AppSpacing.height(10),

                              /// PROGRESS SLIDER
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: _accent,
                                  inactiveTrackColor: _accent.withValues(alpha: 0.25),
                                  thumbColor: _accent,
                                  overlayColor: _accent.withValues(alpha: 0.2),
                                  trackHeight: 3,
                                ),
                                child: Slider(
                                  min: 0,
                                  max: duration == 0 ? 1 : duration,
                                  value: position.clamp(0, duration),
                                  onChanged: (value) {
                                    audioCtr.seek(value);
                                  },
                                ),
                              ),

                              /// TIME DISPLAY
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      audioCtr.formatTime(audioCtr.position.value),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black.withValues(alpha: 0.65),
                                      ),
                                    ),
                                    Text(
                                      audioCtr.formatTime(audioCtr.duration.value),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black.withValues(alpha: 0.65),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              AppSpacing.height(12),

                              /// SET RINGTONE BUTTON
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    if (BharatStorage.getSubscription() == true) {
                                      final ok =
                                      await setToneAccurate(audioUrl: post.alarmUrl, type: 'alarm');
                                      if (ok) {
                                        audioCtr.stopAudio();
                                        Fluttertoast.showToast(
                                          msg: "Alarm set successfully",
                                          gravity: ToastGravity.CENTER,
                                        );
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: "Failed to set alarm",
                                          gravity: ToastGravity.CENTER,
                                        );
                                      }
                                    } else {
                                      Get.to(() => PaymentScreen());
                                    }
                                  },
                                  icon: const Icon(Icons.alarm_rounded, size: 18),
                                  label: const Text(
                                    "Set as Alarm",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _accent,
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shadowColor: _accent.withValues(alpha: 0.5),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        })
                    ],
                  ),
                ),
              );
            });
          },
        );
      }),
    );
  }


  Future<bool> setToneAccurate({
    required String audioUrl,
    required String type,
  }) async {
    bool success = false;
    String fileName = "sanatan_tone.mp3";

    try {
      switch (type) {
        case "ringtone":
          success = await RingtoneSet.setRingtoneFromNetwork(audioUrl);
          break;

        case "alarm":
          success = await RingtoneSet.setAlarmFromNetwork(audioUrl);
          break;


      }
    } catch (e) {
      success = false;
    }

    if (!success) {
      try {
        final dir = await getExternalStorageDirectory();
        final filePath = "${dir!.path}/$fileName";

        final uri = Uri.parse(audioUrl);
        final response = await HttpClient().getUrl(uri).then((r) => r.close());

        if (response.statusCode == 200) {
          final bytes = await consolidateHttpClientResponseBytes(response);

          final file = File(filePath);
          await file.writeAsBytes(bytes);

          switch (type) {
            case "ringtone":
              success = await RingtoneSet.setRingtoneFromFile(file);
              break;

            case "alarm":
              success = await RingtoneSet.setAlarmFromFile(file);
              break;

          }
        }
      } catch (e) {
        success = false;
      }
    }

    return success;
  }

  Future<void> handleToneSet({
    required BuildContext context,
    required int id,
    required String title,
    required String audioUrl,
    required String type, // ringtone | alarm | message
  }) async {
    final AudioRingtoneViewModel audioVM = Get.find();

     await setToneAccurate(
      audioUrl: audioUrl,
      type: type,
    );




  }




}

