import 'package:flutter/material.dart';
import 'resume_data.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  // Controllers for text fields to support editing
  final TextEditingController titleController = TextEditingController();
  final TextEditingController techStackController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();

  void _showProjectDialog({int? index}) {
    bool isEditing = index != null;

    if (isEditing) {
      // Edit mode: Load existing data into controllers
      final proj = ResumeData().projectList[index!];
      titleController.text = proj["title"] ?? "";
      techStackController.text = proj["techStack"] ?? "";
      detailsController.text = proj["description"] ?? proj["details"] ?? "";
    } else {
      // Add mode: Clear fields
      titleController.clear();
      techStackController.clear();
      detailsController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? "Edit Project" : "Add Project"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Project Title"),
              ),
              TextField(
                controller: techStackController,
                decoration: const InputDecoration(labelText: "Tech Stack (e.g. Flutter, Firebase)"),
              ),
              TextField(
                controller: detailsController,
                decoration: const InputDecoration(labelText: "Project Description"),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            onPressed: () {
              setState(() {
                Map<String, String> projectData = {
                  "title": titleController.text,
                  "techStack": techStackController.text,
                  "description": detailsController.text, // Using 'description' to match PDF logic
                };

                if (isEditing) {
                  ResumeData().projectList[index!] = projectData;
                } else {
                  ResumeData().projectList.add(projectData);
                }
                
                // --- SAVE TO DATABASE ---
                ResumeData().saveData();
              });
              Navigator.pop(context);
            },
            child: Text(isEditing ? "Update" : "Add", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Projects", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => _showProjectDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ResumeData().projectList.isEmpty
          ? const Center(child: Text("No projects added yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ResumeData().projectList.length,
              itemBuilder: (context, index) {
                final proj = ResumeData().projectList[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => _showProjectDialog(index: index), // Edit on tap
                    leading: const Icon(Icons.folder, color: Colors.deepPurple),
                    title: Text(proj["title"] ?? "Untitled", style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      "${proj["techStack"] ?? ""}\n${proj["description"] ?? proj["details"] ?? ""}",
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showProjectDialog(index: index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              ResumeData().projectList.removeAt(index);
                              ResumeData().saveData();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}