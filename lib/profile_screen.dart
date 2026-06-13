import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';
import 'app_constants.dart';
import 'notification_service.dart';
import 'resume_data.dart';

// ================================================================
// PROFILE SCREEN
// Fully local — no sign in / sign up required.
// Stores user preferences in SharedPreferences.
// ================================================================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ── Prefs keys ──
  static const _kDisplayName = 'profile_display_name';
  static const _kTagline     = 'profile_tagline';
  static const _kAvatarPath  = 'profile_avatar_path';
  static const _kDarkMode    = 'profile_dark_mode';
  static const _kNotifs      = 'profile_notifications';

  String _displayName = '';
  String _tagline     = '';
  String? _avatarPath;
  bool   _darkMode    = false;
  bool   _notifications = true;

  bool _editingName    = false;
  bool _editingTagline = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _taglineCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl    = TextEditingController();
    _taglineCtrl = TextEditingController();
    _loadPrefs();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _taglineCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _displayName   = p.getString(_kDisplayName) ?? '';
      _tagline       = p.getString(_kTagline)     ?? 'Job Seeker';
      _avatarPath    = p.getString(_kAvatarPath);
      _darkMode      = p.getBool(_kDarkMode)       ?? false;
      _notifications = p.getBool(_kNotifs)         ?? true;
      _nameCtrl.text    = _displayName;
      _taglineCtrl.text = _tagline;
    });
    // Re-schedule daily notification on every app open if enabled
    if (_notifications) {
      await NotificationService.instance.scheduleDaily();
    }
  }

  Future<void> _savePrefs() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kDisplayName, _displayName);
    await p.setString(_kTagline,     _tagline);
    if (_avatarPath != null) await p.setString(_kAvatarPath, _avatarPath!);
    await p.setBool(_kDarkMode, _darkMode);
    await p.setBool(_kNotifs,   _notifications);
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null && mounted) {
      setState(() => _avatarPath = picked.path);
      await _savePrefs();
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendEmail() async {
    final uri = Uri.parse('mailto:${AppConstants.supportEmail}?subject=Resume+Maker+Support');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _rateApp() async {
    final review = InAppReview.instance;
    if (await review.isAvailable()) {
      await review.requestReview();
    } else {
      await _openUrl(AppConstants.rateAppUrl);
    }
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 8),
          Text("Clear All Data?"),
        ]),
        content: const Text(
          "This will permanently delete ALL your saved resumes and preferences. This cannot be undone.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              ResumeData().savedResumes.clear();
              setState(() {
                _displayName = '';
                _tagline     = 'Job Seeker';
                _avatarPath  = null;
              });
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("All data cleared.")),
                );
              }
            },
            child: const Text("Delete Everything", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final resumeCount = ResumeData().savedResumes.length;

    return Scaffold(
      backgroundColor: const Color(AppConstants.bgInt),
      body: CustomScrollView(
        slivers: [
          // ── HEADER SLIVER ──
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(AppConstants.darkInt),
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text("Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(AppConstants.primaryInt), Color(AppConstants.secondaryInt)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    // Avatar
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 46,
                            backgroundColor: Colors.white24,
                            backgroundImage: _avatarPath != null
                                ? FileImage(File(_avatarPath!))
                                : null,
                            child: _avatarPath == null
                                ? Text(
                                    _displayName.isNotEmpty
                                        ? _displayName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(AppConstants.primaryInt), width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, size: 14, color: Color(AppConstants.primaryInt)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Name (inline edit)
                    _editingName
                        ? SizedBox(
                            width: 200,
                            child: TextField(
                              controller: _nameCtrl,
                              autofocus: true,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                                hintText: 'Your Name',
                                hintStyle: TextStyle(color: Colors.white38),
                              ),
                              onSubmitted: (v) async {
                                setState(() { _displayName = v.trim(); _editingName = false; });
                                await _savePrefs();
                              },
                            ),
                          )
                        : GestureDetector(
                            onTap: () => setState(() => _editingName = true),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _displayName.isEmpty ? 'Tap to set name' : _displayName,
                                  style: TextStyle(
                                    color: _displayName.isEmpty ? Colors.white54 : Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.edit, color: Colors.white54, size: 14),
                              ],
                            ),
                          ),
                    const SizedBox(height: 4),
                    // Tagline
                    _editingTagline
                        ? SizedBox(
                            width: 220,
                            child: TextField(
                              controller: _taglineCtrl,
                              autofocus: true,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                                hintText: 'e.g. Software Engineer',
                                hintStyle: TextStyle(color: Colors.white24),
                              ),
                              onSubmitted: (v) async {
                                setState(() { _tagline = v.trim(); _editingTagline = false; });
                                await _savePrefs();
                              },
                            ),
                          )
                        : GestureDetector(
                            onTap: () => setState(() => _editingTagline = true),
                            child: Text(
                              _tagline,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 20),

              // ── STATS ROW ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _statCard("$resumeCount", "Resumes\nSaved", Icons.description_outlined),
                    const SizedBox(width: 12),
                    _statCard("9", "Templates\nAvailable", Icons.style_outlined),
                    const SizedBox(width: 12),
                    _statCard("Free", "Always\nFree", Icons.star_outline),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── PREFERENCES ──
              _sectionHeader("Preferences"),
              // Dark mode toggle hidden for V1 — implement in V2
              _switchTile(
                icon: Icons.notifications_outlined,
                color: const Color(0xFF4A00E0),
                title: "Reminders",
                subtitle: "Remind me to update my resume",
                value: _notifications,
                onChanged: (v) async {
                  setState(() => _notifications = v);
                  await _savePrefs();
                  if (v) {
                    final granted = await NotificationService.instance.requestPermission();
                    if (granted) {
                      await NotificationService.instance.scheduleDaily();
                    } else {
                      // Permission denied — revert toggle
                      if (mounted) setState(() => _notifications = false);
                      await _savePrefs();
                    }
                  } else {
                    await NotificationService.instance.cancelAll();
                  }
                },
              ),
              const SizedBox(height: 20),

              // ── SUPPORT ──
              _sectionHeader("Support"),
              _linkTile(icon: Icons.help_outline,       color: const Color(0xFF0288D1), title: "FAQ",            onTap: () => _openUrl(AppConstants.faqUrl)),
              _linkTile(icon: Icons.mail_outline,        color: const Color(0xFF00695C), title: "Contact Support", onTap: _sendEmail),
              _linkTile(icon: Icons.star_rate_outlined,  color: const Color(0xFFF57F17), title: "Rate the App",   onTap: _rateApp),
              const SizedBox(height: 20),

              // ── LEGAL ──
              _sectionHeader("Legal"),
              _linkTile(
                icon: Icons.privacy_tip_outlined,
                color: const Color(0xFF5C6BC0),
                title: "Privacy Policy",
                onTap: () => _openUrl(AppConstants.privacyPolicyUrl),
              ),
              _linkTile(
                icon: Icons.gavel_outlined,
                color: const Color(0xFF6D4C41),
                title: "Terms of Service",
                onTap: () => _openUrl(AppConstants.termsOfServiceUrl),
              ),
              _linkTile(
                icon: Icons.info_outline,
                color: const Color(0xFF546E7A),
                title: "About Us",
                onTap: () => _openUrl(AppConstants.aboutUsUrl),
              ),
              const SizedBox(height: 20),

              // ── SOCIAL ──
              _sectionHeader("Follow Us"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _socialButton(Icons.camera_alt_outlined, "Instagram", const Color(0xFFE1306C),
                        () => _openUrl(AppConstants.instagramUrl)),
                    const SizedBox(width: 12),
                    _socialButton(Icons.alternate_email, "Twitter / X", const Color(0xFF1DA1F2),
                        () => _openUrl(AppConstants.twitterUrl)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── DANGER ZONE ──
              _sectionHeader("Data"),
              _linkTile(
                icon: Icons.delete_forever_outlined,
                color: Colors.redAccent,
                title: "Clear All Data",
                subtitle: "Delete all resumes & preferences",
                onTap: _clearAllData,
                titleColor: Colors.redAccent,
              ),
              const SizedBox(height: 24),

              // ── APP VERSION ──
              Center(
                child: Text(
                  "${AppConstants.appName}  v${AppConstants.appVersion}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    _footerLink("Privacy Policy", AppConstants.privacyPolicyUrl),
                    const Text("  ·  ", style: TextStyle(color: Colors.grey, fontSize: 11)),
                    _footerLink("Terms", AppConstants.termsOfServiceUrl),
                    const Text("  ·  ", style: TextStyle(color: Colors.grey, fontSize: 11)),
                    _footerLink("Contact", AppConstants.contactUsUrl),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ]),
          ),
        ],
      ),
    );
  }

  // ── WIDGETS ───────────────────────────────────────────────────

  Widget _sectionHeader(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.2),
    ),
  );

  Widget _statCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(AppConstants.primaryInt), size: 22),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _linkTile({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: titleColor ?? Colors.black87),
        ),
        subtitle: subtitle != null
            ? Text(subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis)
            : null,
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(AppConstants.primaryInt),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _socialButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerLink(String label, String url) {
    return GestureDetector(
      onTap: () => _openUrl(url),
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
