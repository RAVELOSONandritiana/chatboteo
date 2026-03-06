import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/droid_logo.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with fade in animation
            const DroidLogo(size: 150)
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .fadeIn(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                )
                .then()
                .shimmer(
                  duration: const Duration(milliseconds: 1500),
                  color: AppTheme.accentColor.withValues(alpha: 0.3),
                ),
            
            const SizedBox(height: 40),
            
            // App name with fade in animation
            Text(
              'ChatBoteo',
              style: GoogleFonts.poppins(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                letterSpacing: 2,
              ),
            )
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 500),
                  duration: const Duration(milliseconds: 800),
                )
                .slideY(
                  begin: 0.3,
                  end: 0,
                  curve: Curves.easeOutBack,
                ),
            
            const SizedBox(height: 12),
            
            // Tagline
            Text(
              'Powered by Puter.ai',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: isDark ? Colors.white60 : Colors.black45,
                letterSpacing: 1,
              ),
            )
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 800),
                  duration: const Duration(milliseconds: 800),
                ),
            
            const SizedBox(height: 60),
            
            // Loading indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor.withValues(alpha: 0.7),
                ),
              ),
            )
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 1200),
                  duration: const Duration(milliseconds: 600),
                ),
          ],
        ),
      ),
    );
  }
}
