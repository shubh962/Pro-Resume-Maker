import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Central singleton — holds all data for the currently active resume
/// and manages persistence via SharedPreferences.
class ResumeData {
  static final ResumeData _instance = ResumeData._internal();
  factory ResumeData() => _instance;
  ResumeData._internal();

  List<Map<String, dynamic>> savedResumes = [];
  String currentResumeId = "";

  // ── PERSONAL ──────────────────────────────────────────────────
  String name          = "";
  String jobTitle      = "";
  String email         = "";
  String phone         = "";
  String address       = "";
  String website       = "";   // NEW: portfolio / GitHub
  String linkedin      = "";   // NEW: LinkedIn URL
  String objective     = "";
  String profileImage  = "";
  String additionalInfo = "";
  String signature     = "";

  // ── LISTS ─────────────────────────────────────────────────────
  List<Map<String, String>> educationList  = [];
  List<Map<String, String>> experienceList = [];
  List<Map<String, String>> projectList    = [];
  List<Map<String, String>> referenceList  = [];
  List<String> skillsList       = [];
  List<String> languagesList    = [];
  List<String> interestsList    = [];
  List<String> achievementsList = [];
  List<String> activitiesList   = [];
  List<String> publicationList  = [];

  // ── CUSTOM SECTIONS ───────────────────────────────────────────
  List<Map<String, dynamic>> customSections = [];

  // ── SECTION ORDER & STATUS ────────────────────────────────────
  final List<String> defaultOrder = const [
    'Objective', 'Experience', 'Education', 'Skills', 'Projects',
    'Languages', 'Reference', 'Interests', 'Achievements & Awards',
    'Activities', 'Publication', 'Additional Information', 'Signature',
  ];

  List<String> sectionOrder = [];

  Map<String, bool> sectionStatus = {};

  // ── CREATE NEW ────────────────────────────────────────────────
  void createNewResume() {
    currentResumeId  = DateTime.now().millisecondsSinceEpoch.toString();
    name = jobTitle = email = phone = address = "";
    website = linkedin = objective = profileImage = additionalInfo = signature = "";
    educationList.clear(); experienceList.clear(); skillsList.clear();
    projectList.clear();   referenceList.clear();  languagesList.clear();
    interestsList.clear(); achievementsList.clear(); activitiesList.clear();
    publicationList.clear(); customSections.clear();
    sectionStatus = _defaultStatus();
    sectionOrder  = List.from(defaultOrder);
  }

  // ── LOAD BY INDEX ─────────────────────────────────────────────
  void loadResume(int index) {
    final r = savedResumes[index];
    currentResumeId  = r['id']              ?? "";
    name             = r['name']            ?? "";
    jobTitle         = r['jobTitle']        ?? "";
    email            = r['email']           ?? "";
    phone            = r['phone']           ?? "";
    address          = r['address']         ?? "";
    website          = r['website']         ?? "";
    linkedin         = r['linkedin']        ?? "";
    objective        = r['objective']       ?? "";
    profileImage     = r['profileImage']    ?? "";
    additionalInfo   = r['additionalInfo']  ?? "";
    signature        = r['signature']       ?? "";

    educationList  = _decodeList(r['education']);
    experienceList = _decodeList(r['experience']);
    projectList    = _decodeList(r['projects']);
    referenceList  = _decodeList(r['references']);

    skillsList       = _decodeStrList(r['skills']);
    languagesList    = _decodeStrList(r['languages']);
    interestsList    = _decodeStrList(r['interests']);
    achievementsList = _decodeStrList(r['achievements']);
    activitiesList   = _decodeStrList(r['activities']);
    publicationList  = _decodeStrList(r['publications']);

    customSections = r['customSections'] != null
        ? List<Map<String, dynamic>>.from(jsonDecode(r['customSections']))
        : [];

    if (r['sectionStatus'] != null) {
      final loaded = Map<String, bool>.from(jsonDecode(r['sectionStatus']));
      sectionStatus = Map.from(_defaultStatus())..addAll(_migrateKeys(loaded));
    } else {
      sectionStatus = _defaultStatus();
    }

    if (r['sectionOrder'] != null) {
      List<String> order = _migrateOrderKeys(
        List<String>.from(jsonDecode(r['sectionOrder'])));
      final seen = <String>{};
      order = order.where((s) => seen.add(s)).toList();
      for (final s in defaultOrder) { if (!order.contains(s)) order.add(s); }
      sectionOrder = order;
    } else {
      sectionOrder = List.from(defaultOrder);
    }
  }

