import 'package:ddip/upload_samples.dart';
import 'package:get/get.dart';

import '../modules/auth/bindings/login_binding.dart';
import '../modules/auth/bindings/register_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/main/views/main_view.dart';
import '../data/services/auth_service.dart';
import '../data/repositories/drugs_repository.dart';
import '../data/repositories/drugs_firestore_repository.dart';
import '../data/repositories/interactions_repository.dart';
import '../data/repositories/interactions_firestore_repository.dart';
import '../modules/interaction/bindings/interaction_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final routes = <GetPage<dynamic>>[
    GetPage(name: Routes.splash, page: () => const SplashView()),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const MainView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthService>(() => AuthService());
        Get.lazyPut<DrugsRepository>(() => DrugsFirestoreRepository());
        Get.lazyPut<InteractionsRepository>(
          () => InteractionsFirestoreRepository(),
        );
        // register interaction controller lazily via binding
        InteractionBinding().dependencies();
      }),
    ),
    GetPage(name: Routes.uploadSamples, page: () => const UploadSamplesPage()),
  ];
}
