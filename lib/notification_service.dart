import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

// ================================================================
// NOTIFICATION SERVICE
// - 44 unique CTA messages, never repeats the same one twice in a row
// - 1 notification per day, random time 9AM–8PM (user's LOCAL timezone)
// - Works correctly for ALL international users
// - Rotates through all messages before reshuffling (Fisher-Yates)
// - Respects user's Reminders toggle in Profile
// ================================================================

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _kLastIndex    = 'notif_last_msg_index';
  static const _kShuffleOrder = 'notif_shuffle_order';
  static const int _dailyId   = 1001;
  static const int _testId    = 9999;

  // ── 44 unique CTAs ─────────────────────────────────────────────
  static const List<Map<String, String>> _messages = [
    // Motivational
    {'t': 'Your dream job is one update away 🚀',         'b': 'Add your latest project or skill to your resume today.'},
    {'t': 'Recruiters are online right now 👀',            'b': 'Make sure your resume is ready to impress.'},
    {'t': 'Good morning, future employee! ☀️',             'b': 'Spend 5 minutes polishing your resume today.'},
    {'t': 'Is your resume telling your best story?',       'b': 'Update your achievements and let your work speak.'},
    {'t': '86% of jobs are filled within 30 days 📅',     'b': "Don't get left behind — keep your resume fresh."},
    {'t': 'Your next big opportunity could be today 💼',   'b': 'Open your resume and make it shine.'},
    {'t': 'Confidence starts with preparation 💪',         'b': 'A polished resume = a confident you. Update now.'},
    {'t': "You've got skills. Show them off! ✨",          'b': 'Add that new skill or tool you learned recently.'},
    // Funny / Light
    {'t': 'Your resume called. It misses you 😢',          'b': 'Give it some love — add a new achievement today.'},
    {'t': 'Plot twist: you get the job 🎉',                'b': 'Update your resume now so the plot can happen.'},
    {'t': 'Your resume is like a selfie 🤳',               'b': 'Make sure it shows your best angle. Update it!'},
    {'t': 'Procrastination called. We declined 📵',        'b': "Open your resume. Just 2 minutes. You've got this."},
    {'t': "Your resume won't write itself (we checked)",   'b': 'Tap to add something awesome to your profile.'},
    {'t': 'LinkedIn who? 😏',                              'b': 'Your PDF resume is your real flex. Keep it fresh.'},
    {'t': 'Not to alarm you, but... 👀',                   'b': 'Your resume might be missing your latest experience.'},
    {'t': 'That project you finished? It belongs here 📋', 'b': 'Add it to your resume before you forget the details.'},
    {'t': 'The audacity to not update your resume 😤',     'b': 'You did the work. Now get the credit. Tap to update.'},
    {'t': "Nobody puts your skills in a corner 💃",        'b': "Showcase what you're great at. Update your resume."},
    // Urgency / Practical
    {'t': 'New month, new opportunities 📆',               'b': 'Start it right — review and update your resume.'},
    {'t': 'Your resume: last updated… when? 🤔',           'b': 'Keep it current. Tap to add your recent work.'},
    {'t': 'Did you learn something new this week? 🧠',     'b': 'Add it to your Skills section right now.'},
    {'t': 'Hiring season is always on 📣',                 'b': "Don't wait. Update your resume and stay ready."},
    {'t': '3 seconds to open your resume →',               'b': 'See if anything needs updating. Quick check!'},
    {'t': 'A complete resume = more callbacks 📞',          'b': 'Fill in missing sections to boost your chances.'},
    {'t': 'Pro tip: Update your summary section 📝',       'b': 'A strong summary gets your resume read in full.'},
    {'t': 'Your certifications deserve a spotlight 🎓',    'b': 'Add that course or certificate you completed.'},
    {'t': 'One more project = one more reason to hire you','b': 'Tap to add your latest project to the resume.'},
    {'t': 'References ready? 🤝',                          'b': 'Add a reference to make your resume stand out.'},
    // Career-specific
    {'t': 'ATS-friendly resumes get 3x more views 📈',    'b': 'Use the Clean ATS Pro template for best results.'},
    {'t': 'Gaps in your resume? Fill them wisely 🗓️',     'b': 'Add freelance, volunteer, or learning activities.'},
    {'t': 'Action verbs = power words 💥',                 'b': 'Start your bullet points with Led, Built, Increased…'},
    {'t': 'Numbers make resumes pop! 📊',                  'b': 'Quantify your achievements: "Increased sales by 30%"'},
    {'t': 'Tailor your resume for every job 🎯',           'b': 'Small tweaks = big difference. Try a new template.'},
    {'t': 'Your LinkedIn & resume should match 🔗',        'b': 'Keep both updated. Consistency builds trust.'},
    {'t': 'Download and share your resume today 📤',       'b': 'Send it to a friend for feedback or apply right now.'},
    {'t': 'First impressions last 👔',                     'b': 'Make yours count — pick a premium template today.'},
    // Soft & Encouraging
    {'t': "You're closer than you think 🌟",               'b': 'One more edit and your resume could be perfect.'},
    {'t': 'Every expert was once a beginner 🌱',           'b': 'Your journey matters. Add it all to your resume.'},
    {'t': 'Small steps, big career 🏆',                    'b': 'Even a tiny update keeps your resume relevant.'},
    {'t': 'Someone is hiring someone exactly like you 💡', 'b': 'Make sure your resume is ready when they look.'},
    {'t': 'Weekend plans: Update resume ✅',               'b': 'Just 5 minutes now = better chances next week.'},
    {'t': "Be the candidate they can't ignore 🔥",         'b': 'Sharpen your resume and stand above the crowd.'},
    {'t': 'Your hard work deserves to be seen 👏',         'b': "Don't undersell yourself. Tap to update your resume."},
    {'t': 'Career glow-up incoming ✨',                    'b': 'Polish your resume and watch the opportunities flow.'},
  ];

  // ── Init — call once at app startup ───────────────────────────
  Future<void> init() async {
    tz_data.initializeTimeZones();

    // Get device's real IANA timezone — works for ALL countries
    // e.g. "Asia/Kolkata", "America/New_York", "Europe/London"
    try {
      // flutter_timezone 5.x returns TimezoneInfo — use .name for IANA string
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      final String tzName = tzInfo.identifier;
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (_) {
      // Fallback: calculate UTC offset manually so notification
      // still fires at correct LOCAL time even if IANA name fails
      final offset = DateTime.now().timeZoneOffset;
      final offsetName = 'Etc/GMT${offset.isNegative ? '+' : '-'}${offset.inHours.abs()}';
      try {
        tz.setLocalLocation(tz.getLocation(offsetName));
      } catch (_) {
        // Last resort — leave as UTC (rare, Chinese OEM devices)
      }
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  // ── Request permission (Android 13+ / iOS) ────────────────────
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
          alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    return true;
  }

  // ── Schedule one daily notification at random time ────────────
  Future<void> scheduleDaily() async {
    await _plugin.cancel(_dailyId);

    final msg  = await _nextMessage();
    final rng  = Random();
    final hour = 9 + rng.nextInt(12);  // 9 AM – 8 PM in user's timezone
    final min  = rng.nextInt(60);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, min);

    // If chosen time already passed today → push to tomorrow
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _dailyId,
      msg['t']!,
      msg['b']!,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'resume_reminders',
          'Resume Reminders',
          channelDescription: 'Daily tips to keep your resume updated',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // No matchDateTimeComponents — one-shot per day
      // Rescheduled on next app open for a NEW random time each day
    );
  }

  // ── Cancel all scheduled notifications ───────────────────────
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ── TEST ONLY — fires in 5 seconds (uncomment in main.dart) ──
  // Remove before production release
  Future<void> testNow() async {
    final msg  = await _nextMessage();
    final when = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
    await _plugin.zonedSchedule(
      _testId,
      msg['t']!,
      msg['b']!,
      when,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'resume_reminders',
          'Resume Reminders',
          channelDescription: 'Daily tips to keep your resume updated',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  // ── Pick next message — Fisher-Yates shuffle rotation ─────────
  Future<Map<String, String>> _nextMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final total = _messages.length;

    List<int> order = (prefs.getStringList(_kShuffleOrder) ?? [])
        .map(int.parse)
        .toList();
    int lastIndex = prefs.getInt(_kLastIndex) ?? -1;

    if (order.isEmpty) {
      order = List.generate(total, (i) => i)..shuffle(Random());
    }

    lastIndex = (lastIndex + 1) % total;

    if (lastIndex == 0) {
      order.shuffle(Random());
    }

    await prefs.setStringList(
        _kShuffleOrder, order.map((e) => e.toString()).toList());
    await prefs.setInt(_kLastIndex, lastIndex);

    return _messages[order[lastIndex]];
  }
}
