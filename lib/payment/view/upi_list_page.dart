// import 'package:animated_line_through/animated_line_through.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:posterapp/myProfile/viewmodel/my_profile_view_model.dart';
// import 'package:posterapp/payment/viewmodel/payment_view_model.dart';
//
// import '../../resource/values/BharatDimension.dart';
//
// class UpiListPage extends StatefulWidget {
//   String amount;
//   String planName;
//   String actualAmount;
//   String validity;
//
//   UpiListPage({
//     super.key,
//     required this.actualAmount,
//     required this.amount,
//     required this.validity,
//     required this.planName,
//   });
//
//   @override
//   State<UpiListPage> createState() => _UpiListPageState();
// }
//
// class _UpiListPageState extends State<UpiListPage>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   MyProfileViewModel profileCtr = Get.put(MyProfileViewModel());
//   PaymentViewModel payCtr = Get.put(PaymentViewModel());
//
//   @override
//   void initState() {
//     _controller = AnimationController(vsync: this);
//     paymentCtr.isProgressLoad.value = true;
//
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade200,
//       appBar: AppBar(
//         elevation: 1,
//         leading: InkWell(
//           onTap: () {
//             Get.back();
//           },
//           child: Icon(
//             Icons.arrow_back,
//           ),
//         ),
//         title: Text(
//           "payment".tr,
//           style: BharatDimension.fontFamily(
//               color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
//         ),
//         actions: [
//           Image.asset(
//             "assets/images/secure.jpg",
//           )
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding:
//                 const EdgeInsets.only(left: 8.0, right: 8, top: 18, bottom: 15),
//             child: Container(
//               height: 80,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   color: const Color(0xFF9559).withValues(alpha: 0.2),
//                   border: Border.all(color: Colors.redAccent)),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   Container(
//                       height: 45,
//                       width: 45,
//                       decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.white,
//                           border: Border.all(
//                               color: const Color(0xFFFF9559), width: 2)),
//                       child: ClipOval(
//                         child: Image.network(
//                           profileCtr.avatar.value,
//                           fit: BoxFit.contain,
//                         ),
//                       )),
//                   SizedBox(
//                     width: Get.width * 0.46,
//                     child: ListTile(
//                       title: Text(
//                         profileCtr.nameCtr.value.text,
//                         overflow: TextOverflow.ellipsis,
//                         softWrap: true,
//                         maxLines: 1,
//                         style: BharatDimension.fontFamily(
//                             fontSize: 12, fontWeight: FontWeight.w500),
//                       ),
//                       subtitle: Text("Islamic Posters Premium",
//                           overflow: TextOverflow.ellipsis,
//                           softWrap: true,
//                           maxLines: 1,
//                           style: BharatDimension.fontFamily(
//                               fontSize: 11, fontWeight: FontWeight.w400)),
//                     ),
//                   ),
//                   SizedBox(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                          Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(
//                               Icons.currency_rupee,
//                               size: 15,
//                             ),
//                             AnimatedLineThrough(
//                               isCrossed: true,
//                               color: Colors.black,
//                               duration: const Duration(seconds: 1),
//                               child: Text(widget.amount,
//                                   ),
//                             ),
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             Text(
//                               widget.planName,
//                               style: GoogleFonts.poppins(fontSize: 12),
//                             ),
//                             const Icon(
//                               Icons.currency_rupee,
//                               size: 15,
//                             ),
//                             Text(
//                               widget.actualAmount,
//                               maxLines: 1,
//                               style: BharatDimension.fontFamily(
//                                   fontSize: 12, fontWeight: FontWeight.w500),
//                             ),
//                           ],
//                         ),
//                         Text(
//                           widget.validity,
//                           maxLines: 1,
//                           style: BharatDimension.fontFamily(
//                               fontSize: 11, fontWeight: FontWeight.w400),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 10.0),
//             child: Container(
//                 width: Get.width,
//                 color: Colors.white,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding:
//                           const EdgeInsets.only(left: 8.0, top: 6, right: 7),
//                       child: Container(
//                         decoration: const BoxDecoration(shape: BoxShape.circle),
//                         child: ClipOval(
//                           child: Image.asset(
//                             "assets/images/upi.jpg",
//                             height: 70,
//                             width: 70,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Visibility(
//                       // visible: paymentCtr.mGpayInstalled.value,
//                       child: Row(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.only(
//                                 left: 8.0, right: 6, top: 10, bottom: 12),
//                             child: ClipOval(
//                                 child: Image.asset(
//                               "assets/images/gpay.jpg",
//                               height: 60,
//                               width: 60,
//                             )),
//                           ),
//                           Text(
//                             "GPay",
//                             style: GoogleFonts.poppins(fontSize: 14),
//                           )
//                         ],
//                       ),
//                     ),
//                     Visibility(
//                       // visible: paymentCtr.mPaytmInstalled.value,
//                       child: Row(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.only(
//                                 left: 8.0, right: 6, top: 10, bottom: 10),
//                             child: ClipOval(
//                               child: Image.asset(
//                                 "assets/images/paytm1.png",
//                                 height: 50,
//                                 width: 50,
//                               ),
//                             ),
//                           ),
//                           Text(
//                             "Paytm",
//                             style: GoogleFonts.poppins(fontSize: 14),
//                           )
//                         ],
//                       ),
//                     ),
//                     Visibility(
//                       // visible: paymentCtr.mPhonePeInstalled.value,
//                       child: Column(
//                         children: [
//                           Row(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.only(
//                                     left: 8.0, right: 6, top: 10),
//                                 child: ClipOval(
//                                     child: Image.asset(
//                                   "assets/images/phonePay.png",
//                                   height: 50,
//                                   width: 50,
//                                 )),
//                               ),
//                               Text(
//                                 "PhonePe",
//                                 style: GoogleFonts.poppins(fontSize: 14),
//                               )
//                             ],
//                           ),
//                           Align(
//                             alignment: Alignment.centerRight,
//                             child: Container(
//                               height: 65,
//                               width: Get.width * 0.8,
//                               padding: const EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10)),
//                               child: ElevatedButton(
//                                   style: ButtonStyle(
//                                     backgroundColor: WidgetStatePropertyAll(
//                                         Colors.deepPurpleAccent.shade700),
//                                   ),
//                                   onPressed: () {
//                                     // CircularProgressIndicator();
//                                     // payCtr.creatSubscription(9900, "com.google.android.apps.nbu.paisa.user");
//                                     //Get.to(PaymentProcessingPage());
//                                   },
//                                   child: Text(
//                                     "PAY USING PHONEPE",
//                                     style: GoogleFonts.poppins(
//                                         color: Colors.white,
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w600),
//                                   )),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 )),
//           )
//         ],
//       ),
//     );
//   }
// }
