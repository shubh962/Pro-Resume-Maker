import 'package:flutter/material.dart';
import 'resume_data.dart';

class ManageSectionScreen extends StatefulWidget {
  const ManageSectionScreen({super.key});

  @override
  State<ManageSectionScreen> createState() => _ManageSectionScreenState();
}

class _ManageSectionScreenState extends State<ManageSectionScreen> {
  List<String> currentOrder = [];
  Map<String, bool> currentStatus = {};

  @override
  void initState() {
    super.initState();
    currentOrder = List.from(ResumeData().sectionOrder);
    currentStatus = Map.from(ResumeData().sectionStatus);
  }

  void _saveChanges() {
    ResumeData().sectionOrder = currentOrder;
    ResumeData().sectionStatus = currentStatus;
    ResumeData().saveData();
    Navigator.pop(context);
  }

  void _showAddSectionDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Custom Section"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Section Name (e.g. Hobbies)",
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
              if (newTitle.isNotEmpty && !currentOrder.contains(newTitle)) {
                setState(() {
                  currentOrder.add(newTitle);
                  currentStatus[newTitle] = true;
                  ResumeData().customSections.add({
                    'title': newTitle,
                    'description': [],
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

  void _deleteSection(String section) {
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
        // Agar ye Purple nahi dikha, matlab purana code chal raha hai
        backgroundColor: Colors.deepPurple, 
        title: const Text("Manage Sections", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: "Save Order",
            onPressed: _saveChanges,
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.deepPurple.shade50,
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.deepPurple, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Drag to reorder. Use the toggle to show/hide sections.",
                    style: TextStyle(fontSize: 12, color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
          ),
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
                    key: ValueKey(section),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.drag_handle, color: Colors.grey),
                      title: Text(section, style: const TextStyle(fontWeight: FontWeight.w500)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!ResumeData().defaultOrder.contains(section))
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deleteSection(section),
                            ),
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
      
      // --- YE BUTTON HAI ADD CUSTOM SECTION KE LIYE ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSectionDialog,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Custom Section", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}