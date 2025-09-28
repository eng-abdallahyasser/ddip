import 'package:get/get.dart';
import '../controllers/interaction_controller.dart';
import '../../../data/repositories/interactions_repository.dart';
import '../../../data/repositories/drugs_repository.dart';

class InteractionBinding extends Bindings {
  @override
  void dependencies() {
    // Controller depends on DrugsRepository which should already be registered
    Get.lazyPut<InteractionController>(
      () => InteractionController(
        drugsRepository: Get.find<DrugsRepository>(),
        interactionsRepository: Get.find<InteractionsRepository>(),
      ),
    );
  }
}
