import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:metal_weight/core/constants/app_colors.dart';
import 'package:metal_weight/screens/navigation/main_nav_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _loopController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _lineExpand;
  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;

  late Animation<double> _floatAnimation;
  late Animation<double> _haloScale;
  late Animation<double> _haloOpacity;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation (Distinct zoom, pop-in and slide)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.40, curve: Curves.easeIn),
      ),
    );

    _logoScale = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.70, curve: Curves.easeOutBack),
      ),
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.60),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _lineExpand = Tween<double>(begin: 0.0, end: 42.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.50, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.60, 1.0, curve: Curves.easeOut),
      ),
    );

    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.60),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.60, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Visible continuous floating & halo pulse animation
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(
        parent: _loopController,
        curve: Curves.easeInOutSine,
      ),
    );

    _haloScale = Tween<double>(begin: 0.95, end: 1.25).animate(
      CurvedAnimation(
        parent: _loopController,
        curve: Curves.easeInOutSine,
      ),
    );

    _haloOpacity = Tween<double>(begin: 0.30, end: 0.08).animate(
      CurvedAnimation(
        parent: _loopController,
        curve: Curves.easeInOutSine,
      ),
    );

    _entranceController.forward();

    // 3. Navigation to MainNavScreen with smooth fade
    _navigationTimer = Timer(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainNavScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _entranceController.dispose();
    _loopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Distinct Animated Logo with Floating Motion & Halo Pulse
                      FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: AnimatedBuilder(
                            animation: _loopController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _floatAnimation.value),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Ambient Orange Halo Pulse
                                    Transform.scale(
                                      scale: _haloScale.value,
                                      child: Container(
                                        height: 180,
                                        width: 180,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(32),
                                          color: AppColors.secondaryOrange
                                              .withValues(alpha: _haloOpacity.value),
                                        ),
                                      ),
                                    ),
                                    _buildLogo(_floatAnimation.value),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Animated Title
                      FadeTransition(
                        opacity: _titleFade,
                        child: SlideTransition(
                          position: _titleSlide,
                          child: const Text(
                            'Milen Trading',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Animated Brand Accent Line
                      AnimatedBuilder(
                        animation: _lineExpand,
                        builder: (context, child) {
                          return Container(
                            width: _lineExpand.value,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryOrange,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      // Animated Subtitle
                      FadeTransition(
                        opacity: _subtitleFade,
                        child: SlideTransition(
                          position: _subtitleSlide,
                          child: const Text(
                            'STRUCTURAL CALCULATOR',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.0,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 48.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StaggeredPulseLoadingDots(color: AppColors.secondaryOrange),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(double floatOffset) {
    final double dynamicBlur = 18.0 + (floatOffset + 8.0) * 0.7;
    return Container(
      height: 180,
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: dynamicBlur,
            offset: Offset(0, 6 + (floatOffset + 8.0) * 0.25),
          ),
          BoxShadow(
            color: AppColors.secondaryOrange.withValues(alpha: 0.16),
            blurRadius: dynamicBlur * 1.3,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.asset(
          'assets/images/image.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(
                Icons.precision_manufacturing,
                size: 70,
                color: AppColors.primaryDark,
              ),
            );
          },
        ),
      ),
    );
  }
}

class StaggeredPulseLoadingDots extends StatefulWidget {
  final Color color;

  const StaggeredPulseLoadingDots({super.key, required this.color});

  @override
  State<StaggeredPulseLoadingDots> createState() =>
      _StaggeredPulseLoadingDotsState();
}

class _StaggeredPulseLoadingDotsState extends State<StaggeredPulseLoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(double delay) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = (_controller.value - delay) % 1.0;
        final wave = math.sin(progress * 2 * math.pi);
        final jump = wave > 0 ? wave * 6.0 : 0.0;
        final scaleValue = 0.9 + (wave > 0 ? wave * 0.35 : 0.0);

        return Transform.translate(
          offset: Offset(0, -jump),
          child: Transform.scale(
            scale: scaleValue,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: wave > 0 ? 1.0 : 0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(0.0),
        const SizedBox(width: 8),
        _buildDot(0.18),
        const SizedBox(width: 8),
        _buildDot(0.36),
      ],
    );
  }
}
