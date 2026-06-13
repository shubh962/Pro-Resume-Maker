import 'package:flutter/material.dart';
import 'resume_data.dart';

class CustomSectionScreen extends StatefulWidget {
  final String sectionTitle;

  const CustomSectionScreen({super.key, required this.sectionTitle});

  @override
  State<CustomSectionScreen> createState() => _CustomSectionScreenState();
}

class _CustomSectionScreenState extends State<CustomSectionScreen> {
  List<String> items = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // ResumeData se is specific section ka data dhundo
    final section = ResumeData().customSections.firstWhere(
          (element) => element['title'] == widget.sectionTitle,
          orElse: () => {'title': widget.sectionTitle, 'description': []},
        );

    // Agar description list hai to load karo, warna empty string ko list banao
    if (section['description'] is List) {
      items = List<String>.from(section['description']);
    } else {
      items = [section['description'].toString()];
    }
    setState(() {});
  }

  void _saveData() {
    // Purana data hatao aur naya update karo
    int index = ResumeData().customSections.indexWhere((element) => element['title'] == widget.sectionTitle);
    
    if (index != -1) {
      ResumeData().customSections[index]['description'] = items;
    } else {
      // Agar galti se delete ho gaya ho to wapas add karo
      ResumeData().customSections.add({
        'title': widget.sectionTitle,
        'description': items,
      });
    }
    ResumeData().saveData();
  }

  void _addItem() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Add to ${widget.sectionTitle}"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Enter detail (e.g. Organized Event...)",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  items.add(controller.text);
                  _saveData();
                });
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  void _deleteItem(int index) {
    setState(() {
      items.removeAt(index);
      _saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sectionTitle, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.post_add, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Text("Add details for ${widget.sectionTitle}", style: const TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.circle, size: 10, color: Colors.deepPurple),
                    title: Text(items[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteItem(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}