import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'resume_data.dart';
import 'app_constants.dart';

class PersonalDetails extends StatefulWidget {
  const PersonalDetails({super.key});

  @override
  State<PersonalDetails> createState() => _PersonalDetailsState();
}

class _PersonalDetailsState extends State<PersonalDetails> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name     = TextEditingController(text: ResumeData().name);
  late final TextEditingController _job      = TextEditingController(text: ResumeData().jobTitle);
  late final TextEditingController _email    = TextEditingController(text: ResumeData().email);
  late final TextEditingController _phone    = TextEditingController(text: ResumeData().phone);
  late final TextEditingController _address  = TextEditingController(text: ResumeData().address);
  late final TextEditingController _linkedin = TextEditingController(text: ResumeData().linkedin);
  late final TextEditingController _website  = TextEditingController(text: ResumeData().website);

  String? _imagePath = ResumeData().profileImage.isNotEmpty ? ResumeData().profileImage : null;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _job, _email, _phone, _address, _linkedin, _website]) c.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final p = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (p != null) setState(() => _imagePath = p.path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final d      = ResumeData();
    d.name       = _name.text.trim();
    d.jobTitle   = _job.text.trim();
    d.email      = _email.text.trim();
    d.phone      = _phone.text.trim();
    d.address    = _address.text.trim();
    d.linkedin   = _linkedin.text.trim();
    d.website    = _website.text.trim();
    d.profileImage = _imagePath ?? "";
    await d.saveData();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.bgInt),
      appBar: AppBar(
        title: const Text("Personal Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(AppConstants.primaryInt),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          _saving
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(child: SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))))
              : TextButton(
                  onPressed: _save,
                  child: const Text("Save",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── PHOTO ──
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: const Color(0xFFEDE7F6),
                    backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
                    child: _imagePath == null
                        ? const Icon(Icons.person, size: 52, color: Colors.deepPurple)
                        : null,
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(AppConstants.primaryInt), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 6),
            const Center(child: Text("Tap to change photo",
              style: TextStyle(color: Colors.grey, fontSize: 12))),
            const SizedBox(height: 18),

            // ATS note
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 16),
                SizedBox(width: 8),
                Expanded(child: Text(
                  "ATS tip: Profile photos are omitted from ATS-safe templates. LinkedIn & website are included in all templates.",
                  style: TextStyle(fontSize: 11, color: Colors.blueGrey))),
              ]),
            ),

            _label("Full Name *"),
            _field(_name, "e.g. Jane Smith",
              validator: (v) => (v == null || v.trim().isEmpty) ? "Name is required" : null),
            const SizedBox(height: 14),

            _label("Job Title / Position"),
            _field(_job, "e.g. Senior Software Engineer"),
            const SizedBox(height: 14),

            _label("Email Address *"),
            _field(_email, "e.g. jane@example.com",
              type: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return "Email is required";
                if (!v.contains('@') || !v.contains('.')) return "Enter a valid email";
                return null;
              }),
            const SizedBox(height: 14),

            _label("Phone Number"),
            _field(_phone, "e.g. +1 555 000 1234", type: TextInputType.phone),
            const SizedBox(height: 14),

            _label("Location / Address"),
            _field(_address, "e.g. New York, NY, USA"),
            const SizedBox(height: 14),

            _label("LinkedIn Profile"),
            _field(_linkedin, "e.g. linkedin.com/in/janesmith", type: TextInputType.url),
            const SizedBox(height: 14),

            _label("Website / Portfolio"),
            _field(_website, "e.g. janesmith.dev", type: TextInputType.url),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppConstants.primaryInt),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _saving ? null : _save,
                child: const Text("Save Details",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
  );

  Widget _field(TextEditingController c, String hint, {
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: c,
    keyboardType: type,
    validator: validator,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black26),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(AppConstants.primaryInt), width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent)),
    ),
  );
}
