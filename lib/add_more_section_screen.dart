import 'package:flutter/material.dart';
import 'resume_data.dart';

class AddMoreSectionScreen extends StatefulWidget {
  const AddMoreSectionScreen({super.key});

  @override
  State<AddMoreSectionScreen> createState() => _AddMoreSectionScreenState();
}

class _AddMoreSectionScreenState extends State<AddMoreSectionScreen> {
  // Local state for reordering and toggling
  List<String> currentOrder = [];
  Map<String, bool> currentStatus = {};

  @override
  void initState() {
    super.initState();
    // Load current data
    currentOrder = List.from(ResumeData().sectionOrder);
    currentStatus = Map.from(ResumeData().sectionStatus);
  }

  void _saveChanges() {
    // Save to singleton and persistent storage
    ResumeData().sectionOrder = currentOrder;
    ResumeData().sectionStatus = currentStatus;
    ResumeData().saveData();
    Navigator.pop(context);
  }

  // --- SHOW DIALOG TO ADD NEW SECTION ---
  void _showAddSectionDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Custom Section"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Section Name (e.g. Hobbies, Volunteering)",
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              String newTitle = controller.text.trim();
              // Check if valid and not duplicate
              if (newTitle.isNotEmpty && !currentOrder.contains(newTitle)) {
                setState(() {
                  // 1. Add to Order
                  currentOrder.add(newTitle);
                  // 2. Enable it
                  currentStatus[newTitle] = true;
                  // 3. Register in ResumeData so PDF knows about it
                  ResumeData().customSections.add({
                    'title': newTitle,
                    'description': [], // Empty list initially
                  });
                });
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // --- DELETE CUSTOM SECTION ---
  void _deleteSection(String section) {
    // Prevent deleting core sections
    if (!ResumeData().defaultOrder.contains(section)) {
      setState(() {
        currentOrder.remove(section);
        currentStatus.remove(section);
        ResumeData().customSections.removeWhere((s) => s['title'] == section);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Sections", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Save Button
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: "Save Order",
            onPressed: _saveChanges,
          )
        ],
      ),
      body: Column(
        children: [
          // Hint Header
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.deepPurple.shade50,
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.deepPurple, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Drag to reorder. Toggle to show/hide. Use + button to add new.",
                    style: TextStyle(fontSize: 12, color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
          ),
          
          // Reorderable List
          Expanded(
            child: ReorderableListView(
              padding: const EdgeInsets.only(bottom: 80), // Space for FAB
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = currentOrder.removeAt(oldIndex);
                  currentOrder.insert(newIndex, item);
                });
              },
              children: [
                for (final section in currentOrder)
                  Card(
                    key: ValueKey(section), // Unique Key for ReorderableList
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.drag_handle, color: Colors.grey),
                      title: Text(section, style: const TextStyle(fontWeight: FontWeight.w500)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Show Delete button ONLY for Custom Sections
                          if (!ResumeData().defaultOrder.contains(section))
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deleteSection(section),
                            ),
                          
                          // Toggle Switch
                          Switch(
                            value: currentStatus[section] ?? false,
                            activeColor: Colors.deepPurple,
                            onChanged: (val) {
                              setState(() {
                                currentStatus[section] = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      
      // --- ADD BUTTON (FAB) ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSectionDialog,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Custom", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}