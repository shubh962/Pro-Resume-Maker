import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ad_helper.dart';
import 'resume_data.dart';
import 'app_constants.dart';

class PdfPreviewScreen extends StatefulWidget {
  const PdfPreviewScreen({super.key});

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  int _selectedTemplate = 0;
  final RewardedAdManager _rewardedAdManager = RewardedAdManager();

  final List<Map<String, dynamic>> _templates = [
    {"name": "Classic Pro",    "desc": "Clean & ATS-friendly",       "icon": Icons.article_outlined,           "color": const Color(0xFF37474F)},
    {"name": "Modern Blue",    "desc": "Bold header, two-tone",       "icon": Icons.dashboard_outlined,         "color": const Color(0xFF1565C0)},
    {"name": "Sidebar Dark",   "desc": "Two-column, dark panel",      "icon": Icons.view_sidebar_outlined,      "color": const Color(0xFF1A1A2E)},
    {"name": "Executive",      "desc": "Black & gold accent",         "icon": Icons.workspace_premium_outlined, "color": const Color(0xFFB8860B)},
    {"name": "Emerald Split",  "desc": "Green accent, split layout",  "icon": Icons.eco_outlined,               "color": const Color(0xFF00695C)},
    {"name": "Slate Column",   "desc": "Two-col, slate grey sidebar", "icon": Icons.view_column_outlined,       "color": const Color(0xFF455A64)},
    {"name": "Crimson Edge",   "desc": "Left accent bar, bold name",  "icon": Icons.format_paint_outlined,      "color": const Color(0xFFC62828)},
    {"name": "Navy Timeline",  "desc": "Timeline dots, navy accent",  "icon": Icons.timeline,                   "color": const Color(0xFF0D2137)},
    {"name": "Clean ATS Pro",  "desc": "One-page, plain & ATS-safe",  "icon": Icons.document_scanner_outlined,  "color": const Color(0xFF212121)},
  ];

  @override
  void initState() {
    super.initState();
    _rewardedAdManager.load();
  }

  // ── PDF FILENAME (uses user's name) ───────────────────────────
  String get _pdfFileName {
    final name = _clean(ResumeData().name);
    final base = name.isNotEmpty
        ? "${name.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}_resume"
        : "resume";
    return "${base}_${_templates[_selectedTemplate]['name'].toString().toLowerCase().replaceAll(' ', '_')}.pdf";
  }

