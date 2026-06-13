import 'package:flutter/material.dart';
import 'resume_data.dart';

class ExperienceScreen extends StatefulWidget {
  const ExperienceScreen({super.key});

  @override
  State<ExperienceScreen> createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends State<ExperienceScreen> {
  final _companyCtrl = TextEditingController();
  final _jobCtrl     = TextEditingController();
  final _startCtrl   = TextEditingController();
  final _endCtrl     = TextEditingController();
  final _detailsCtrl = TextEditingController();

  @override
  void dispose() {
    _companyCtrl.dispose();
    _jobCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  // ── Month-Year picker ─────────────────────────────────────────
  Future<void> _pickMonthYear(TextEditingController ctrl) async {
    final now = DateTime.now();
    int selectedYear  = now.year;
    int selectedMonth = now.month;

    // Try to parse existing value
    if (ctrl.text.isNotEmpty) {
      final parts = ctrl.text.split(' ');
      if (parts.length == 2) {
        final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        final mi = months.indexOf(parts[0]);
        if (mi != -1) selectedMonth = mi + 1;
        selectedYear = int.tryParse(parts[1]) ?? now.year;
      }
    }

    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setS) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Text("Select Month & Year"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Year selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => setS(() => selectedYear--),
                    ),
                    Text("$selectedYear",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => setS(() {
                        if (selectedYear < now.year + 5) selectedYear++;
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Month grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, childAspectRatio: 1.8,
                  ),
                  itemCount: 12,
                  itemBuilder: (_, i) {
                    final sel = selectedMonth == i + 1;
                    return GestureDetector(
                      onTap: () => setS(() => selectedMonth = i + 1),
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: sel ? const Color(0xFF4A00E0) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          months[i],
                          style: TextStyle(
                            color: sel ? Colors.white : Colors.black87,
                            fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A00E0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  ctrl.text = "${months[selectedMonth - 1]} $selectedYear";
                  Navigator.pop(ctx);
                },
                child: const Text("Done", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
  }

  // ── Add / Edit dialog ─────────────────────────────────────────
  void _showDialog({int? index}) {
    final isEdit = index != null;
    final formKey = GlobalKey<FormState>();

    if (isEdit) {
      final e = ResumeData().experienceList[index];
      _companyCtrl.text = e['company'] ?? '';
      _jobCtrl.text     = e['job']     ?? '';
      _startCtrl.text   = e['start']   ?? e['startDate'] ?? '';
      _endCtrl.text     = e['end']     ?? e['endDate']   ?? '';
      _detailsCtrl.text = e['details'] ?? e['description'] ?? '';
    } else {
      _companyCtrl.clear();
      _jobCtrl.clear();
      _startCtrl.clear();
      _endCtrl.clear();
      _detailsCtrl.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.6,
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
                  // Handle
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
                    isEdit ? "Edit Experience" : "Add Experience",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  _label("Company Name *"),
                  _field(_companyCtrl, "e.g. Google Inc.", formKey,
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Company name is required" : null),
                  const SizedBox(height: 14),

                  _label("Job Title *"),
                  _field(_jobCtrl, "e.g. Software Engineer", formKey,
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Job title is required" : null),
                  const SizedBox(height: 14),

                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _label("Start Date"),
                      _dateField(_startCtrl, "e.g. Jan 2022", () async {
                        await _pickMonthYear(_startCtrl);
                        setS(() {});
                      }),
                    ])),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _label("End Date"),
                      _dateField(_endCtrl, "Present", () async {
                        await _pickMonthYear(_endCtrl);
                        setS(() {});
                      }),
                    ])),
                  ]),
                  const SizedBox(height: 14),

                  _label("Responsibilities / Achievements"),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text(
                      "Tip: Start each line with an action verb (Led, Built, Increased…)",
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                  TextFormField(
                    controller: _detailsCtrl,
                    maxLines: 6,
                    decoration: _inputDeco("e.g. Led a team of 5 engineers\nReduced load time by 40%"),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A00E0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        setState(() {
                          final entry = {
                            'company': _companyCtrl.text.trim(),
                            'job':     _jobCtrl.text.trim(),
                            'start':   _startCtrl.text.trim(),
                            'end':     _endCtrl.text.trim(),
                            'details': _detailsCtrl.text.trim(),
                          };
                          if (isEdit) {
                            ResumeData().experienceList[index] = entry;
                          } else {
                            ResumeData().experienceList.add(entry);
                          }
                          ResumeData().saveData();
                        });
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        isEdit ? "Update Experience" : "Add Experience",
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
        content: const Text("This experience entry will be removed."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              setState(() {
                ResumeData().experienceList.removeAt(index);
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
    final list = ResumeData().experienceList;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9),
      appBar: AppBar(
        title: const Text("Work Experience", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4A00E0),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4A00E0),
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
                        color: const Color(0xFF4A00E0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.work_outline, color: Color(0xFF4A00E0), size: 22),
                    ),
                    title: Text(e['job'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e['company'] ?? '', style: const TextStyle(fontSize: 13)),
                        if ((e['start'] ?? '').isNotEmpty || (e['end'] ?? '').isNotEmpty)
                          Text(
                            "${e['start'] ?? ''}  –  ${e['end']?.isNotEmpty == true ? e['end'] : 'Present'}",
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Color(0xFF4A00E0), size: 20),
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
      Icon(Icons.work_outline, size: 64, color: Colors.grey.shade300),
      const SizedBox(height: 16),
      const Text("No experience added yet", style: TextStyle(fontSize: 16, color: Colors.grey)),
      const SizedBox(height: 8),
      const Text("Tap + Add to get started", style: TextStyle(fontSize: 13, color: Colors.grey)),
    ]),
  );

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
  );

  Widget _field(TextEditingController c, String hint, GlobalKey<FormState> fk, {String? Function(String?)? validator}) =>
    TextFormField(
      controller: c,
      validator: validator,
      decoration: _inputDeco(hint),
    );

  Widget _dateField(TextEditingController c, String hint, VoidCallback onTap) =>
    TextFormField(
      controller: c,
      readOnly: true,
      onTap: onTap,
      decoration: _inputDeco(hint).copyWith(
        suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
      ),
    );

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.black26),
    filled: true,
    fillColor: const Color(0xFFF8F8F8),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4A00E0), width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
  );
}
