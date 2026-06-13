import 'package:flutter/material.dart';
import 'resume_data.dart';

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({super.key});

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  final TextEditingController langController = TextEditingController();

  void _addLanguage() {
    if (langController.text.isNotEmpty) {
      setState(() {
        ResumeData().languagesList.add(langController.text);
        langController.clear();
        ResumeData().saveData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Languages", style: TextStyle(color: Colors.white)), backgroundColor: Colors.deepPurple, iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: TextField(controller: langController, decoration: const InputDecoration(hintText: "Enter Language (e.g. English)"))),
                IconButton(icon: const Icon(Icons.add_circle, color: Colors.deepPurple), onPressed: _addLanguage),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              children: ResumeData().languagesList.map((lang) => Chip(
                label: Text(lang),
                onDeleted: () {
                  setState(() {
                    ResumeData().languagesList.remove(lang);
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