import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:metal_weight/core/constants/app_colors.dart';
import 'package:metal_weight/screens/navigation/main_nav_screen.dart';

enum SplashTheme {
  blueprint, // Style 1: Dark Industrial CAD Blueprint
  metallicSlate, // Style 2: Premium Metallic Steel Slate
}

class SplashScreen extends StatefulWidget {
  /// Toggle between Style 1 (blueprint) and Style 2 (metallicSlate)
  final SplashTheme theme;

  const SplashScreen({
    super.key,
    this.theme = SplashTheme.blueprint,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _loopController;
  late AnimationController _shimmerController;

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

    _lineExpand = Tween<double>(begin: 0.0, end: 46.0).animate(
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

    // 3. Metallic Light Sweep (Gloss sheen running diagonally)
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _entranceController.forward();

    // 4. Navigation to MainNavScreen with smooth fade transition
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
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.theme == SplashTheme.metallicSlate) {
      return _buildMetallicSlateTheme(context);
    } else {
      return _buildBlueprintTheme(context);
    }
  }

  // ===========================================================================
  // STYLE 2: PREMIUM METALLIC STEEL SLATE
  // ===========================================================================
  Widget _buildMetallicSlateTheme(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101216),
      body: Stack(
        children: [
          // 1. Brushed Charcoal / Steel Slate Radial Gradient Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.12),
                  radius: 1.15,
                  colors: [
                    Color(0xFF242A36), // Brushed Titanium Slate core
                    Color(0xFF161920), // Dark Charcoal
                    Color(0xFF0C0E12), // Obsidian Shadow
                  ],
                  stops: [0.0, 0.60, 1.0],
                ),
              ),
            ),
          ),

          // 2. Subtle Brushed Metal Texture Lines
          const Positioned.fill(
            child: CustomPaint(
              painter: MetallicHairlinesPainter(),
            ),
          ),

          // 3. Subtle Metallic Corner Pins
          _buildMetallicCornerPin(Alignment.topLeft),
          _buildMetallicCornerPin(Alignment.topRight),
          _buildMetallicCornerPin(Alignment.bottomLeft),
          _buildMetallicCornerPin(Alignment.bottomRight),

          // 4. Central Animated Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Floating Logo with Metallic Bevel Frame & Shimmer Glare
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
                                        // Warm Amber/Steel Rim Halo Glow
                                        Transform.scale(
                                          scale: _haloScale.value,
                                          child: Container(
                                            height: 180,
                                            width: 180,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(32),
                                              color: AppColors.secondaryOrange
                                                  .withValues(alpha: _haloOpacity.value * 0.7),
                                            ),
                                          ),
                                        ),
                                        _buildMetallicLogoCard(_floatAnimation.value),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 34),
                          // Platinum Title with Embossed Shadow
                          FadeTransition(
                            opacity: _titleFade,
                            child: SlideTransition(
                              position: _titleSlide,
                              child: Text(
                                'Milen Trading',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: Colors.white,
                                  shadows: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Polished Gold/Amber Metallic Divider
                          AnimatedBuilder(
                            animation: _lineExpand,
                            builder: (context, child) {
                              return Container(
                                width: _lineExpand.value,
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Color(0xFFE67E22),
                                      Color(0xFFFFB300),
                                      Color(0xFFE67E22),
                                      Colors.transparent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFB300).withValues(alpha: 0.5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          // Brushed Silver / Titanium Subtitle
                          FadeTransition(
                            opacity: _subtitleFade,
                            child: SlideTransition(
                              position: _subtitleSlide,
                              child: const Text(
                                'STRUCTURAL CALCULATOR',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 3.5,
                                  color: Color(0xFFC0C7D5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // 5. Bottom Corporate Precision Indicator
                const Padding(
                  padding: EdgeInsets.only(bottom: 36.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'PRECISION INDUSTRIAL METALS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.5,
                          color: Color(0xFF8A93A6),
                        ),
                      ),
                      SizedBox(height: 12),
                      StaggeredPulseLoadingDots(color: AppColors.secondaryOrange),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetallicCornerPin(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF3A4150),
              border: Border.all(
                color: const Color(0xFF5A6376),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetallicLogoCard(double floatOffset) {
    final double dynamicBlur = 24.0 + (floatOffset + 8.0) * 0.8;
    return Container(
      height: 180,
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF6B7688).withValues(alpha: 0.45),
          width: 1.8,
        ),
        boxShadow: [
          // Deep Graphite Shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: dynamicBlur,
            offset: Offset(0, 8 + (floatOffset + 8.0) * 0.3),
          ),
          // Warm Polished Amber Edge Glow
          BoxShadow(
            color: AppColors.secondaryOrange.withValues(alpha: 0.28),
            blurRadius: dynamicBlur * 1.3,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // The Logo Image
            Image.asset(
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

            // Diagonal Metallic Light Sheen / Shimmer Sweep
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                final double pos = _shimmerController.value * 2.8 - 0.9;
                return ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment(pos - 0.5, -1.0),
                      end: Alignment(pos + 0.5, 1.0),
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.45), // Glare peak
                        Colors.transparent,
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.40, 0.50, 0.60, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcATop,
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.01),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // STYLE 1: DARK INDUSTRIAL CAD BLUEPRINT
  // ===========================================================================
  Widget _buildBlueprintTheme(BuildContext context) {
    const Color blueprintDark = Color(0xFF0F1D38);
    const Color cyanAccent = Color(0xFF00E5FF);

    return Scaffold(
      backgroundColor: blueprintDark,
      body: Stack(
        children: [
          // 1. Technical CAD Blueprint Grid Background
          const Positioned.fill(
            child: CustomPaint(
              painter: BlueprintGridPainter(),
            ),
          ),

          // 2. Technical CAD Corner Brackets
          _buildCadCorner(Alignment.topLeft, cyanAccent),
          _buildCadCorner(Alignment.topRight, cyanAccent),
          _buildCadCorner(Alignment.bottomLeft, cyanAccent),
          _buildCadCorner(Alignment.bottomRight, cyanAccent),

          // 3. Central Animated Logo & Typography
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                                        Transform.scale(
                                          scale: _haloScale.value,
                                          child: Container(
                                            height: 180,
                                            width: 180,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(32),
                                              color: cyanAccent.withValues(
                                                  alpha: _haloOpacity.value * 0.6),
                                            ),
                                          ),
                                        ),
                                        _buildBlueprintLogo(_floatAnimation.value, cyanAccent),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          FadeTransition(
                            opacity: _titleFade,
                            child: SlideTransition(
                              position: _titleSlide,
                              child: const Text(
                                'Milen Trading',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          AnimatedBuilder(
                            animation: _lineExpand,
                            builder: (context, child) {
                              return Container(
                                width: _lineExpand.value,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryOrange,
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.secondaryOrange.withValues(alpha: 0.6),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          FadeTransition(
                            opacity: _subtitleFade,
                            child: SlideTransition(
                              position: _subtitleSlide,
                              child: const Text(
                                'STRUCTURAL CALCULATOR',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 3.0,
                                  color: cyanAccent,
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
                  padding: EdgeInsets.only(bottom: 36.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'INITIALIZING SYSTEM...',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.5,
                          color: Colors.white54,
                        ),
                      ),
                      SizedBox(height: 12),
                      StaggeredPulseLoadingDots(color: AppColors.secondaryOrange),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCadCorner(Alignment alignment, Color color) {
    return Align(
      alignment: alignment,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              border: Border(
                top: alignment == Alignment.topLeft || alignment == Alignment.topRight
                    ? BorderSide(color: color.withValues(alpha: 0.4), width: 1.5)
                    : BorderSide.none,
                bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight
                    ? BorderSide(color: color.withValues(alpha: 0.4), width: 1.5)
                    : BorderSide.none,
                left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft
                    ? BorderSide(color: color.withValues(alpha: 0.4), width: 1.5)
                    : BorderSide.none,
                right: alignment == Alignment.topRight || alignment == Alignment.bottomRight
                    ? BorderSide(color: color.withValues(alpha: 0.4), width: 1.5)
                    : BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlueprintLogo(double floatOffset, Color cyanAccent) {
    final double dynamicBlur = 24.0 + (floatOffset + 8.0) * 0.8;
    return Container(
      height: 180,
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        border: Border.all(
          color: cyanAccent.withValues(alpha: 0.45),
          width: 1.8,
        ),
        boxShadow: [
          // Luminous Blueprint Cyan Neon Glow
          BoxShadow(
            color: cyanAccent.withValues(alpha: 0.35),
            blurRadius: dynamicBlur * 1.2,
            spreadRadius: 2,
            offset: Offset(0, 4 + (floatOffset + 8.0) * 0.25),
          ),
          // Ambient Warm Edge Glow
          BoxShadow(
            color: AppColors.secondaryOrange.withValues(alpha: 0.28),
            blurRadius: dynamicBlur * 1.4,
            spreadRadius: 3,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
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
            // Light sheen shimmer sweep
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                final double pos = _shimmerController.value * 2.8 - 0.9;
                return ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment(pos - 0.5, -1.0),
                      end: Alignment(pos + 0.5, 1.0),
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.35),
                        Colors.transparent,
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.40, 0.50, 0.60, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcATop,
                  child: Container(color: Colors.white.withValues(alpha: 0.01)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Subtle brushed metal hairlines painter for Style 2
class MetallicHairlinesPainter extends CustomPainter {
  const MetallicHairlinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 1.0;

    const double gap = 16.0;
    for (double i = -size.height; i < size.width; i += gap) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height * 0.8, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Technical CAD blueprint grid painter for Style 1
class BlueprintGridPainter extends CustomPainter {
  const BlueprintGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.035)
      ..strokeWidth = 1.0;

    final majorLinePaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.08)
      ..strokeWidth = 1.2;

    const double step = 24.0;
    const double majorStep = 96.0;

    for (double x = 0; x <= size.width; x += step) {
      final isMajor = (x % majorStep).abs() < 1.0;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        isMajor ? majorLinePaint : linePaint,
      );
    }

    for (double y = 0; y <= size.height; y += step) {
      final isMajor = (y % majorStep).abs() < 1.0;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        isMajor ? majorLinePaint : linePaint,
      );
    }

    final markerPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.16)
      ..strokeWidth = 1.0;

    for (double x = majorStep; x < size.width; x += majorStep) {
      for (double y = majorStep; y < size.height; y += majorStep) {
        canvas.drawLine(Offset(x - 3, y), Offset(x + 3, y), markerPaint);
        canvas.drawLine(Offset(x, y - 3), Offset(x, y + 3), markerPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
