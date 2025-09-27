import 'package:get/get.dart';

import '../../../data/services/auth_service.dart';
import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService());
    Get.lazyPut<LoginController>(() => LoginController(Get.find<AuthService>()));
  }
}