  // ── DEFAULT STATUS ────────────────────────────────────────────
  Map<String, bool> _defaultStatus() => {
    'Objective'             : true,
    'Experience'            : true,
    'Education'             : true,
    'Skills'                : true,
    'Projects'              : true,
    'Languages'             : false,
    'Reference'             : true,
    'Interests'             : false,
    'Achievements & Awards' : false,
    'Activities'            : false,
    'Publication'           : false,
    'Additional Information': false,
    'Signature'             : false,
  };

  // ── PROGRESS ──────────────────────────────────────────────────
  double getProgress() {
    int filled = 0;
    if (name.isNotEmpty)           filled++;
    if (email.isNotEmpty)          filled++;
    if (educationList.isNotEmpty)  filled++;
    if (experienceList.isNotEmpty) filled++;
    if (skillsList.isNotEmpty)     filled++;
    return filled / 5;
  }

  // ── SAVE ──────────────────────────────────────────────────────
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final current = {
      'id'             : currentResumeId,
      'name'           : name,
      'jobTitle'       : jobTitle,
      'email'          : email,
      'phone'          : phone,
      'address'        : address,
      'website'        : website,
      'linkedin'       : linkedin,
      'objective'      : objective,
      'profileImage'   : profileImage,
      'additionalInfo' : additionalInfo,
      'signature'      : signature,
      'education'      : jsonEncode(educationList),
      'experience'     : jsonEncode(experienceList),
      'skills'         : jsonEncode(skillsList),
      'projects'       : jsonEncode(projectList),
      'references'     : jsonEncode(referenceList),
      'languages'      : jsonEncode(languagesList),
      'interests'      : jsonEncode(interestsList),
      'achievements'   : jsonEncode(achievementsList),
      'activities'     : jsonEncode(activitiesList),
      'publications'   : jsonEncode(publicationList),
      'customSections' : jsonEncode(customSections),
      'sectionStatus'  : jsonEncode(sectionStatus),
      'sectionOrder'   : jsonEncode(sectionOrder),
      'lastEdited'     : DateTime.now().toIso8601String(),
    };

    final idx = savedResumes.indexWhere((r) => r['id'] == currentResumeId);
    if (idx != -1) savedResumes[idx] = current; else savedResumes.add(current);
    await prefs.setString('ALL_RESUMES', jsonEncode(savedResumes));
  }

  // ── DELETE ────────────────────────────────────────────────────
  Future<void> deleteResume(int index) async {
    savedResumes.removeAt(index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ALL_RESUMES', jsonEncode(savedResumes));
  }

  // ── LOAD ALL ON START ─────────────────────────────────────────
  Future<void> loadAllResumes() async {
    final prefs  = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('ALL_RESUMES');
    if (jsonStr == null) return;

    savedResumes = List<Map<String, dynamic>>.from(jsonDecode(jsonStr));
    bool dirty = false;

    for (int i = 0; i < savedResumes.length; i++) {
      final r = Map<String, dynamic>.from(savedResumes[i]);
      if (r['sectionOrder'] != null) {
        List<String> order = _migrateOrderKeys(List<String>.from(jsonDecode(r['sectionOrder'])));
        final seen = <String>{};
        order = order.where((s) => seen.add(s)).toList();
        r['sectionOrder'] = jsonEncode(order);
        dirty = true;
      }
      if (r['sectionStatus'] != null) {
        final st = Map<String, bool>.from(jsonDecode(r['sectionStatus']));
        r['sectionStatus'] = jsonEncode(_migrateKeys(st));
        dirty = true;
      }
      savedResumes[i] = r;
    }
    if (dirty) await prefs.setString('ALL_RESUMES', jsonEncode(savedResumes));
  }

  // ── DECODE HELPERS ────────────────────────────────────────────
  List<Map<String, String>> _decodeList(String? json) {
    if (json == null || json.isEmpty) return [];
    return List<Map<String, String>>.from(
      jsonDecode(json).map((x) => Map<String, String>.from(x)));
  }

  List<String> _decodeStrList(String? json) {
    if (json == null || json.isEmpty) return [];
    return List<String>.from(jsonDecode(json));
  }

  // ── KEY MIGRATION ─────────────────────────────────────────────
  static const Map<String, String> _keyMap = {
    'Language'        : 'Languages',
    'Achievements'    : 'Achievements & Awards',
    'Additional Info' : 'Additional Information',
  };

  Map<String, bool> _migrateKeys(Map<String, bool> src) {
    final out = <String, bool>{};
    src.forEach((k, v) => out[_keyMap[k] ?? k] = v);
    return out;
  }

  List<String> _migrateOrderKeys(List<String> src) =>
    src.map((k) => _keyMap[k] ?? k).toList();
}
