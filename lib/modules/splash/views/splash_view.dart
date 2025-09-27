import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../routes/app_pages.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // small delay to allow Firebase to restore the auth state
    await Future.delayed(const Duration(milliseconds: 200));
    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;
    if (user != null) {
      Get.offAllNamed(Routes.home);
    } else {
      Get.offAllNamed(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App logo (optional)
            const FlutterLogo(size: 72),
            const SizedBox(height: 16),
            Text('DDIP', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            const SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
