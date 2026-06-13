import 'package:flutter/material.dart';
import 'resume_data.dart';

class ReferenceScreen extends StatefulWidget {
  const ReferenceScreen({super.key});

  @override
  State<ReferenceScreen> createState() => _ReferenceScreenState();
}

class _ReferenceScreenState extends State<ReferenceScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  void _showAddReferenceDialog({int? index}) {
    bool isEditing = index != null;

    if (isEditing) {
      final ref = ResumeData().referenceList[index!];
      nameController.text = ref['name'] ?? '';
      jobController.text = ref['job'] ?? '';
      companyController.text = ref['company'] ?? '';
      emailController.text = ref['email'] ?? '';
      phoneController.text = ref['phone'] ?? '';
    } else {
      nameController.clear();
      jobController.clear();
      companyController.clear();
      emailController.clear();
      phoneController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? "Edit Reference" : "Add Reference"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Reference Name")),
              TextField(controller: jobController, decoration: const InputDecoration(labelText: "Job Title")),
              TextField(controller: companyController, decoration: const InputDecoration(labelText: "Company Name")),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Phone")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            onPressed: () {
              setState(() {
                Map<String, String> refData = {
                  "name": nameController.text,
                  "job": jobController.text,
                  "company": companyController.text,
                  "email": emailController.text,
                  "phone": phoneController.text,
                };
                if (isEditing) {
                  ResumeData().referenceList[index!] = refData;
                } else {
                  ResumeData().referenceList.add(refData);
                }
                ResumeData().saveData(); // BUG FIX: was missing before
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
        title: const Text("Reference", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => _showAddReferenceDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ResumeData().referenceList.isEmpty
          ? const Center(child: Text("No references added yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ResumeData().referenceList.length,
              itemBuilder: (context, index) {
                final ref = ResumeData().referenceList[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => _showAddReferenceDialog(index: index),
                    leading: const Icon(Icons.person, color: Colors.deepPurple),
                    title: Text(ref["name"] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${ref["job"]} at ${ref["company"]}\n${ref["email"]}"),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showAddReferenceDialog(index: index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              ResumeData().referenceList.removeAt(index);
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