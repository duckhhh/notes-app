import 'package:get/get.dart';
import 'package:notes_app/app/modules/home/bindings/home_binding.dart';
import 'package:notes_app/app/modules/home/views/home_view.dart';
import 'package:notes_app/app/modules/note/bindings/note_binding.dart';
import 'package:notes_app/app/modules/note/views/note_view.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.NOTE,
      page: () => const NoteView(),
      binding: NoteBinding(),
    ),
  ];
}
