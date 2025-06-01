import 'package:get/get.dart';
import 'package:notes_app/app/modules/note/controllers/note_controller.dart';

class NoteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NoteController>(
      () => NoteController(),
    );
  }
}
