import 'package:flutter/material.dart';
import 'resume_data.dart';
import 'ad_helper.dart';
import 'app_constants.dart';

import 'personal_details.dart';
import 'education_screen.dart';
import 'experience_screen.dart';
import 'skills_screen.dart';
import 'objective_screen.dart';
import 'reference_screen.dart';
import 'project_screen.dart';
import 'languages_screen.dart';
import 'generic_list_screen.dart';
import 'additional_info_screen.dart';
import 'signature_screen.dart';
import 'pdf_preview_screen.dart';
import 'rearrange_screen.dart';
import 'add_more_section_screen.dart';
import 'custom_section_screen.dart';

class EditorDashboard extends StatefulWidget {
  const EditorDashboard({super.key});

  @override
  State<EditorDashboard> createState() => _EditorDashboardState();
}

class _EditorDashboardState extends State<EditorDashboard> {
  final InterstitialAdManager _interstitialAdManager = InterstitialAdManager();

  // Track whether any changes were made
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _interstitialAdManager.load();
  }

  // ── Navigation with change tracking ──────────────────────────
  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    ).then((_) {
      setState(() => _hasChanges = true);
      _interstitialAdManager.tryShow();
      _interstitialAdManager.load();
    });
  }

  void _goToPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/pdf_preview'),
        builder: (_) => const PdfPreviewScreen(),
      ),
    ).then((_) => setState(() {}));
  }

  // ── Back with unsaved-changes confirmation ────────────────────
  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Save Changes?"),
        content: const Text("Your resume has unsaved changes. Would you like to save before leaving?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'discard'),
            child: const Text("Discard", style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppConstants.primaryInt),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              await ResumeData().saveData();
              if (ctx.mounted) Navigator.pop(ctx, 'save');
            },
            child: const Text("Save & Exit", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    return result != null; // any button = allow pop
  }

  // ── BUILD ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final data   = ResumeData();
    final status = data.sectionStatus;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(AppConstants.bgInt),
        appBar: _buildAppBar(),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            // ── PROGRESS CARD ──
            _buildProgressCard(data),
            const SizedBox(height: 20),

            // ── BASICS ──
            _sectionLabel("Basics"),
            _tile(
              icon: Icons.person_outline, color: const Color(0xFF5C6BC0),
              label: "Personal Details",
              subtitle: data.name.isNotEmpty
                  ? "${data.name}${data.jobTitle.isNotEmpty ? '  ·  ${data.jobTitle}' : ''}"
                  : "Name, email, phone, LinkedIn…",
              onTap: () => _navigateTo(const PersonalDetails()),
              done: data.name.isNotEmpty && data.email.isNotEmpty,
            ),
            _tile(
              icon: Icons.lightbulb_outline, color: const Color(0xFF26A69A),
              label: "Objective / Summary",
              subtitle: data.objective.isNotEmpty
                  ? (data.objective.length > 55 ? "${data.objective.substring(0, 55)}…" : data.objective)
                  : "Add a professional summary",
              onTap: () => _navigateTo(ObjectiveScreen()),
              done: data.objective.isNotEmpty,
              visible: status['Objective'] ?? true,
            ),
            const SizedBox(height: 20),

            // ── EXPERIENCE ──
            _sectionLabel("Experience"),
            _tile(
              icon: Icons.work_outline, color: const Color(AppConstants.primaryInt),
              label: "Work Experience",
              subtitle: _count(data.experienceList.length, "entry", "entries"),
              onTap: () => _navigateTo(const ExperienceScreen()),
              done: data.experienceList.isNotEmpty,
              visible: status['Experience'] ?? true,
            ),
            _tile(
              icon: Icons.folder_open_outlined, color: const Color(0xFF7B1FA2),
              label: "Projects",
              subtitle: _count(data.projectList.length, "project", "projects"),
              onTap: () => _navigateTo(ProjectScreen()),
              done: data.projectList.isNotEmpty,
              visible: status['Projects'] ?? true,
            ),
            const SizedBox(height: 20),

            // ── EDUCATION ──
            _sectionLabel("Education"),
            _tile(
              icon: Icons.school_outlined, color: const Color(0xFF1565C0),
              label: "Education",
              subtitle: _count(data.educationList.length, "entry", "entries"),
              onTap: () => _navigateTo(const EducationScreen()),
              done: data.educationList.isNotEmpty,
              visible: status['Education'] ?? true,
            ),
            const SizedBox(height: 20),

            // ── SKILLS & MORE ──
            _sectionLabel("Skills & More"),
            _tile(
              icon: Icons.star_outline, color: const Color(0xFF00695C),
              label: "Skills",
              subtitle: _count(data.skillsList.length, "skill", "skills"),
              onTap: () => _navigateTo(SkillsScreen()),
              done: data.skillsList.isNotEmpty,
              visible: status['Skills'] ?? true,
            ),
            if (status['Languages'] == true)
              _tile(
                icon: Icons.translate_outlined, color: const Color(0xFF0288D1),
                label: "Languages",
                subtitle: _count(data.languagesList.length, "language", "languages"),
                onTap: () => _navigateTo(LanguagesScreen()),
                done: data.languagesList.isNotEmpty,
              ),
            if (status['Interests'] == true)
              _tile(
                icon: Icons.favorite_outline, color: const Color(0xFFD81B60),
                label: "Interests / Hobbies",
                subtitle: _count(data.interestsList.length, "item", "items"),
                onTap: () => _navigateTo(GenericListScreen(
                  title: "Interests",
                  dataList: data.interestsList,
                )),
                done: data.interestsList.isNotEmpty,
              ),
            if (status['Achievements & Awards'] == true)
              _tile(
                icon: Icons.emoji_events_outlined, color: const Color(0xFFF57F17),
                label: "Achievements & Awards",
                subtitle: _count(data.achievementsList.length, "item", "items"),
                onTap: () => _navigateTo(GenericListScreen(
                  title: "Achievements & Awards",
                  dataList: data.achievementsList,
                )),
                done: data.achievementsList.isNotEmpty,
              ),
            if (status['Activities'] == true)
              _tile(
                icon: Icons.groups_outlined, color: const Color(0xFF37474F),
                label: "Activities",
                subtitle: _count(data.activitiesList.length, "item", "items"),
                onTap: () => _navigateTo(GenericListScreen(
                  title: "Activities",
                  dataList: data.activitiesList,
                )),
                done: data.activitiesList.isNotEmpty,
              ),
            if (status['Publication'] == true)
              _tile(
                icon: Icons.menu_book_outlined, color: const Color(0xFF546E7A),
                label: "Publications",
                subtitle: _count(data.publicationList.length, "item", "items"),
                onTap: () => _navigateTo(GenericListScreen(
                  title: "Publications",
                  dataList: data.publicationList,
                )),
                done: data.publicationList.isNotEmpty,
              ),
            if (status['Reference'] == true)
              _tile(
                icon: Icons.contact_mail_outlined, color: const Color(0xFF4E342E),
                label: "References",
                subtitle: _count(data.referenceList.length, "reference", "references"),
                onTap: () => _navigateTo(ReferenceScreen()),
                done: data.referenceList.isNotEmpty,
              ),
            if (status['Additional Information'] == true)
              _tile(
                icon: Icons.info_outline, color: const Color(0xFF00838F),
                label: "Additional Information",
                subtitle: data.additionalInfo.isNotEmpty ? "Filled in" : "Optional details",
                onTap: () => _navigateTo(AdditionalInfoScreen()),
                done: data.additionalInfo.isNotEmpty,
              ),
            if (status['Signature'] == true)
              _tile(
                icon: Icons.draw_outlined, color: const Color(0xFF558B2F),
                label: "Signature",
                subtitle: data.signature.isNotEmpty ? "Signature added" : "Add your signature",
                onTap: () => _navigateTo(SignatureScreen()),
                done: data.signature.isNotEmpty,
              ),

            // ── CUSTOM SECTIONS ──
            ...data.customSections.map((sec) {
              final String title = sec['title'] ?? "Custom Section";
              final List   items = sec['description'] ?? [];
              return _tile(
                icon: Icons.add_circle_outline, color: const Color(0xFF6D4C41),
                label: title,
                subtitle: _count(items.length, "item", "items"),
                onTap: () => _navigateTo(CustomSectionScreen(sectionTitle: title)),
                done: items.isNotEmpty,
              );
            }),

            const SizedBox(height: 20),

            // ── MANAGE ROW ──
            Row(children: [
              Expanded(child: _actionBtn(
                icon: Icons.add_box_outlined, label: "Add Section",
                color: const Color(AppConstants.primaryInt),
                onTap: () => _navigateTo(AddMoreSectionScreen()),
              )),
              const SizedBox(width: 12),
              Expanded(child: _actionBtn(
                icon: Icons.swap_vert_rounded, label: "Reorder",
                color: const Color(0xFF37474F),
                onTap: () => _navigateTo(RearrangeScreen()),
              )),
            ]),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(AppConstants.primaryInt),
          onPressed: _goToPreview,
          icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
          label: const Text("Preview PDF",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // ── APP BAR ───────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() => AppBar(
    elevation: 0,
    backgroundColor: Colors.transparent,
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(AppConstants.primaryInt), Color(AppConstants.secondaryInt)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
    ),
    title: const Text("Resume Editor",
      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    iconTheme: const IconThemeData(color: Colors.white),
    actions: [
      Container(
        margin: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
        child: TextButton.icon(
          onPressed: _goToPreview,
          icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 16),
          label: const Text("Preview",
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ),
    ],
  );

  // ── PROGRESS CARD ─────────────────────────────────────────────
  Widget _buildProgressCard(ResumeData data) {
    final pct = (data.getProgress() * 100).round();
    final Color bar = pct >= 80 ? Colors.green : pct >= 50 ? Colors.orange : Colors.redAccent;
    final String msg = pct < 40
        ? "Add your experience & education to get started."
        : pct < 80
            ? "Looking good! Fill more sections to stand out."
            : "Your resume looks great! Ready to preview.";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(AppConstants.primaryInt), Color(AppConstants.secondaryInt)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(AppConstants.primaryInt).withOpacity(0.25),
            blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                data.name.isNotEmpty ? data.name : "Your Resume",
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text("$pct% Done",
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: data.getProgress(),
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(bar),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 10),
        Text(msg, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ]),
    );
  }

  // ── HELPERS ───────────────────────────────────────────────────
  Widget _sectionLabel(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(t.toUpperCase(),
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
        color: Colors.grey[500], letterSpacing: 1.2)),
  );

  Widget _tile({
    required IconData icon, required Color color,
    required String label, required String subtitle,
    required VoidCallback onTap,
    bool done = false, bool visible = true,
  }) {
    if (!visible) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
              if (done)
                Container(
                  width: 8, height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon, required String label,
    required Color color, required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
      ]),
    ),
  );

  String _count(int n, String s, String p) =>
    n == 0 ? "Tap to add" : "$n ${n == 1 ? s : p} added";
}
