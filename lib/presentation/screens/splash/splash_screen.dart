import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gymmate/core/theme/app_colors.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateXAnimation;
  late Animation<double> _rotateYAnimation;
  late Animation<double> _rotateZAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _buttonScaleAnimation;
  final List<Particle> _particles = [];
  final List<FitnessIcon> _fitnessIcons = [];
  String _displayedText = '';
  int _textIndex = 0;
  final String _fullText = 'Your Personal Fitness Companion';
  Timer? _typingTimer;
  double _progress = 0.0;
  bool _showMotivationalText = false;
  final List<String> _motivationalTexts = [
    'Push Your Limits',
    'Be Stronger Today',
    'Achieve Your Goals',
    'Train Like a Champion',
  ];
  int _currentMotivationalIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeParticles();
    _initializeFitnessIcons();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _rotateXAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _rotateYAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeInOut),
      ),
    );

    _rotateZAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeInOut),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _buttonScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
    _startTypingAnimation();
    _startProgressAnimation();
    _startMotivationalTextAnimation();
  }

  void _initializeParticles() {
    for (int i = 0; i < 30; i++) {
      _particles.add(Particle());
    }
  }

  void _initializeFitnessIcons() {
    final icons = [
      FontAwesomeIcons.dumbbell,
      FontAwesomeIcons.personRunning,
      FontAwesomeIcons.heartPulse,
      FontAwesomeIcons.fire,
      FontAwesomeIcons.trophy,
    ];
    
    for (int i = 0; i < icons.length; i++) {
      _fitnessIcons.add(FitnessIcon(
        icon: icons[i],
        x: math.Random().nextDouble() * 300,
        y: math.Random().nextDouble() * 600,
        size: math.Random().nextDouble() * 20 + 15,
        opacity: math.Random().nextDouble() * 0.3 + 0.1,
        speed: math.Random().nextDouble() * 2 + 1,
        angle: math.Random().nextDouble() * 2 * math.pi,
      ));
    }
  }

  void _startTypingAnimation() {
    _typingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_textIndex < _fullText.length) {
        setState(() {
          _displayedText += _fullText[_textIndex];
          _textIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startProgressAnimation() {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_progress < 1.0) {
        setState(() {
          _progress += 0.01;
        });
      } else {
        timer.cancel();
        _navigateToMain();
      }
    });
  }

  void _startMotivationalTextAnimation() {
    Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _showMotivationalText = true;
        _currentMotivationalIndex = (_currentMotivationalIndex + 1) % _motivationalTexts.length;
      });
      
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _showMotivationalText = false;
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _navigateToMain() {
    Navigator.pushReplacementNamed(context, '/main');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
              Colors.purple,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated particles
            ..._particles.map((particle) => _buildParticle(particle)),
            
            // Fitness icons
            ..._fitnessIcons.map((icon) => _buildFitnessIcon(icon)),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with advanced 3D rotation animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001) // perspective
                              ..rotateX(_rotateXAnimation.value)
                              ..rotateY(_rotateYAnimation.value)
                              ..rotateZ(_rotateZAnimation.value),
                            alignment: Alignment.center,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(_glowAnimation.value * 0.5),
                                    blurRadius: 20 * _glowAnimation.value,
                                    spreadRadius: 5 * _glowAnimation.value,
                                  ),
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(_glowAnimation.value * 0.3),
                                    blurRadius: 30 * _glowAnimation.value,
                                    spreadRadius: 10 * _glowAnimation.value,
                                  ),
                                ],
                              ),
                              child: Transform.translate(
                                offset: Offset(0, -10 * math.sin(_bounceAnimation.value * math.pi * 2)),
                                child: const Icon(
                                  FontAwesomeIcons.dumbbell,
                                  size: 100,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // App name with animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      'GymMate',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Typing animation for tagline
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      _displayedText,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Motivational text
                  AnimatedOpacity(
                    opacity: _showMotivationalText ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _motivationalTexts[_currentMotivationalIndex],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  // Progress indicator
                  Container(
                    width: 250,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Get Started button with animation
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticle(Particle particle) {
    return Positioned(
      left: particle.x,
      top: particle.y,
      child: Container(
        width: particle.size,
        height: particle.size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(particle.opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildFitnessIcon(FitnessIcon icon) {
    return Positioned(
      left: icon.x,
      top: icon.y,
      child: Opacity(
        opacity: icon.opacity,
        child: Icon(
          icon.icon,
          size: icon.size,
          color: Colors.white,
        ),
      ),
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double opacity;
  double speed;
  double angle;

  Particle()
      : x = math.Random().nextDouble() * 400,
        y = math.Random().nextDouble() * 800,
        size = math.Random().nextDouble() * 4 + 2,
        opacity = math.Random().nextDouble() * 0.5 + 0.1,
        speed = math.Random().nextDouble() * 2 + 1,
        angle = math.Random().nextDouble() * 2 * math.pi;

  void update() {
    x += math.cos(angle) * speed;
    y += math.sin(angle) * speed;

    if (x < 0 || x > 400) angle = math.pi - angle;
    if (y < 0 || y > 800) angle = -angle;
  }
}

class FitnessIcon {
  final IconData icon;
  double x;
  double y;
  final double size;
  final double opacity;
  final double speed;
  double angle;

  FitnessIcon({
    required this.icon,
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speed,
    required this.angle,
  });

  void update() {
    x += math.cos(angle) * speed;
    y += math.sin(angle) * speed;

    if (x < 0 || x > 300) angle = math.pi - angle;
    if (y < 0 || y > 600) angle = -angle;
  }
} 