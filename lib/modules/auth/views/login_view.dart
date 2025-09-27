import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';
import '../../../../routes/app_pages.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
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
                    // Logo
                    Center(
                      child: Image.asset(
                        'assets/images/ddip_logo.jpg',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Welcome back', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('Sign in to continue', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
                    const SizedBox(height: 24),

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

                    // Login button
                    Obx(() => FilledButton(
                          onPressed: controller.isLoading.value ? null : controller.loginWithEmail,
                          child: controller.isLoading.value
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Login'),
                        )),

                    const SizedBox(height: 12),

                    // Google button
                    OutlinedButton.icon(
                      onPressed: controller.loginWithGoogle,
                      icon: Image.asset('assets/images/google.png', width: 24, height: 24),
                      label: const Text('Continue with Google'),
                    ),

                    const SizedBox(height: 16),

                    // Go to register
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () => Get.toNamed(Routes.register),
                          child: const Text('Create one'),
                        ),
                      ],
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
