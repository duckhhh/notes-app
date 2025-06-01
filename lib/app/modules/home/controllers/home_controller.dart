import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes_app/app/data/database_service.dart';
import 'package:notes_app/app/data/note_model.dart';
import 'package:notes_app/app/routes/app_pages.dart';

class HomeController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  
  final RxList<Note> notes = <Note>[].obs;
  final RxList<Note> filteredNotes = <Note>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxInt sortOption = 0.obs;
  
  final searchController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    fetchNotes();
  }
  
  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
  
  void fetchNotes() async {
    isLoading.value = true;
    try {
      notes.value = await _databaseService.getAllNotes();
      applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load notes: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  void applyFilters() {
    if (searchQuery.isEmpty) {
      filteredNotes.value = List.from(notes);
    } else {
      filteredNotes.value = notes.where((note) {
        return note.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
               note.content.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    switch (sortOption.value) {
      case 0:
        filteredNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case 1:
        filteredNotes.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case 2:
        filteredNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 3:
        filteredNotes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 4:
        filteredNotes.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }
  }
  
  void onSearchChanged(String query) {
    searchQuery.value = query;
    applyFilters();
  }
  
  void changeSortOption(int option) {
    sortOption.value = option;
    applyFilters();
  }
  
  void createNote() {
    Get.toNamed(Routes.NOTE)?.then((_) => fetchNotes());
  }
  
  void editNote(Note note) {
    Get.toNamed(Routes.NOTE, arguments: note)?.then((_) => fetchNotes());
  }
  
  void deleteNote(Note note) async {
    final deletedNote = note;
    //final deletedIndex = filteredNotes.indexOf(note);
    
    await _databaseService.deleteNote(note.id!);
    fetchNotes();
    
    Get.snackbar(
      'Note Deleted',
      'The note "${deletedNote.title}" has been deleted.',
      mainButton: TextButton(
        onPressed: () async {
          await _databaseService.insertNote(deletedNote);
          fetchNotes();
          Get.snackbar(
            'Note Restored',
            'The note has been restored.',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        child: const Text('UNDO'),
      ),
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
