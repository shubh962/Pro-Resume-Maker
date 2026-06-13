import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import 'editor_dashboard.dart';
import 'pdf_preview_screen.dart';
import 'resume_data.dart';
import 'ad_helper.dart';
import 'profile_screen.dart';
import 'app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  final BannerAdManager _bannerAdManager = BannerAdManager();

  @override
  void initState() {
    super.initState();
    _bannerAdManager.load(() => setState(() {}));
  }

  @override
  void dispose() {
    _bannerAdManager.dispose();
    super.dispose();
  }

  // ── NAVIGATION ────────────────────────────────────────────────
  void _createNew() {
    ResumeData().createNewResume();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditorDashboard()),
    ).then((_) => setState(() {}));
  }

  void _editResume(int index) {
    ResumeData().loadResume(index);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditorDashboard()),
    ).then((_) => setState(() {}));
  }

  void _previewResume(int index) {
    ResumeData().loadResume(index);
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/pdf_preview'),
        builder: (_) => const PdfPreviewScreen(),
      ),
    ).then((_) => setState(() {}));
  }

  void _deleteResume(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
          SizedBox(width: 8),
          Text("Delete Resume?"),
        ]),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              await ResumeData().deleteResume(index);
              setState(() {});
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _duplicateResume(int index) async {
    ResumeData().loadResume(index);
    ResumeData().currentResumeId = "copy_${DateTime.now().millisecondsSinceEpoch}";
    await ResumeData().saveData();
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Resume duplicated successfully!")),
      );
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.bgInt),
      body: _currentTab == 0 ? _buildResumesTab() : const ProfileScreen(),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── BOTTOM NAV ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, -3))],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentTab,
              onTap: (i) => setState(() => _currentTab = i),
              backgroundColor: Colors.white,
              selectedItemColor: const Color(AppConstants.primaryInt),
              unselectedItemColor: Colors.grey,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.description_outlined),
                  activeIcon: Icon(Icons.description),
                  label: "Resumes",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: "Profile",
                ),
              ],
            ),
          ),
          // ── BANNER AD ──
          if (_bannerAdManager.isLoaded && _bannerAdManager.ad != null)
            SizedBox(
              width: _bannerAdManager.ad!.size.width.toDouble(),
              height: _bannerAdManager.ad!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAdManager.ad!),
            ),
        ],
      ),
      floatingActionButton: _currentTab == 0
          ? FloatingActionButton.extended(
              backgroundColor: const Color(AppConstants.primaryInt),
              onPressed: _createNew,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Create New",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  // ── RESUMES TAB ───────────────────────────────────────────────
  Widget _buildResumesTab() {
    final resumes = ResumeData().savedResumes;
    return Column(
      children: [
        _buildHeader(resumes.length),
        Expanded(
          child: resumes.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  itemCount: resumes.length,
                  itemBuilder: (_, i) => _buildResumeCard(resumes[i], i),
                ),
        ),
      ],
    );
  }

  // ── HEADER ────────────────────────────────────────────────────
  Widget _buildHeader(int count) {
    return Container(
      padding: const EdgeInsets.only(top: 56, left: 20, right: 20, bottom: 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(AppConstants.primaryInt), Color(AppConstants.secondaryInt)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "My Resumes",
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                count == 0
                    ? "Create your first resume"
                    : "$count resume${count == 1 ? '' : 's'} saved",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.description_outlined, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

  // ── EMPTY STATE ───────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.12), blurRadius: 24)],
            ),
            child: const Icon(Icons.note_add_outlined, size: 64, color: Color(0xFFCE93D8)),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Resumes Yet",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tap 'Create New' to build your\nfirst professional resume in minutes.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppConstants.primaryInt),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _createNew,
            icon: const Icon(Icons.add),
            label: const Text("Create Resume", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 40),
          // Legal footer in empty state
          _buildLegalRow(),
        ],
      ),
    );
  }

  // ── RESUME CARD ───────────────────────────────────────────────
  Widget _buildResumeCard(Map<String, dynamic> resume, int index) {
    String name = (resume['name'] ?? '').toString().trim();
    if (name.isEmpty) name = "Untitled Resume";
    final String job  = (resume['jobTitle'] ?? '').toString().trim().isNotEmpty
        ? resume['jobTitle']
        : "No job title";
    final String date = resume['lastEdited']?.toString().split('T')[0] ?? '–';
    final double progress = _calcProgress(resume);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.09), blurRadius: 16, offset: const Offset(0, 5))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _editResume(index),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Gradient avatar
                    Container(
                      height: 56, width: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7B2FF7), Color(AppConstants.primaryInt)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(job, style: const TextStyle(fontSize: 13, color: Colors.grey),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text("Edited: $date", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                    // Three-dot menu
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (v) {
                        if (v == 'edit')      _editResume(index);
                        if (v == 'preview')   _previewResume(index);
                        if (v == 'duplicate') _duplicateResume(index);
                        if (v == 'delete')    _deleteResume(index);
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit',      child: _MenuItem(icon: Icons.edit_outlined,          label: "Edit")),
                        PopupMenuItem(value: 'preview',   child: _MenuItem(icon: Icons.picture_as_pdf_outlined, label: "Preview PDF")),
                        PopupMenuItem(value: 'duplicate', child: _MenuItem(icon: Icons.copy_outlined,           label: "Duplicate")),
                        PopupMenuDivider(),
                        PopupMenuItem(value: 'delete',    child: _MenuItem(icon: Icons.delete_outline, label: "Delete", color: Colors.redAccent)),
                      ],
                    ),
                  ],
                ),
                // Progress bar
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 0.8 ? Colors.green : progress >= 0.5 ? Colors.orange : Colors.redAccent,
                          ),
                          minHeight: 5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${(progress * 100).round()}% complete",
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _calcProgress(Map<String, dynamic> r) {
    int filled = 0;
    if ((r['name']       ?? '').toString().isNotEmpty) filled++;
    if ((r['email']      ?? '').toString().isNotEmpty) filled++;
    if ((r['experience'] ?? '[]') != '[]')             filled++;
    if ((r['education']  ?? '[]') != '[]')             filled++;
    if ((r['skills']     ?? '[]') != '[]')             filled++;
    return filled / 5;
  }

  // ── LEGAL FOOTER ROW ──────────────────────────────────────────
  Widget _buildLegalRow() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        _legalLink("Privacy Policy", AppConstants.privacyPolicyUrl),
        const Text("  ·  ", style: TextStyle(color: Colors.grey, fontSize: 11)),
        _legalLink("Terms", AppConstants.termsOfServiceUrl),
        const Text("  ·  ", style: TextStyle(color: Colors.grey, fontSize: 11)),
        _legalLink("Contact", AppConstants.contactUsUrl),
      ],
    );
  }

  Widget _legalLink(String label, String url) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(AppConstants.primaryInt),
          fontSize: 11,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

// ── POPUP MENU ITEM ───────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _MenuItem({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.black87;
    return Row(children: [
      Icon(icon, color: c, size: 18),
      const SizedBox(width: 10),
      Text(label, style: TextStyle(color: c, fontSize: 14)),
    ]);
  }
}
