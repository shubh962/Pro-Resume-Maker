import 'package:flutter/material.dart';
import 'resume_data.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final TextEditingController skillController = TextEditingController();

  // --- SUGGESTED SKILLS LIST ---
  final List<String> suggestions = [
    "Python", "Java", "HTML", "CSS", "JavaScript", "SQL", "React", "Flutter",
    "AutoCAD", "Microsoft Excel", "Communication", "Problem Solving", "AWS", "Git"
  ];

  void _addSkill(String skill) {
    String trimmedSkill = skill.trim();
    if (trimmedSkill.isNotEmpty && !ResumeData().skillsList.contains(trimmedSkill)) {
      setState(() {
        ResumeData().skillsList.add(trimmedSkill);
        skillController.clear();
        ResumeData().saveData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Skills", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- INPUT BOX ---
            const Text("Add Your Skills", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: skillController,
                      decoration: const InputDecoration(
                        hintText: "e.g. Python, AutoCAD, Teamwork",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (val) => _addSkill(val),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.deepPurple, size: 30),
                    onPressed: () => _addSkill(skillController.text),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- SUGGESTIONS SECTION ---
            const Text("Suggestions (Tap to Add)", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestions.where((s) => !ResumeData().skillsList.contains(s)).map((s) {
                return ActionChip(
                  label: Text(s),
                  onPressed: () => _addSkill(s),
                  backgroundColor: Colors.deepPurple.withOpacity(0.05),
                  side: BorderSide(color: Colors.deepPurple.withOpacity(0.2)),
                  labelStyle: const TextStyle(color: Colors.deepPurple, fontSize: 12),
                );
              }).toList(),
            ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),

            // --- ADDED SKILLS LIST ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Added Skills", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("${ResumeData().skillsList.length} Skills", style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 15),
            
            ResumeData().skillsList.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Text("No skills added yet.", style: TextStyle(color: Colors.grey[400])),
                    ),
                  )
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ResumeData().skillsList.map((skill) {
                      return Chip(
                        label: Text(skill),
                        backgroundColor: Colors.white,
                        deleteIcon: const Icon(Icons.cancel, size: 18, color: Colors.redAccent),
                        side: const BorderSide(color: Colors.grey),
                        onDeleted: () {
                          setState(() {
                            ResumeData().skillsList.remove(skill);
                            ResumeData().saveData();
                          });
                        },
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}