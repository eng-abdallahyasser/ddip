import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Email
                    TextFormField(
                      controller: controller.emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: controller.validateEmail,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: controller.passwordCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: controller.validatePassword,
                    ),
                    const SizedBox(height: 16),

                    // Confirm
                    TextFormField(
                      controller: controller.confirmCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Confirm password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: controller.validateConfirm,
                    ),
                    const SizedBox(height: 16),

                    // Register button
                    Obx(() => FilledButton(
                          onPressed: controller.isLoading.value ? null : controller.register,
                          child: controller.isLoading.value
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Sign up'),
                        )),

                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Back to Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
