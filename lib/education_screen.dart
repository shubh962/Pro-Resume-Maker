import 'package:flutter/material.dart';
import 'resume_data.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final _schoolCtrl = TextEditingController();
  final _courseCtrl = TextEditingController();
  final _scoreCtrl  = TextEditingController();
  final _yearCtrl   = TextEditingController();

  @override
  void dispose() {
    _schoolCtrl.dispose();
    _courseCtrl.dispose();
    _scoreCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  // ── Year range picker ─────────────────────────────────────────
  Future<void> _pickYearRange() async {
    final now = DateTime.now().year;
    int startYear = now - 4;
    int endYear   = now;

    // Parse existing value
    if (_yearCtrl.text.isNotEmpty) {
      final parts = _yearCtrl.text.split('-');
      if (parts.length == 2) {
        startYear = int.tryParse(parts[0].trim()) ?? startYear;
        endYear   = int.tryParse(parts[1].trim()) ?? endYear;
      } else if (parts.length == 1) {
        endYear = int.tryParse(parts[0].trim()) ?? endYear;
        startYear = endYear - 4;
      }
    }

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text("Select Year Range"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _yearRow("Start Year", startYear,
                onDec: () => setS(() => startYear--),
                onInc: () => setS(() { if (startYear < endYear) startYear++; }),
              ),
              const SizedBox(height: 12),
              _yearRow("End Year", endYear,
                onDec: () => setS(() { if (endYear > startYear) endYear--; }),
                onInc: () => setS(() { if (endYear < now + 6) endYear++; }),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                _yearCtrl.text = "$startYear – $endYear";
                Navigator.pop(ctx);
              },
              child: const Text("Done", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }),
    );
  }

  Widget _yearRow(String label, int year, {required VoidCallback onDec, required VoidCallback onInc}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Row(children: [
          IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: onDec),
          Text("$year", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: onInc),
        ]),
      ],
    );
  }

  // ── Add / Edit dialog ─────────────────────────────────────────
  void _showDialog({int? index}) {
    final isEdit  = index != null;
    final formKey = GlobalKey<FormState>();

    if (isEdit) {
      final e = ResumeData().educationList[index];
      _schoolCtrl.text = e['school'] ?? e['college'] ?? '';
      _courseCtrl.text = e['course'] ?? '';
      _scoreCtrl.text  = e['score']  ?? '';
      _yearCtrl.text   = e['year']   ?? '';
    } else {
      _schoolCtrl.clear();
      _courseCtrl.clear();
      _scoreCtrl.clear();
      _yearCtrl.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => DraggableScrollableSheet(
          initialChildSize: 0.88,
          minChildSize: 0.5,
          maxChildSize: 0.97,
          builder: (_, scrollCtrl) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Form(
              key: formKey,
              child: ListView(
                controller: scrollCtrl,
                padding: EdgeInsets.fromLTRB(
                  20, 16, 20,
                  MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isEdit ? "Edit Education" : "Add Education",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  _label("School / University *"),
                  _field(_schoolCtrl, "e.g. MIT, Harvard University",
                    validator: (v) => (v == null || v.trim().isEmpty) ? "School name is required" : null),
                  const SizedBox(height: 14),

                  _label("Degree / Course *"),
                  _field(_courseCtrl, "e.g. B.Sc. Computer Science",
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Degree/course is required" : null),
                  const SizedBox(height: 14),

                  _label("Grade / Score (optional)"),
                  _field(_scoreCtrl, "e.g. 3.8 GPA, First Class, 85%"),
                  const SizedBox(height: 14),

                  _label("Year"),
                  TextFormField(
                    controller: _yearCtrl,
                    readOnly: true,
                    onTap: () async {
                      await _pickYearRange();
                      setS(() {});
                    },
                    decoration: _inputDeco("e.g. 2020 – 2024").copyWith(
                      suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        setState(() {
                          final entry = {
                            'school': _schoolCtrl.text.trim(),
                            'course': _courseCtrl.text.trim(),
                            'score':  _scoreCtrl.text.trim(),
                            'year':   _yearCtrl.text.trim(),
                          };
                          if (isEdit) {
                            ResumeData().educationList[index] = entry;
                          } else {
                            ResumeData().educationList.add(entry);
                          }
                          ResumeData().saveData();
                        });
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        isEdit ? "Update Education" : "Add Education",
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _delete(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Delete Entry?"),
        content: const Text("This education entry will be removed."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              setState(() {
                ResumeData().educationList.removeAt(index);
                ResumeData().saveData();
              });
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = ResumeData().educationList;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9),
      appBar: AppBar(
        title: const Text("Education", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1565C0),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1565C0),
        onPressed: () => _showDialog(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: list.isEmpty
          ? _empty()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final e = list[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 3))],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.school_outlined, color: Color(0xFF1565C0), size: 22),
                    ),
                    title: Text(e['school'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((e['course'] ?? '').isNotEmpty)
                          Text(e['course'] ?? '', style: const TextStyle(fontSize: 13)),
                        Row(children: [
                          if ((e['year'] ?? '').isNotEmpty)
                            Text(e['year'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          if ((e['year'] ?? '').isNotEmpty && (e['score'] ?? '').isNotEmpty)
                            const Text("  ·  ", style: TextStyle(fontSize: 11, color: Colors.grey)),
                          if ((e['score'] ?? '').isNotEmpty)
                            Text(e['score'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ]),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Color(0xFF1565C0), size: 20),
                          onPressed: () => _showDialog(index: i),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () => _delete(i),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _empty() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.school_outlined, size: 64, color: Colors.grey.shade300),
      const SizedBox(height: 16),
      const Text("No education added yet", style: TextStyle(fontSize: 16, color: Colors.grey)),
      const SizedBox(height: 8),
      const Text("Tap + Add to get started", style: TextStyle(fontSize: 13, color: Colors.grey)),
    ]),
  );

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
  );

  Widget _field(TextEditingController c, String hint, {String? Function(String?)? validator}) =>
    TextFormField(
      controller: c,
      validator: validator,
      decoration: _inputDeco(hint),
    );

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.black26),
    filled: true,
    fillColor: const Color(0xFFF8F8F8),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
  );
}
