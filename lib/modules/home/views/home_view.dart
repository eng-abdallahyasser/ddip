import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/auth_service.dart';
import '../../../../routes/app_pages.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('DDIP Home'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              Get.offAllNamed(Routes.login);
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome to DDIP — Drug-Drug Interactions app'),
      ),
    );
  }
}
