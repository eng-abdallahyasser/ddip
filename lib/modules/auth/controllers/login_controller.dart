import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  LoginController(this._auth);

  final AuthService _auth;

  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  final isLoading = false.obs;

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^\S+@\S+\.\S+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 6) return 'Min 6 characters';
    return null;
  }

  Future<void> loginWithEmail() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    try {
      final ok = await _auth.signInWithEmail(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text,
      );
      if (ok) {
        Get.snackbar('Success', 'Logged in successfully');
        Get.offAllNamed(Routes.home);
      } else {
        Get.snackbar('Error', 'Invalid email or password', backgroundColor: Colors.red.shade100);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      final ok = await _auth.signInWithGoogle();
      if (ok) {
        Get.snackbar('Success', 'Google sign-in success');
        Get.offAllNamed(Routes.home);
      } else {
        Get.snackbar('Error', 'Google sign-in cancelled/failed', backgroundColor: Colors.red.shade100);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() => Get.toNamed(Routes.register);

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}