  // ── REWARDED DIALOG ───────────────────────────────────────────
  void _showRewardedDialog({
    required BuildContext context,
    required String actionLabel,
    required VoidCallback onRewarded,
  }) {
    if (!AdHelper.isMobile) { onRewarded(); return; }

    IconData icon = Icons.download_rounded;
    if (actionLabel == "Print") icon = Icons.print_rounded;
    if (actionLabel == "Share") icon = Icons.share_rounded;

    if (_rewardedAdManager.isLoaded) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: const Color(AppConstants.primaryInt).withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, 10))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(AppConstants.primaryInt), Color(AppConstants.secondaryInt)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                  ),
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                      child: Icon(icon, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 12),
                    Text("$actionLabel Resume",
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(AppConstants.primaryInt).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(AppConstants.primaryInt).withValues(alpha: 0.2)),
                      ),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.star_rounded, color: Color(AppConstants.primaryInt), size: 16),
                        SizedBox(width: 4),
                        Text("100% Free — Watch a short ad",
                          style: TextStyle(color: Color(AppConstants.primaryInt), fontSize: 12, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "Your resume is ready! Watch a quick ad to unlock your download.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, fontSize: 13.5, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(AppConstants.primaryInt),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _rewardedAdManager.show(onRewarded: onRewarded, onNotLoaded: onRewarded);
                        },
                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.play_circle_filled_rounded, size: 22),
                          SizedBox(width: 8),
                          Text("Watch Ad & Continue", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Maybe Later", style: TextStyle(color: Colors.black38, fontSize: 13)),
                    ),
                    const SizedBox(height: 4),
                  ]),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      onRewarded();
      _rewardedAdManager.load();
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.bgInt),
      appBar: AppBar(
        title: const Text("Choose Template", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(AppConstants.darkInt),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.verified_outlined, color: Colors.greenAccent),
            tooltip: "All templates are ATS-optimized",
            onPressed: () => _showAtsInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTemplateSelector(),
          // ATS badge
          Container(
            color: const Color(AppConstants.darkInt),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            child: Row(children: [
              const Icon(Icons.verified, color: Colors.greenAccent, size: 14),
              const SizedBox(width: 6),
              Text(
                "ATS-Optimized  •  Plain text  •  Recruiter-ready",
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
              ),
            ]),
          ),
          // PDF Preview
          Expanded(
            child: PdfPreview(
              key: ValueKey(_selectedTemplate),
              build: (format) => _generateTemplate(format),
              canDebug: false,
              canChangePageFormat: false,
              pdfFileName: _pdfFileName,
              allowPrinting: false,
              actions: [
                PdfPreviewAction(
                  icon: const Icon(Icons.print_rounded, color: Colors.white),
                  onPressed: (ctx, build, fmt) => _showRewardedDialog(
                    context: ctx, actionLabel: "Print",
                    onRewarded: () async { final b = await build(fmt); await Printing.layoutPdf(onLayout: (_) async => b); },
                  ),
                ),
                PdfPreviewAction(
                  icon: const Icon(Icons.share_rounded, color: Colors.white),
                  onPressed: (ctx, build, fmt) => _showRewardedDialog(
                    context: ctx, actionLabel: "Share",
                    onRewarded: () async { final b = await build(fmt); await Printing.sharePdf(bytes: b, filename: _pdfFileName); },
                  ),
                ),
                PdfPreviewAction(
                  icon: const Icon(Icons.download_rounded, color: Colors.white),
                  onPressed: (ctx, build, fmt) => _showRewardedDialog(
                    context: ctx, actionLabel: "Download",
                    onRewarded: () async { final b = await build(fmt); await Printing.sharePdf(bytes: b, filename: _pdfFileName); },
                  ),
                ),
              ],
            ),
          ),
          _buildLegalFooter(),
        ],
      ),
    );
  }

  Widget _buildTemplateSelector() {
    return Container(
      height: 88,
      color: const Color(0xFF16213E),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: _templates.length,
        itemBuilder: (_, i) {
          final t = _templates[i];
          final bool sel = _selectedTemplate == i;
          final Color c = t['color'] as Color;
          return GestureDetector(
            onTap: () => setState(() => _selectedTemplate = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? Colors.white : Colors.white10,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sel ? c : Colors.white24, width: sel ? 2 : 1),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(t['icon'] as IconData, size: 16, color: sel ? c : Colors.white70),
                const SizedBox(width: 6),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t['name'] as String,
                      style: TextStyle(color: sel ? const Color(AppConstants.darkInt) : Colors.white,
                        fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(t['desc'] as String,
                      style: TextStyle(color: sel ? Colors.black45 : Colors.white38, fontSize: 9)),
                  ],
                ),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegalFooter() {
    return Container(
      color: const Color(AppConstants.darkInt),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          _legalLink("Privacy Policy",  AppConstants.privacyPolicyUrl),
          const Text("  ·  ", style: TextStyle(color: Colors.white38, fontSize: 11)),
          _legalLink("Terms of Service", AppConstants.termsOfServiceUrl),
          const Text("  ·  ", style: TextStyle(color: Colors.white38, fontSize: 11)),
          _legalLink("Contact Us",      AppConstants.contactUsUrl),
        ],
      ),
    );
  }

  Widget _legalLink(String label, String url) => GestureDetector(
    onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
    child: Text(label, style: const TextStyle(
      color: Colors.white54, fontSize: 11,
      decoration: TextDecoration.underline, decorationColor: Colors.white38,
    )),
  );

  void _showAtsInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.verified, color: Colors.green),
          SizedBox(width: 8),
          Text("ATS-Optimized Templates"),
        ]),
        content: const Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _AtsPoint(text: "Clean, single-font PDF — Helvetica"),
          _AtsPoint(text: "No images or charts in content area"),
          _AtsPoint(text: "Standard section headings (EXPERIENCE, EDUCATION…)"),
          _AtsPoint(text: "Skills as plain bullets — not pills or tables"),
          _AtsPoint(text: "Left-aligned body text for highest parse accuracy"),
          _AtsPoint(text: "Contact details in main page flow (not PDF headers)"),
          _AtsPoint(text: "LinkedIn & website included in contact row"),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx),
          child: const Text("Got it", style: TextStyle(color: Color(AppConstants.primaryInt))))],
      ),
    );
  }

  // ================================================================
  // HELPERS
  // ================================================================
  String _clean(String? t) {
    if (t == null || t.trim().isEmpty) return "";
    return t
        .replaceAll(RegExp(r'[☑✔☐^]'), '')
        .replaceAll('\u2013', '-')   // en dash –
        .replaceAll('\u2014', '-')   // em dash —
        .replaceAll('\u2012', '-')   // figure dash
        .replaceAll('\u2015', '-')   // horizontal bar
        .replaceAll('\u2010', '-')   // hyphen
        .replaceAll('\u2011', '-')   // non-breaking hyphen
        .replaceAll('\u00b7', '')    // middle dot
        .replaceAll(RegExp(r'[\u{1F300}-\u{1FABF}]', unicode: true), '')  // emoji
        .replaceAll(RegExp(r'[\u{2600}-\u{27BF}]', unicode: true), '')   // symbols/emoji
        .trim();
  }

  /// Builds the contact line including LinkedIn and website if present
  List<pw.Widget> _contactItems(ResumeData d, pw.Font r, {PdfColor color = PdfColors.grey700, double fs = 9}) {
    final items = <String>[];
    if (_clean(d.email).isNotEmpty)    items.add(_clean(d.email));
    if (_clean(d.phone).isNotEmpty)    items.add(_clean(d.phone));
    if (_clean(d.address).isNotEmpty)  items.add(_clean(d.address));
    if (_clean(d.linkedin).isNotEmpty) items.add(_clean(d.linkedin));
    if (_clean(d.website).isNotEmpty)  items.add(_clean(d.website));

    final List<pw.Widget> row = [];
    for (int i = 0; i < items.length; i++) {
      row.add(pw.Text(items[i], style: pw.TextStyle(font: r, fontSize: fs, color: color)));
      if (i < items.length - 1) {
        row.add(pw.Text("  |  ", style: pw.TextStyle(font: r, fontSize: fs, color: PdfColors.grey400)));
      }
    }
    return row;
  }

  // ── TEMPLATE ROUTER ──────────────────────────────────────────
  Future<Uint8List> _generateTemplate(PdfPageFormat format) async {
    final pdf = pw.Document();
    final d   = ResumeData();
    final r   = pw.Font.helvetica();
    final b   = pw.Font.helveticaBold();
    final i   = pw.Font.helveticaOblique();
    switch (_selectedTemplate) {
      case 0: return _buildClassicPro(pdf, d, r, b, i);
      case 1: return _buildModernBlue(pdf, d, r, b, i);
      case 2: return _buildSidebarDark(pdf, d, r, b, i);
      case 3: return _buildExecutive(pdf, d, r, b, i);
      case 4: return _buildEmeraldSplit(pdf, d, r, b, i);
      case 5: return _buildSlateColumn(pdf, d, r, b, i);
      case 6: return _buildCrimsonEdge(pdf, d, r, b, i);
      case 7: return _buildNavyTimeline(pdf, d, r, b, i);
      case 8: return _buildCleanAtsPro(pdf, d, r, b, i);
      default: return _buildClassicPro(pdf, d, r, b, i);
    }
  }

  // ================================================================
  // SHARED SECTION BUILDER
  // ================================================================
  List<pw.Widget> _buildAllSections(ResumeData d, pw.Font r, pw.Font b, pw.Font i, {
    PdfColor accentColor  = PdfColors.blueGrey900,
    PdfColor dividerColor = PdfColors.blueGrey200,
    double fontSize = 10, double titleFontSize = 11,
  }) {
    final widgets = <pw.Widget>[];
    for (final s in d.sectionOrder) {
      if (d.sectionStatus[s] == false) continue;
      final w = _buildSection(s, d, r, b, i,
        accentColor: accentColor, dividerColor: dividerColor,
        fontSize: fontSize, titleFontSize: titleFontSize);
      if (w != null) widgets.add(w);
    }
    return widgets;
  }

  pw.Widget? _buildSection(String section, ResumeData d, pw.Font r, pw.Font b, pw.Font i, {
    PdfColor accentColor  = PdfColors.blueGrey900,
    PdfColor dividerColor = PdfColors.blueGrey200,
    double fontSize = 10, double titleFontSize = 11,
  }) {
    if (section == 'Objective' && _clean(d.objective).isNotEmpty) {
      return _sBlock("SUMMARY", accentColor, dividerColor, titleFontSize, b,
        pw.Text(_clean(d.objective), style: pw.TextStyle(font: r, fontSize: fontSize), textAlign: pw.TextAlign.justify));
    }
    if (section == 'Experience' && d.experienceList.isNotEmpty) {
      return _sBlock("EXPERIENCE", accentColor, dividerColor, titleFontSize, b,
        pw.Column(children: d.experienceList.map((e) {
          final start   = _clean(e['start'] ?? e['startDate']);
          final rawEnd  = _clean(e['end']   ?? e['endDate'] ?? '');
          final end     = rawEnd.isEmpty ? 'Present' : rawEnd;
          final details = _clean(e['details'] ?? e['description']);
          final company = _clean(e['company']);
          final job     = _clean(e['job']);
          // Build date string: only show if start or end exists
          final dateStr = (start.isEmpty && end == 'Present') ? '' :
                          start.isEmpty ? end :
                          end.isEmpty   ? start : '$start - $end';
          return pw.Padding(padding: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Expanded(child: pw.Text(company, style: pw.TextStyle(font: b, fontSize: fontSize))),
                if (dateStr.isNotEmpty)
                  pw.Text(dateStr,
                    style: pw.TextStyle(font: r, fontSize: fontSize - 1, color: PdfColors.grey600)),
              ]),
              if (job.isNotEmpty)
                pw.Text(job, style: pw.TextStyle(font: i, fontSize: fontSize - 1, color: PdfColors.grey700)),
              if (details.isNotEmpty) ...[pw.SizedBox(height: 4), _bullets(details, r, fontSize: fontSize - 1)],
            ]));
        }).toList()));
    }
    if (section == 'Education' && d.educationList.isNotEmpty) {
      return _sBlock("EDUCATION", accentColor, dividerColor, titleFontSize, b,
        pw.Column(children: d.educationList.map((e) {
          final school = _clean(e['school'] ?? e['college']);
          final course = _clean(e['course']);
          final year   = _clean(e['year']);
          final score  = _clean(e['score']);
          return pw.Padding(padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Expanded(child: pw.Text(school, style: pw.TextStyle(font: b, fontSize: fontSize))),
                if (year.isNotEmpty) pw.Text(year, style: pw.TextStyle(font: r, fontSize: fontSize - 1, color: PdfColors.grey600)),
              ]),
              if (course.isNotEmpty) pw.Text(course, style: pw.TextStyle(font: r, fontSize: fontSize - 1)),
              if (score.isNotEmpty)  pw.Text("Score: $score", style: pw.TextStyle(font: r, fontSize: fontSize - 1, color: PdfColors.grey600)),
            ]));
        }).toList()));
    }
    if (section == 'Skills' && d.skillsList.isNotEmpty) {
      final cleaned = d.skillsList.map((s) => _clean(s)).where((s) => s.isNotEmpty).toList();
      if (cleaned.isEmpty) return null;
      return _sBlock("SKILLS", accentColor, dividerColor, titleFontSize, b,
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: cleaned.map((s) => _bulletRow(s, r, fontSize: fontSize - 0.5)).toList()));
    }
    if (section == 'Projects' && d.projectList.isNotEmpty) {
      return _sBlock("PROJECTS", accentColor, dividerColor, titleFontSize, b,
        pw.Column(children: d.projectList.map((p) {
          final title = _clean(p['title']);
          final tech  = _clean(p['techStack']);
          final desc  = _clean(p['description'] ?? p['details']);
          return pw.Padding(padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Row(children: [
                if (title.isNotEmpty) pw.Text(title, style: pw.TextStyle(font: b, fontSize: fontSize)),
                if (tech.isNotEmpty) ...[
                  pw.Text("  |  ", style: pw.TextStyle(font: r, fontSize: fontSize - 1, color: PdfColors.grey)),
                  pw.Text(tech, style: pw.TextStyle(font: i, fontSize: fontSize - 1, color: PdfColors.grey700)),
                ],
              ]),
              if (desc.isNotEmpty) ...[pw.SizedBox(height: 3), _bullets(desc, r, fontSize: fontSize - 1)],
            ]));
        }).toList()));
    }
    if (section == 'Languages' && d.languagesList.isNotEmpty) {
      final c = d.languagesList.map((s) => _clean(s)).where((s) => s.isNotEmpty).toList();
      if (c.isEmpty) return null;
      return _sBlock("LANGUAGES", accentColor, dividerColor, titleFontSize, b,
        pw.Text(c.join("  |  "), style: pw.TextStyle(font: r, fontSize: fontSize)));
    }
    if (section == 'Interests' && d.interestsList.isNotEmpty) {
      final c = d.interestsList.map((s) => _clean(s)).where((s) => s.isNotEmpty).toList();
      if (c.isEmpty) return null;
      return _sBlock("INTERESTS", accentColor, dividerColor, titleFontSize, b,
        pw.Text(c.join("  |  "), style: pw.TextStyle(font: r, fontSize: fontSize)));
    }
    if (section == 'Achievements & Awards' && d.achievementsList.isNotEmpty) {
      final c = d.achievementsList.map((s) => _clean(s)).where((s) => s.isNotEmpty).toList();
      if (c.isEmpty) return null;
      return _sBlock("ACHIEVEMENTS & AWARDS", accentColor, dividerColor, titleFontSize, b,
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: c.map((item) => _bulletRow(item, r, fontSize: fontSize)).toList()));
    }
    if (section == 'Activities' && d.activitiesList.isNotEmpty) {
      final c = d.activitiesList.map((s) => _clean(s)).where((s) => s.isNotEmpty).toList();
      if (c.isEmpty) return null;
      return _sBlock("ACTIVITIES", accentColor, dividerColor, titleFontSize, b,
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: c.map((item) => _bulletRow(item, r, fontSize: fontSize)).toList()));
    }
    if (section == 'Publication' && d.publicationList.isNotEmpty) {
      final c = d.publicationList.map((s) => _clean(s)).where((s) => s.isNotEmpty).toList();
      if (c.isEmpty) return null;
      return _sBlock("PUBLICATIONS", accentColor, dividerColor, titleFontSize, b,
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: c.map((item) => _bulletRow(item, r, fontSize: fontSize)).toList()));
    }
    if (section == 'Reference' && d.referenceList.isNotEmpty) {
      return _sBlock("REFERENCES", accentColor, dividerColor, titleFontSize, b,
        pw.Column(children: d.referenceList.map((ref) {
          final name    = _clean(ref['name']);
          final job     = _clean(ref['job']);
          final company = _clean(ref['company']);
          final email   = _clean(ref['email']);
          final phone   = _clean(ref['phone']);
          return pw.Padding(padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              if (name.isNotEmpty) pw.Text(name, style: pw.TextStyle(font: b, fontSize: fontSize)),
              if (job.isNotEmpty || company.isNotEmpty)
                pw.Text("${job.isNotEmpty ? job : ''}${company.isNotEmpty ? ' at $company' : ''}",
                  style: pw.TextStyle(font: r, fontSize: fontSize - 1)),
              if (email.isNotEmpty) pw.Text(email, style: pw.TextStyle(font: r, fontSize: fontSize - 1, color: PdfColors.grey600)),
              if (phone.isNotEmpty) pw.Text(phone, style: pw.TextStyle(font: r, fontSize: fontSize - 1, color: PdfColors.grey600)),
            ]));
        }).toList()));
    }
    if (section == 'Additional Information' && _clean(d.additionalInfo).isNotEmpty) {
      return _sBlock("ADDITIONAL INFORMATION", accentColor, dividerColor, titleFontSize, b,
        pw.Text(_clean(d.additionalInfo), style: pw.TextStyle(font: r, fontSize: fontSize)));
    }
    for (final cs in d.customSections) {
      if (cs['title'] == section) {
        final items   = List<String>.from(cs['description'] ?? []);
        final cleaned = items.map((s) => _clean(s)).where((s) => s.isNotEmpty).toList();
        if (cleaned.isEmpty) return null;
        return _sBlock(section.toUpperCase(), accentColor, dividerColor, titleFontSize, b,
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: cleaned.map((item) => _bulletRow(item, r, fontSize: fontSize)).toList()));
      }
    }
    return null;
  }

  // ================================================================
  // TEMPLATES
  // ================================================================

  // 0 — CLASSIC PRO
  Future<Uint8List> _buildClassicPro(pw.Document pdf, ResumeData d, pw.Font r, pw.Font b, pw.Font i) async {
    const accent = PdfColor.fromInt(0xFF37474F);
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 45, vertical: 40),
      build: (ctx) => [
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(_clean(d.name).toUpperCase(),
            style: pw.TextStyle(font: b, fontSize: 22, color: accent, letterSpacing: 1.5)),
          if (_clean(d.jobTitle).isNotEmpty)
            pw.Text(_clean(d.jobTitle), style: pw.TextStyle(font: r, fontSize: 12, color: PdfColors.grey600)),
          pw.SizedBox(height: 6),
          pw.Divider(color: accent, thickness: 1.5),
          pw.SizedBox(height: 4),
          pw.Wrap(spacing: 0, children: _contactItems(d, r, color: PdfColors.grey700, fs: 9)),
          pw.SizedBox(height: 10),
        ]),
        ..._buildAllSections(d, r, b, i, accentColor: accent, dividerColor: PdfColors.blueGrey100),
      ],
    ));
    return pdf.save();
  }

  // 1 — MODERN BLUE
  Future<Uint8List> _buildModernBlue(pw.Document pdf, ResumeData d, pw.Font r, pw.Font b, pw.Font i) async {
    const hdr = PdfColor.fromInt(0xFF1565C0);
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => [
        pw.Container(
          width: double.infinity, color: hdr,
          padding: const pw.EdgeInsets.fromLTRB(35, 25, 35, 25),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(_clean(d.name).toUpperCase(),
              style: pw.TextStyle(font: b, fontSize: 26, color: PdfColors.white, letterSpacing: 1)),
            if (_clean(d.jobTitle).isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(_clean(d.jobTitle), style: pw.TextStyle(font: r, fontSize: 12, color: PdfColors.blue100)),
            ],
            pw.SizedBox(height: 10),
            pw.Wrap(spacing: 0, children: _contactItems(d, r, color: PdfColors.white, fs: 9)),
          ]),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(35, 25, 35, 30),
          child: pw.Column(children: _buildAllSections(d, r, b, i, accentColor: hdr, dividerColor: PdfColors.blue100)),
        ),
      ],
    ));
    return pdf.save();
  }

  // 2 — SIDEBAR DARK
  Future<Uint8List> _buildSidebarDark(pw.Document pdf, ResumeData d, pw.Font r, pw.Font b, pw.Font i) async {
    const sidebar = PdfColor.fromInt(0xFF1A1A2E);
    const accent  = PdfColor.fromInt(0xFF4FC3F7);
    final skills  = d.skillsList.map((s) => _clean(s)).where((s) => s.isNotEmpty).toList();
    final langs   = d.languagesList.map((s) => _clean(s)).where((s) => s.isNotEmpty).toList();

    final main = <pw.Widget>[];
    for (final s in d.sectionOrder) {
      if (d.sectionStatus[s] == false) continue;
      if (s == 'Skills' || s == 'Languages') continue;
      final w = _buildSection(s, d, r, b, i,
        accentColor: const PdfColor.fromInt(0xFF1A1A2E), dividerColor: PdfColors.blueGrey100, fontSize: 9.5, titleFontSize: 10);
      if (w != null) main.add(w);
    }

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Container(
          width: 185,
          constraints: const pw.BoxConstraints(minHeight: 841.89),
          color: sidebar,
          padding: const pw.EdgeInsets.all(22),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(_clean(d.name).toUpperCase(),
              style: pw.TextStyle(font: b, fontSize: 15, color: PdfColors.white, letterSpacing: 0.8)),
            if (_clean(d.jobTitle).isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(_clean(d.jobTitle), style: pw.TextStyle(font: r, fontSize: 9, color: accent)),
            ],
            pw.SizedBox(height: 16),
            pw.Divider(color: PdfColors.blueGrey700, thickness: 0.5),
            pw.SizedBox(height: 12),
            _sidebarHeading("CONTACT", b, accent),
            if (_clean(d.email).isNotEmpty)    _sidebarText(_clean(d.email), r),
            if (_clean(d.phone).isNotEmpty)    _sidebarText(_clean(d.phone), r),
            if (_clean(d.address).isNotEmpty)  _sidebarText(_clean(d.address), r),
            if (_clean(d.linkedin).isNotEmpty) _sidebarText(_clean(d.linkedin), r),
            if (_clean(d.website).isNotEmpty)  _sidebarText(_clean(d.website), r),
            pw.SizedBox(height: 16),
            if (skills.isNotEmpty) ...[
              _sidebarHeading("SKILLS", b, accent),
              pw.SizedBox(height: 6),
              ...skills.map((sk) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 5),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text(sk, style: pw.TextStyle(font: r, fontSize: 8.5, color: PdfColors.white)),
                  pw.SizedBox(height: 2),
                  pw.Row(children: [
                    pw.Expanded(flex: 75, child: pw.Container(height: 3,
                      decoration: const pw.BoxDecoration(color: accent,
                        borderRadius: pw.BorderRadius.all(pw.Radius.circular(2))))),
                    pw.Expanded(flex: 25, child: pw.Container(height: 3,
                      decoration: const pw.BoxDecoration(color: PdfColors.blueGrey700,
                        borderRadius: pw.BorderRadius.all(pw.Radius.circular(2))))),
                  ]),
                ]),
              )),
              pw.SizedBox(height: 16),
            ],
            if (langs.isNotEmpty) ...[
              _sidebarHeading("LANGUAGES", b, accent),
              ...langs.map((l) => _sidebarText(l, r)),
            ],
          ]),
        ),
        pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(25, 25, 30, 30),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: main),
          ),
        ),
      ]),
    ));
    return pdf.save();
  }

  // 3 — EXECUTIVE
  Future<Uint8List> _buildExecutive(pw.Document pdf, ResumeData d, pw.Font r, pw.Font b, pw.Font i) async {
    const gold  = PdfColor.fromInt(0xFFB8860B);
    const black = PdfColors.black;
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => [
        pw.Container(
          color: black,
          padding: const pw.EdgeInsets.fromLTRB(40, 28, 40, 28),
          child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text(_clean(d.name).toUpperCase(),
                style: pw.TextStyle(font: b, fontSize: 24, color: PdfColors.white, letterSpacing: 2)),
              if (_clean(d.jobTitle).isNotEmpty)
                pw.Text(_clean(d.jobTitle), style: pw.TextStyle(font: r, fontSize: 11, color: gold)),
            ]),
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              if (_clean(d.email).isNotEmpty)
                pw.Text(_clean(d.email), style: pw.TextStyle(font: r, fontSize: 9, color: PdfColors.grey300)),
              if (_clean(d.phone).isNotEmpty)
                pw.Text(_clean(d.phone), style: pw.TextStyle(font: r, fontSize: 9, color: PdfColors.grey300)),
              if (_clean(d.address).isNotEmpty)
                pw.Text(_clean(d.address), style: pw.TextStyle(font: r, fontSize: 9, color: PdfColors.grey300)),
              if (_clean(d.linkedin).isNotEmpty)
                pw.Text(_clean(d.linkedin), style: pw.TextStyle(font: r, fontSize: 9, color: PdfColors.grey300)),
              if (_clean(d.website).isNotEmpty)
                pw.Text(_clean(d.website), style: pw.TextStyle(font: r, fontSize: 9, color: PdfColors.grey300)),
            ]),
          ]),
        ),
        pw.Container(height: 3, color: gold),
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(40, 25, 40, 30),
          child: pw.Column(children: _buildAllSections(d, r, b, i, accentColor: black, dividerColor: gold)),
        ),
      ],
    ));
    return pdf.save();
  }

  // 4 — MINIMAL LINE
  Future<Uint8List> _buildMinimalLine(pw.Document pdf, ResumeData d, pw.Font r, pw.Font b, pw.Font i) async {
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 55, vertical: 45),
      build: (ctx) => [
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
          pw.Text(_clean(d.name).toUpperCase(),
            style: pw.TextStyle(font: b, fontSize: 26, letterSpacing: 4), textAlign: pw.TextAlign.center),
          if (_clean(d.jobTitle).isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(_clean(d.jobTitle),
              style: pw.TextStyle(font: r, fontSize: 11, color: PdfColors.grey600), textAlign: pw.TextAlign.center),
          ],
          pw.SizedBox(height: 8),
          pw.Wrap(alignment: pw.WrapAlignment.center, spacing: 0,
            children: _contactItems(d, r, color: PdfColors.grey600, fs: 8.5)),
          pw.SizedBox(height: 15),
        ]),
        ..._buildAllSections(d, r, b, i,
          accentColor: PdfColors.black, dividerColor: PdfColors.grey300, fontSize: 9.5, titleFontSize: 10),
      ],
    ));
    return pdf.save();
  }

  // 5 — EMERALD SPLIT
  Future<Uint8List> _buildEmeraldSplit(pw.Document pdf, ResumeData d, pw.Font r, pw.Font b, pw.Font i) async {
    const emerald = PdfColor.fromInt(0xFF00695C);
    const light   = PdfColor.fromInt(0xFFE0F2F1);
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => [
        pw.Container(width: double.infinity, color: emerald, height: 6),
        pw.Container(
          padding: const pw.EdgeInsets.fromLTRB(40, 22, 40, 18),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text(_clean(d.name).toUpperCase(),
                  style: pw.TextStyle(font: b, fontSize: 22, color: emerald, letterSpacing: 1.2)),
                if (_clean(d.jobTitle).isNotEmpty)
                  pw.Text(_clean(d.jobTitle), style: pw.TextStyle(font: r, fontSize: 11, color: PdfColors.grey600)),
              ]),
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                if (_clean(d.email).isNotEmpty)    pw.Text(_clean(d.email),    style: pw.TextStyle(font: r, fontSize: 9, color: PdfColors.grey700)),
                if (_clean(d.phone).isNotEmpty)    pw.Text(_clean(d.phone),    style: pw.TextStyle(font: r, fontSize: 9, color: PdfColors.grey700)),
                if (_clean(d.address).isNotEmpty)  pw.Text(_clean(d.address),  style: pw.TextStyle(font: r, fontSize: 9, color: PdfColors.grey700)),
                if (_clean(d.linkedin).isNotEmpty) pw.Text(_clean(d.linkedin), style: pw.TextStyle(font: r, fontSize: 9, color: PdfColors.grey700)),
                if (_clean(d.website).isNotEmpty)  pw.Text(_clean(d.website),  style: pw.TextStyle(font: r, fontSize: 9, color: PdfColors.grey700)),
              ]),
            ],
          ),
        ),
        pw.Container(color: light, height: 2),
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(40, 20, 40, 30),
          child: pw.Column(children: _buildAllSections(d, r, b, i, accentColor: emerald, dividerColor: light)),
        ),
      ],
    ));
    return pdf.save();
  }

  // 6 — SLATE COLUMN
  Future<Uint8List> _buildSlateColumn(pw.Document pdf, ResumeData d, pw.Font r, pw.Font b, pw.Font i) async {
    const slate      = PdfColor.fromInt(0xFF455A64);
    const slateDark  = PdfColor.fromInt(0xFF37474F);
    const slateLight = PdfColor.fromInt(0xFFECEFF1);
    final skills = d.skillsList.map((s) => _clean(s)).where((s) => s.isNotEmpty).toList();
    final langs  = d.languagesList.map((s) => _clean(s)).where((s) => s.isNotEmpty).toList();

    final main = <pw.Widget>[];
    for (final s in d.sectionOrder) {
      if (d.sectionStatus[s] == false) continue;
      if (s == 'Skills' || s == 'Languages') continue;
      final w = _buildSection(s, d, r, b, i, accentColor: slate, dividerColor: slateLight, fontSize: 9.5, titleFontSize: 10.5);
      if (w != null) main.add(w);
    }

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Container(
          width: 178,
          constraints: const pw.BoxConstraints(minHeight: 841.89),
          color: slate,
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Container(
              width: double.infinity, color: slateDark,
              padding: const pw.EdgeInsets.fromLTRB(18, 28, 14, 22),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text(_clean(d.name), style: pw.TextStyle(font: b, fontSize: 14, color: PdfColors.white, letterSpacing: 0.5)),
                if (_clean(d.jobTitle).isNotEmpty) ...[
                  pw.SizedBox(height: 5),
                  pw.Text(_clean(d.jobTitle), style: pw.TextStyle(font: r, fontSize: 9, color: PdfColors.blueGrey100)),
                ],
              ]),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(18),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                _sidebarHeading("CONTACT", b, PdfColors.blueGrey100),
                if (_clean(d.email).isNotEmpty)    _sidebarText(_clean(d.email), r),
                if (_clean(d.phone).isNotEmpty)    _sidebarText(_clean(d.phone), r),
                if (_clean(d.address).isNotEmpty)  _sidebarText(_clean(d.address), r),
                if (_clean(d.linkedin).isNotEmpty) _sidebarText(_clean(d.linkedin), r),
                if (_clean(d.website).isNotEmpty)  _sidebarText(_clean(d.website), r),
                pw.SizedBox(height: 18),
                if (skills.isNotEmpty) ...[
                  _sidebarHeading("SKILLS", b, PdfColors.blueGrey100),
                  pw.SizedBox(height: 4),
                  ...skills.map((s) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Text(s, style: pw.TextStyle(font: r, fontSize: 8.5, color: PdfColors.white)),
                  )),
                  pw.SizedBox(height: 18),
                ],
                if (langs.isNotEmpty) ...[
                  _sidebarHeading("LANGUAGES", b, PdfColors.blueGrey100),
                  ...langs.map((l) => _sidebarText(l, r)),
                ],
              ]),
            ),
          ]),
        ),
        pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(26, 30, 32, 30),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: main),
          ),
        ),
      ]),
    ));
    return pdf.save();
  }

  // 7 — CRIMSON EDGE
  Future<Uint8List> _buildCrimsonEdge(pw.Document pdf, ResumeData d, pw.Font r, pw.Font b, pw.Font i) async {
    const crimson = PdfColor.fromInt(0xFFC62828);
    const dark    = PdfColor.fromInt(0xFF1C1C1C);
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => [
        pw.Stack(children: [
          pw.Positioned(left: 0, top: 0, bottom: 0, child: pw.Container(width: 5, color: crimson)),
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(25, 32, 36, 26),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text(_clean(d.name).toUpperCase(),
                    style: pw.TextStyle(font: b, fontSize: 24, color: dark, letterSpacing: 1.5)),
                  if (_clean(d.jobTitle).isNotEmpty) ...[
                    pw.SizedBox(height: 5),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      color: crimson,
                      child: pw.Text(_clean(d.jobTitle),
                        style: pw.TextStyle(font: b, fontSize: 10, color: PdfColors.white)),
                    ),
                  ],
                ]),
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                  if (_clean(d.email).isNotEmpty)    pw.Text(_clean(d.email),    style: pw.TextStyle(font: r, fontSize: 9, color: PdfColors.grey700)),
                  if (_clean(d.phone).isNotEmpty)    pw.Text(_clean(d.phone),    style: pw.TextStyle(font: r, fontSize: 9, color: PdfColors.grey700)),
                  if (_clean(d.address).isNotEmpty)  pw.Text(_clean(d.address),  style: pw.TextStyle(font: r, fontSize: 9, color: PdfColors.grey700)),
                  if (_clean(d.linkedin).isNotEmpty) pw.Text(_clean(d.linkedin), style: pw.TextStyle(font: r, fontSize: 9, color: PdfColors.grey700)),
                  if (_clean(d.website).isNotEmpty)  pw.Text(_clean(d.website),  style: pw.TextStyle(font: r, fontSize: 9, color: PdfColors.grey700)),
                ]),
              ],
            ),
          ),
        ]),
        pw.Container(height: 1.5, color: crimson, margin: const pw.EdgeInsets.fromLTRB(25, 0, 36, 0)),
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(25, 10, 36, 30),
          child: pw.Stack(children: [
            pw.Positioned(left: 0, top: 0, bottom: 0,
              child: pw.Container(width: 2, color: const PdfColor.fromInt(0xFFFFEBEE))),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 14),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: _buildAllSections(d, r, b, i,
                  accentColor: crimson, dividerColor: const PdfColor.fromInt(0xFFFFCDD2))),
            ),
          ]),
        ),
      ],
    ));
    return pdf.save();
  }

  // 8 — NAVY TIMELINE
  Future<Uint8List> _buildNavyTimeline(pw.Document pdf, ResumeData d, pw.Font r, pw.Font b, pw.Font i) async {
    const navy     = PdfColor.fromInt(0xFF0D2137);
    const navyTint = PdfColor.fromInt(0xFFE8F0F7);
    const navyMid  = PdfColor.fromInt(0xFF1A3A5C);

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => [
        pw.Container(
          width: double.infinity, color: navy,
          padding: const pw.EdgeInsets.fromLTRB(42, 32, 42, 28),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(_clean(d.name).toUpperCase(),
              style: pw.TextStyle(font: b, fontSize: 25, color: PdfColors.white, letterSpacing: 1.8)),
            if (_clean(d.jobTitle).isNotEmpty) ...[
              pw.SizedBox(height: 6),
              pw.Text(_clean(d.jobTitle),
                style: pw.TextStyle(font: r, fontSize: 12, color: const PdfColor.fromInt(0xFF90CAF9))),
            ],
            pw.SizedBox(height: 14),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 8),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: PdfColors.blueGrey700, width: 0.5),
                  bottom: pw.BorderSide(color: PdfColors.blueGrey700, width: 0.5),
                ),
              ),
              child: pw.Wrap(spacing: 0,
                children: _contactItems(d, r, color: PdfColors.blueGrey200, fs: 9)),
            ),
          ]),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(42, 22, 42, 30),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: _buildAllSectionsNavy(d, r, b, i, accentColor: navy, tintColor: navyTint),
          ),
        ),
      ],
    ));
    return pdf.save();
  }

  List<pw.Widget> _buildAllSectionsNavy(ResumeData d, pw.Font r, pw.Font b, pw.Font i, {
    required PdfColor accentColor, required PdfColor tintColor,
  }) {
    final widgets = <pw.Widget>[];
    for (final section in d.sectionOrder) {
      if (d.sectionStatus[section] == false) continue;
      pw.Widget? w;
      if (section == 'Experience' && d.experienceList.isNotEmpty) {
        w = _navySection("EXPERIENCE", accentColor, b,
          pw.Column(children: d.experienceList.map((e) => _timelineEntry(
            title: _clean(e['company']),
            subtitle: _clean(e['job']),
            date: () {
              final s = _clean(e['start'] ?? e['startDate'] ?? '');
              final rawE = _clean(e['end'] ?? e['endDate'] ?? '');
              final en = rawE.isEmpty ? 'Present' : rawE;
              if (s.isEmpty && en == 'Present') return '';
              if (s.isEmpty) return en;
              return '$s - $en';
            }(),
            body: _clean(e['details'] ?? e['description']),
            r: r, b: b, i: i, dot: accentColor,
          )).toList()));
      } else if (section == 'Education' && d.educationList.isNotEmpty) {
        w = _navySection("EDUCATION", accentColor, b,
          pw.Column(children: d.educationList.map((e) => _timelineEntry(
            title: _clean(e['school'] ?? e['college']),
            subtitle: _clean(e['course']),
            date: _clean(e['year']),
            body: _clean(e['score']).isNotEmpty ? "Score: ${_clean(e['score'])}" : "",
            r: r, b: b, i: i, dot: accentColor,
          )).toList()));
      } else {
        w = _buildSection(section, d, r, b, i,
          accentColor: accentColor, dividerColor: tintColor, fontSize: 10, titleFontSize: 11);
      }
      if (w != null) widgets.add(w);
    }
    return widgets;
  }

  pw.Widget _navySection(String title, PdfColor accent, pw.Font b, pw.Widget content) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.SizedBox(height: 16),
      pw.Row(children: [
        pw.Container(width: 3, height: 14, color: accent, margin: const pw.EdgeInsets.only(right: 8)),
        pw.Text(title, style: pw.TextStyle(font: b, fontSize: 11, color: accent, letterSpacing: 0.8)),
      ]),
      pw.Container(height: 0.8, color: accent, margin: const pw.EdgeInsets.only(top: 4, bottom: 10)),
      content,
    ]);
  }

  pw.Widget _timelineEntry({
    required String title, required String subtitle, required String date, required String body,
    required pw.Font r, required pw.Font b, required pw.Font i, required PdfColor dot,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 3, right: 10),
          child: pw.Container(width: 7, height: 7,
            decoration: pw.BoxDecoration(color: dot, shape: pw.BoxShape.circle)),
        ),
        pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Expanded(child: pw.Text(title, style: pw.TextStyle(font: b, fontSize: 10))),
            if (date.isNotEmpty) pw.Text(date, style: pw.TextStyle(font: r, fontSize: 9, color: PdfColors.grey600)),
          ]),
          if (subtitle.isNotEmpty)
            pw.Text(subtitle, style: pw.TextStyle(font: i, fontSize: 9.5, color: PdfColors.grey700)),
          if (body.isNotEmpty) ...[pw.SizedBox(height: 4), _bullets(body, r, fontSize: 9)],
        ])),
      ]),
    );
  }

  // ── SHARED HELPERS ────────────────────────────────────────────
  pw.Widget _sBlock(String title, PdfColor accent, PdfColor divider, double ts, pw.Font b, pw.Widget content) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.SizedBox(height: 14),
      pw.Text(title, style: pw.TextStyle(font: b, fontSize: ts, color: accent, letterSpacing: 0.8)),
      pw.Container(height: 1.5, color: accent, margin: const pw.EdgeInsets.only(top: 3, bottom: 6)),
      content,
    ]);
  }

  pw.Widget _bullets(String text, pw.Font font, {double fontSize = 9}) {
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return pw.Text(text, style: pw.TextStyle(font: font, fontSize: fontSize));
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: lines.map((l) => _bulletRow(l.trim(), font, fontSize: fontSize)).toList());
  }

  pw.Widget _bulletRow(String text, pw.Font font, {double fontSize = 9}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Padding(
          padding: pw.EdgeInsets.only(top: fontSize * 0.35, right: 5),
          child: pw.Container(width: 3, height: 3,
            decoration: const pw.BoxDecoration(color: PdfColors.grey700, shape: pw.BoxShape.circle)),
        ),
        pw.Expanded(child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: fontSize))),
      ]),
    );
  }

  pw.Widget _sidebarHeading(String text, pw.Font b, PdfColor color) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(text, style: pw.TextStyle(font: b, fontSize: 9, color: color, letterSpacing: 1)),
      pw.Divider(color: PdfColors.blueGrey700, thickness: 0.5),
      pw.SizedBox(height: 6),
    ]);
  }

  pw.Widget _sidebarText(String text, pw.Font r) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Text(text, style: pw.TextStyle(font: r, fontSize: 8.5, color: PdfColors.white)),
  );
  // ================================================================
  // 9 — CLEAN ATS PRO  (matches uploaded one-page plain resume style)
  // Pure Helvetica, no color blocks, maximum ATS compatibility
  // ================================================================
  Future<Uint8List> _buildCleanAtsPro(pw.Document pdf, ResumeData d, pw.Font r, pw.Font b, pw.Font i) async {
    const black  = PdfColors.black;
    const grey6  = PdfColors.grey600;
    const grey8  = PdfColors.grey800;
    const divClr = PdfColors.grey400;

    // ── helpers ──────────────────────────────────────────────────
    pw.Widget _section(String title, pw.Widget content) {
      return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.SizedBox(height: 12),
        pw.Text(title.toUpperCase(),
          style: pw.TextStyle(font: b, fontSize: 10.5, color: black, letterSpacing: 1.2)),
        pw.Container(height: 0.8, color: black, margin: const pw.EdgeInsets.only(top: 3, bottom: 7)),
        content,
      ]);
    }

    pw.Widget _expEntry(Map e) {
      final company = _clean(e['company']);
      final job     = _clean(e['job']);
      final start   = _clean(e['start'] ?? e['startDate'] ?? '');
      final rawEnd  = _clean(e['end'] ?? e['endDate'] ?? '');
      final end     = rawEnd.isEmpty ? 'Present' : rawEnd;
      final dateStr = start.isEmpty ? end : '$start - $end';
      final details = _clean(e['details'] ?? e['description']);
      return pw.Padding(padding: const pw.EdgeInsets.only(bottom: 9), child:
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Expanded(child: pw.RichText(text: pw.TextSpan(children: [
              pw.TextSpan(text: company, style: pw.TextStyle(font: b, fontSize: 10)),
              if (job.isNotEmpty) pw.TextSpan(text: '  |  $job',
                style: pw.TextStyle(font: i, fontSize: 9.5, color: grey8)),
            ]))),
            if (dateStr.isNotEmpty)
              pw.Text(dateStr, style: pw.TextStyle(font: r, fontSize: 9, color: grey6)),
          ]),
          if (details.isNotEmpty) ...[pw.SizedBox(height: 3), _bullets(details, r, fontSize: 9)],
        ]));
    }

    pw.Widget _eduEntry(Map e) {
      final school = _clean(e['school'] ?? e['college']);
      final course = _clean(e['course']);
      final year   = _clean(e['year']);
      final score  = _clean(e['score']);
      return pw.Padding(padding: const pw.EdgeInsets.only(bottom: 8), child:
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(school, style: pw.TextStyle(font: b, fontSize: 10)),
            if (course.isNotEmpty) pw.Text(course, style: pw.TextStyle(font: r, fontSize: 9.5, color: grey8)),
            if (score.isNotEmpty)  pw.Text('Score: $score', style: pw.TextStyle(font: r, fontSize: 9, color: grey6)),
          ])),
          if (year.isNotEmpty) pw.Text(year, style: pw.TextStyle(font: r, fontSize: 9, color: grey6)),
        ]));
    }

    // ── build sections list ──────────────────────────────────────
    final List<pw.Widget> sections = [];
    for (final s in d.sectionOrder) {
      if (d.sectionStatus[s] == false) continue;
      switch (s) {
        case 'Objective':
          if (_clean(d.objective).isNotEmpty)
            sections.add(_section('Professional Summary',
              pw.Text(_clean(d.objective),
                style: pw.TextStyle(font: r, fontSize: 9.5, lineSpacing: 2),
                textAlign: pw.TextAlign.justify)));
          break;
        case 'Experience':
          if (d.experienceList.isNotEmpty)
            sections.add(_section('Work Experience',
              pw.Column(children: d.experienceList.map(_expEntry).toList())));
          break;
        case 'Education':
          if (d.educationList.isNotEmpty)
            sections.add(_section('Education',
              pw.Column(children: d.educationList.map(_eduEntry).toList())));
          break;
        default:
          final w = _buildSection(s, d, r, b, i,
            accentColor: black, dividerColor: divClr, fontSize: 9.5, titleFontSize: 10);
          if (w != null) sections.add(w);
      }
    }

    // ── page ─────────────────────────────────────────────────────
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 38),
      build: (ctx) => [
        // Name block
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(_clean(d.name).toUpperCase(),
            style: pw.TextStyle(font: b, fontSize: 22, color: black, letterSpacing: 2.0)),
          if (_clean(d.jobTitle).isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.Text(_clean(d.jobTitle),
              style: pw.TextStyle(font: i, fontSize: 11, color: grey8, letterSpacing: 0.5)),
          ],
          pw.SizedBox(height: 5),
          pw.Container(height: 1, color: black),
          pw.SizedBox(height: 4),
          // Contact line — all items separated by •
          pw.Wrap(spacing: 0, children: () {
            final items = <String>[];
            if (_clean(d.address).isNotEmpty)  items.add(_clean(d.address));
            if (_clean(d.phone).isNotEmpty)    items.add(_clean(d.phone));
            if (_clean(d.email).isNotEmpty)    items.add(_clean(d.email));
            if (_clean(d.linkedin).isNotEmpty) items.add(_clean(d.linkedin));
            if (_clean(d.website).isNotEmpty)  items.add(_clean(d.website));
            final widgets = <pw.Widget>[];
            for (int idx = 0; idx < items.length; idx++) {
              widgets.add(pw.Text(items[idx],
                style: pw.TextStyle(font: r, fontSize: 9, color: grey8)));
              if (idx < items.length - 1)
                widgets.add(pw.Text('  |  ',
                  style: pw.TextStyle(font: r, fontSize: 9, color: grey6)));
            }
            return widgets;
          }()),
          pw.SizedBox(height: 2),
          pw.Container(height: 0.5, color: divClr),
        ]),
        ...sections,
      ],
    ));
    return pdf.save();
  }


}

class _AtsPoint extends StatelessWidget {
  final String text;
  const _AtsPoint({required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
    ]),
  );
}
