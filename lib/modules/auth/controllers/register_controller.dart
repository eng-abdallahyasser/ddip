import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class RegisterController extends GetxController {
  RegisterController(this._auth);

  final AuthService _auth;

  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

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

  String? validateConfirm(String? value) {
    if (value != passwordCtrl.text) return 'Passwords do not match';
    return null;
  }

  Future<void> register() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    try {
      final ok = await _auth.registerWithEmail(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text,
      );
      if (ok) {
        Get.snackbar('Success', 'Account created');
        Get.offAllNamed(Routes.home);
      } else {
        Get.snackbar('Error', 'Registration failed', backgroundColor: Colors.red.shade100);
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.onClose();
  }
}
