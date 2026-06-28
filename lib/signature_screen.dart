import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import 'resume_data.dart';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key});
  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _imagePath;

  // Draw tab
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2.5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (ResumeData().signature.isNotEmpty) {
      _imagePath = ResumeData().signature;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  // ── Save drawn signature as PNG file ──────────────────────────
  Future<void> _saveDrawnSignature() async {
    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please draw your signature first')),
      );
      return;
    }
    final Uint8List? pngBytes = await _signatureController.toPngBytes(
      height: 300, width: 800,
    );
    if (pngBytes == null) return;

    final dir  = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/signature.png');
    await file.writeAsBytes(pngBytes);

    if (mounted) {
      setState(() => _imagePath = file.path);
      ResumeData().signature = file.path;
      await ResumeData().saveData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signature saved!'),
          backgroundColor: Color(0xFF1565C0),
        ),
      );
    }
  }

  // ── Upload from gallery ────────────────────────────────────────
  Future<void> _pickImage() async {
    final XFile? image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (image != null && mounted) {
      setState(() => _imagePath = image.path);
      ResumeData().signature = image.path;
      await ResumeData().saveData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signature uploaded!'),
          backgroundColor: Color(0xFF1565C0),
        ),
      );
    }
  }

  // ── Remove signature ──────────────────────────────────────────
  Future<void> _remove() async {
    setState(() => _imagePath = null);
    _signatureController.clear();
    ResumeData().signature = '';
    await ResumeData().saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Signature', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1565C0),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_imagePath != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              tooltip: 'Remove signature',
              onPressed: _remove,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.draw_outlined), text: 'Draw'),
            Tab(icon: Icon(Icons.upload_outlined), text: 'Upload'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DrawTab(
            controller: _signatureController,
            onSave: _saveDrawnSignature,
            savedPath: _imagePath,
          ),
          _UploadTab(
            onUpload: _pickImage,
            imagePath: _imagePath,
          ),
        ],
      ),
    );
  }
}

// ── DRAW TAB ──────────────────────────────────────────────────────
class _DrawTab extends StatelessWidget {
  final SignatureController controller;
  final VoidCallback onSave;
  final String? savedPath;
  const _DrawTab({required this.controller, required this.onSave, this.savedPath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Draw your signature below:',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 12),

          // Canvas
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFF1565C0), width: 1.5),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Signature(
                controller: controller,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Sign above using your finger or stylus',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),

          // Action buttons
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.clear(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Clear'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Save Signature'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ]),

          // Preview of saved signature
          if (savedPath != null && savedPath!.isNotEmpty) ...[
            const SizedBox(height: 28),
            const Text('Current signature on resume:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(children: [
                Image.file(File(savedPath!), height: 60),
                const SizedBox(width: 12),
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 6),
                const Text('Added to resume', style: TextStyle(color: Colors.green, fontSize: 13)),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

// ── UPLOAD TAB ────────────────────────────────────────────────────
class _UploadTab extends StatelessWidget {
  final VoidCallback onUpload;
  final String? imagePath;
  const _UploadTab({required this.onUpload, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upload a signature image from your gallery:',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 20),

          // Upload box
          GestureDetector(
            onTap: onUpload,
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: imagePath != null ? Colors.green.shade300 : const Color(0xFF1565C0),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
              ),
              child: imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.file(File(imagePath!), fit: BoxFit.contain),
                    )
                  : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.upload_file_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text('Tap to choose from gallery',
                          style: TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 6),
                      Text('PNG or JPG with white/transparent background',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                    ]),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: Text(imagePath != null ? 'Change Signature Image' : 'Upload Signature Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '💡 Tip: Sign on white paper, photograph it, and use a photo editing app to remove the background for best results.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}