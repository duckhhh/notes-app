import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes_app/app/data/database_service.dart';
import 'package:notes_app/app/data/note_model.dart';

class NoteController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  
  final RxBool isEditing = false.obs;
  final RxBool isSaving = false.obs;
  
  Note? originalNote;
  
  @override
  void onInit() {
    super.onInit();
    
    if (Get.arguments != null && Get.arguments is Note) {
      originalNote = Get.arguments as Note;
      isEditing.value = true;
      
      titleController.text = originalNote!.title;
      contentController.text = originalNote!.content;
    }
  }
  
  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }
  
  bool validateForm() {
    final titleValid = titleController.text.trim().isNotEmpty;
    final contentValid = contentController.text.trim().isNotEmpty;
    return titleValid && contentValid;
  }
  
  String? getTitleError() {
    return titleController.text.trim().isEmpty ? 'Title cannot be empty' : null;
  }
  
  String? getContentError() {
    return contentController.text.trim().isEmpty ? 'Content cannot be empty' : null;
  }
  
  Future<bool> saveNote() async {
    if (!validateForm()) {
      return false;
    }
    
    isSaving.value = true;
    
    try {
      final now = DateTime.now();
      
      if (isEditing.value) {
        final updatedNote = originalNote!.copyWith(
          title: titleController.text.trim(),
          content: contentController.text.trim(),
          updatedAt: now,
        );
        
        await _databaseService.updateNote(updatedNote);
      } else {
        final newNote = Note(
          title: titleController.text.trim(),
          content: contentController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        
        await _databaseService.insertNote(newNote);
      }
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save note: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
