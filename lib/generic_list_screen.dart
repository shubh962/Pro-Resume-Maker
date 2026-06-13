import 'package:flutter/material.dart';
import 'resume_data.dart';

class GenericListScreen extends StatefulWidget {
  final String title;
  final List<String> dataList;

  const GenericListScreen({super.key, required this.title, required this.dataList});

  @override
  State<GenericListScreen> createState() => _GenericListScreenState();
}

class _GenericListScreenState extends State<GenericListScreen> {
  final TextEditingController controller = TextEditingController();

  void _addItem() {
    if (controller.text.isNotEmpty) {
      setState(() {
        widget.dataList.add(controller.text);
        controller.clear();
        ResumeData().saveData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.deepPurple, iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: TextField(controller: controller, decoration: InputDecoration(hintText: "Enter ${widget.title}"))),
                IconButton(icon: const Icon(Icons.add_circle, color: Colors.deepPurple), onPressed: _addItem),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              children: widget.dataList.map((item) => Chip(
                label: Text(item),
                onDeleted: () {
                  setState(() {
                    widget.dataList.remove(item);
                    ResumeData().saveData();
                  });
                },
              )).toList(),
            )
          ],
        ),
      ),
    );
  }
}