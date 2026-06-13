import 'package:flutter/material.dart';
import 'resume_data.dart';

class ObjectiveScreen extends StatefulWidget {
  const ObjectiveScreen({super.key});

  @override
  State<ObjectiveScreen> createState() => _ObjectiveScreenState();
}

class _ObjectiveScreenState extends State<ObjectiveScreen> {
  final TextEditingController objectiveController = TextEditingController();

  // --- PRE-WRITTEN OBJECTIVES LIST ---
  final List<Map<String, String>> preObjectives = [
    {
      "title": "IT / Tech",
      "text": "Versatile B.Tech (Information Technology) graduate with hands-on experience in web development. Proficient in HTML, CSS, Python, and SQL, with strong problem-solving abilities."
    },
    {
      "title": "Mechanical / Engineering",
      "text": "Results-oriented professional with experience in the mechanical field and proficiency in AutoCAD. Seeking to leverage technical skills in a growth-driven organization."
    },
    {
      "title": "BPO / Customer Success",
      "text": "Dedicated professional with experience in customer success and quality assurance. Proven ability to resolve client queries effectively while maintaining high satisfaction scores."
    },
    {
      "title": "Fresher / General",
      "text": "Eager and motivated graduate seeking an entry-level position to contribute to a growth-oriented organization while continuously learning and developing new skills."
    },
    {
      "title": "Management",
      "text": "Highly organized individual with strong communication and teamwork skills. Aiming to contribute to tech and client-focused solutions in a fast-paced environment."
    },
  ];

  @override
  void initState() {
    super.initState();
    objectiveController.text = ResumeData().objective;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Objective", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              ResumeData().objective = objectiveController.text;
              ResumeData().saveData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Objective Saved!")),
              );
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select from Pre-written Objectives:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            
            // --- HORIZONTAL SELECTOR ---
            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: preObjectives.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        objectiveController.text = preObjectives[index]['text']!;
                      });
                    },
                    child: Container(
                      width: 250,
                      margin: const EdgeInsets.only(right: 12, bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            preObjectives[index]['title']!,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            preObjectives[index]['text']!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Or Edit Your Objective:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: objectiveController,
              maxLines: 8,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: "Write your career objective here...",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}