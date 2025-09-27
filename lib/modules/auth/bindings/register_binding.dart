import 'package:get/get.dart';

import '../../../data/services/auth_service.dart';
import '../controllers/register_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService());
    Get.lazyPut<RegisterController>(() => RegisterController(Get.find<AuthService>()));
  }
}
