import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:posterapp/core/storage/app_spacing.dart';
import 'package:posterapp/payment/viewmodel/payment_view_model.dart';

import '../../core/theme/app_colors.dart';

class VerifyPaymentPage extends StatefulWidget {
  const VerifyPaymentPage({super.key});

  @override
  State<VerifyPaymentPage> createState() => _VerifyPaymentPageState();
}

class _VerifyPaymentPageState extends State<VerifyPaymentPage>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _pulseController;
  late final AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    paymentCtr.startVerifyPaymentPolling();
    paymentCtr.videoController?.pause();
  }

  @override
  void dispose() {
    paymentCtr.cancelVerifyPaymentPolling();
    _rotationController.dispose();
    _pulseController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8EC),
              AppColors.bgColor,
              Color(0xFFE8CFA8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAnimatedLogo(),
                  AppSpacing.height(40),
                  _buildTitle(),
                  AppSpacing.height(14),
                  _buildSubtitle(),
                  AppSpacing.height(36),
                  // _buildLinearLoader(),
                   AppSpacing.height(28),
                  _buildSecurityBadge(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) {
              final t = Curves.easeInOut.transform(_pulseController.value);
              return Container(
                width: 160 + (t * 20),
                height: 160 + (t * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor.withValues(alpha: 0.12 - (t * 0.10)),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _rotationController,
            builder: (_, __) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        AppColors.primaryColor.withValues(alpha: 0.0),
                        AppColors.primaryColor.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.25),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              size: 58,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      "Verifying Payment",
      style: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.black,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildSubtitle() {
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (_, __) {
        final dots = ((_dotsController.value * 4).floor() % 4);
        final suffix = "." * dots;
        return Text(
          "Please wait while we confirm your transaction$suffix",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.w400,
            color: AppColors.black.withValues(alpha: 0.65),
          ),
        );
      },
    );
  }

  // Widget _buildLinearLoader() {
  //   return ClipRRect(
  //     borderRadius: BorderRadius.circular(20),
  //     child: SizedBox(
  //       width: 180,
  //       height: 6,
  //       child: LinearProgressIndicator(
  //         backgroundColor: AppColors.primaryColor.withValues(alpha: 0.15),
  //         valueColor:
  //             const AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSecurityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lock_rounded,
            size: 16,
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            "Secured by Razorpay",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.black.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}