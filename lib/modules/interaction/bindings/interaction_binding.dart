import 'package:get/get.dart';
import '../controllers/interaction_controller.dart';

class InteractionBinding extends Bindings {
  @override
  void dependencies() {
    // Controller depends on DrugsRepository which should already be registered
    Get.lazyPut<InteractionController>(
      () => InteractionController(repository: Get.find()),
    );
  }
}
