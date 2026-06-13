import 'package:flutter/material.dart';
import 'resume_data.dart';

class RearrangeScreen extends StatefulWidget {
  const RearrangeScreen({super.key});

  @override
  State<RearrangeScreen> createState() => _RearrangeScreenState();
}

class _RearrangeScreenState extends State<RearrangeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rearrange Sections", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ReorderableListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final section in ResumeData().sectionOrder)
            Card(
              key: ValueKey(section),
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.drag_handle, color: Colors.grey),
                title: Text(section, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
        ],
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex -= 1;
            final String item = ResumeData().sectionOrder.removeAt(oldIndex);
            ResumeData().sectionOrder.insert(newIndex, item);
            ResumeData().saveData(); // Save new order
          });
        },
      ),
    );
  }
}