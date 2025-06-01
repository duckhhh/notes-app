import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/app/data/note_model.dart';
import 'package:notes_app/app/modules/home/controllers/home_controller.dart';
import 'package:notes_app/app/theme/theme_service.dart';
import 'package:notes_app/app/utils/responsive_helper.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes', overflow: TextOverflow.ellipsis),
        centerTitle: false,
        actions: [
          _buildSortButton(),
          IconButton(
            icon: Icon(Get.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ThemeService.to.switchTheme(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildNotesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.createNote,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: 'Search notes...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              controller.searchController.clear();
              controller.onSearchChanged('');
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onChanged: controller.onSearchChanged,
      ),
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.sort),
      onSelected: controller.changeSortOption,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Row(
            children: [
              const Icon(Icons.update),
              const SizedBox(width: 8),
              Text(
                'Updated (newest)',
                style: TextStyle(
                  fontWeight: controller.sortOption.value == 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              const Icon(Icons.update),
              const SizedBox(width: 8),
              Text(
                'Updated (oldest)',
                style: TextStyle(
                  fontWeight: controller.sortOption.value == 1 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              const Icon(Icons.calendar_today),
              const SizedBox(width: 8),
              Text(
                'Created (newest)',
                style: TextStyle(
                  fontWeight: controller.sortOption.value == 2 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: Row(
            children: [
              const Icon(Icons.calendar_today),
              const SizedBox(width: 8),
              Text(
                'Created (oldest)',
                style: TextStyle(
                  fontWeight: controller.sortOption.value == 3 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 4,
          child: Row(
            children: [
              const Icon(Icons.sort_by_alpha),
              const SizedBox(width: 8),
              Text(
                'Title (A-Z)',
                style: TextStyle(
                  fontWeight: controller.sortOption.value == 4 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.filteredNotes.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.note_alt_outlined,
                size: 80,
                color: Colors.grey.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                controller.searchQuery.isEmpty
                    ? 'No notes yet. Create one!'
                    : 'No notes found for "${controller.searchQuery.value}"',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
            ],
          ),
        );
      }

      // Create a list of note cards
      final noteCards = controller.filteredNotes.map((note) => _buildNoteCard(note)).toList();
      
      // Use responsive grid based on screen size
      return LayoutBuilder(builder: (context, constraints) {
        if (ResponsiveHelper.isMobile(context)) {
          // Single column list view for mobile
          return ListView.builder(
            itemCount: noteCards.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) => noteCards[index],
          );
        } else {
          // Grid view for tablet and desktop
          final crossAxisCount = ResponsiveHelper.isTablet(context) ? 2 : 3;
          
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: noteCards.length,
            itemBuilder: (context, index) => noteCards[index],
          );
        }
      });
    });
  }

  Widget _buildNoteCard(Note note) {
    final dateFormat = DateFormat('MMM d, yyyy - h:mm:ss a');
    
    return Dismissible(
      key: Key(note.id.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Delete Note'),
            content: Text('Are you sure you want to delete "${note.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('DELETE'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        controller.deleteNote(note);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: InkWell(
          onTap: () => controller.editNote(note),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  note.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.update,
                          size: 14,
                          color: Get.theme.textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Updated: ${dateFormat.format(note.updatedAt)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Get.theme.textTheme.bodySmall?.color,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Get.theme.textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Created: ${dateFormat.format(note.createdAt)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Get.theme.textTheme.bodySmall?.color,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
