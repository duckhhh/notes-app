import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes_app/app/modules/note/controllers/note_controller.dart';
import 'package:notes_app/app/utils/responsive_helper.dart';

class NoteView extends GetView<NoteController> {
  const NoteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditing.value ? 'Edit Note' : 'New Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        // Create responsive layout based on screen size
        return Center(
          child: Container(
            width: ResponsiveHelper.isMobile(context)
                ? constraints.maxWidth
                : constraints.maxWidth * 0.7,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: controller.titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter note title',
                  ),
                  style: TextStyle(
                    fontSize: ResponsiveHelper.isMobile(context) ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TextField(
                    controller: controller.contentController,
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      hintText: 'Enter note content',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(
                      fontSize: ResponsiveHelper.isMobile(context) ? 16 : 18,
                    ),
                    maxLines: null,
                    expands: true,
                    textCapitalization: TextCapitalization.sentences,
                    textAlignVertical: TextAlignVertical.top,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _saveNote() async {
    if (!controller.validateForm()) {
      Get.snackbar(
        'Validation Error',
        'Title and content cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 3),
      );
      return;
    }
    
    final loadingOverlay = _buildLoadingOverlay();
    Get.dialog(loadingOverlay, barrierDismissible: false);
    
    try {
      final success = await controller.saveNote();
      
      Get.back();
      
      if (success) {
        Get.back();
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Something went wrong: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildLoadingOverlay() {
    return const Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
