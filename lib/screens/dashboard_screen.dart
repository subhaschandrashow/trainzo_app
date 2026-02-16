import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'webview/webview_screen.dart';
import 'login_screen.dart';
import 'scanner.dart';
import '../utils/constants.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const DashboardScreen({required this.user, super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String currentUrl = Constants.rootUrl;
  String currentTitle = "Dashboard";
  String sessionId = "";
  String role = "";
  bool _sessionChecked = false;

  @override
  void initState() {
    super.initState();
    _verifySession();
  }

  /// ✅ Verify session validity before loading dashboard
  Future<void> _verifySession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    role = prefs.getString('role') ?? '';

    if (token == null || token.isEmpty) {
      _logout();
      return;
    }

    setState(() {
      _sessionChecked = true;
      currentUrl = "${Constants.rootUrl}/index.php?view=dashboard";
    });
  }


  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    try {
      if (token != null && token.isNotEmpty) {
        await http.post(
          Uri.parse("${Constants.apiBaseUrl}/logout.php"),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      }
    } catch (e) {
      print("Logout API error: $e");
    }

    await prefs.clear();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }


  // 🔸 Dashboard menus
  List<Map<String, dynamic>> getMenus() {
    final baseMenus = <Map<String, dynamic>>[];

    if (role == 'saas_admin') {
      baseMenus.addAll([
        {
        'title': 'Gyms',
        'icon': Icons.location_city,
        'submenus': {
          'All Gyms': 'gyms',
        },
       },
       {
        'title': 'Users',
        'icon': Icons.people,
        'submenus': {
          'Users': 'users'
        },
      },
      {
        'title': 'Gym Owners',
        'icon': Icons.people,
        'submenus': {
          'Gym Owners': 'gym_owners'
        },
      },
      {
        'title': 'Students',
        'icon': Icons.people,
        'submenus': {
          'Students': 'students'
        },
      },
      {
        'title': 'Trainers',
        'icon': Icons.people,
        'submenus': {
          'Trainers': 'trainers'
        },
      },
      {
        'title': 'Plans',
        'icon': Icons.people,
        'submenus': {
          'Plans': 'plans'
        },
      },
      {
        'title': 'Subscriptions',
        'icon': Icons.people,
        'submenus': {
          'Subscriptions': 'gym_owners_subscriptions'
        },
      },
      {
        'title': 'Settings',
        'icon': Icons.people,
        'submenus': {
          'Settings': 'settings'
        },
      },
      {
        'title': 'Developer Options',
        'icon': Icons.people,
        'submenus': {
          'Developer Options': 'developer_options'
        }
      },

      ]);

    }
    else if (role == 'gym_owner') {
      baseMenus.addAll([
      {
        'title': 'Gyms',
        'icon': Icons.location_city,
        'submenus': {
          'All Gyms': 'gyms',
          'Membership Plans': 'membership_plans',
          'Subscriptions': 'subscriptions',
          'Announcements': 'announcements',
          'Feedback': 'feedbacks',
          'Equipments': 'equipments',
          'Equipment Log': 'equipment_logs',
          'Maintenance Requests': 'maintainance_requests',
        },
      },
      {
        'title': 'Trainers',
        'icon': Icons.people,
        'submenus': {
          'All Trainers': 'trainers',
          'Trainer Schedules': 'trainer_schedules',
          'Trainer Attendances': 'trainer_attendance',
        },
      },
      {
        'title': 'Students',
        'icon': Icons.person,
        'submenus': {
          'All Students': 'students',
          'Student Attendances': 'student_attendance',
          'Attendance Register': 'attendance_register',
          'Absentee Report': 'absentee_report',
          'Personal Training': 'personal_training',
          'Assign Workout': 'student_workouts',
          'Assign Diet': 'student_diets',
          'Progress Tracking': 'student_progress',
          'Achievements': 'student_achievements',
        },
      },
      {
        'title': 'My Profile',
        'icon': Icons.person_pin,
        'submenus': {
          'View Profile': 'profile',
        },
      },
      {
        'title': 'Finances',
        'icon': Icons.account_balance_wallet,
        'submenus': {
          'Payment List': 'payments',
          'Invoice List': 'invoice_list',
          'Revenue Reports': 'revenue_reports',
          'Link Barcode': 'link_barcode',
        },
      },
      {
        'title': 'System',
        'icon': Icons.settings,
        'submenus': {
          'Subscriptions': 'saas_subscription',
          'Billing History': 'billing_history',
          'Make Payment': 'renew_membership',
        },
      },
    ]);
    } else if (role == 'trainer') {
      baseMenus.addAll([
        {
          'title': 'My Zone',
          'icon': Icons.location_city,
          'submenus': {'My Schedule': 'trainer_schedules'},
        },
        {
          'title': 'Students',
          'icon': Icons.person,
          'submenus': {
            'All Students': 'students',
            'Personal Training': 'personal_training',
            'Student Attendances': 'student_attendance',
            'Trainer Attendances': 'trainer_attendance',
            'Attendance Register': 'attendance_register',
            'Assign Workout': 'student_workouts',
            'Assign Diet': 'student_diets',
            'Progress Tracking': 'student_progress',
            'Achievements': 'student_achievements',
          },
        },
        {
          'title': 'My Profile',
          'icon': Icons.person_pin,
          'submenus': {'View Profile': 'profile'},
        },
        {
          'title': 'Scanner',
          'icon': Icons.qr_code_scanner,
          'submenus': {'Scan QR': 'scan_qr'},
        },
      ]);
    } else if (role == 'student') {
      baseMenus.addAll([
        {
          'title': 'My TODOS',
          'icon': Icons.task,
          'submenus': {
            'Workout Plans': 'student_workouts',
            'Diet Plans': 'student_diets',
          },
        },
        {
          'title': 'Membership',
          'icon': Icons.receipt_long,
          'submenus': {
            'My Membership': 'subscriptions',
            'Invoice List': 'invoice_list',
            'Payments': 'payments',
            'Feedback': 'feedbacks',
          },
        },
        {
          'title': 'My Profile',
          'icon': Icons.person_pin,
          'submenus': {'View Profile': 'profile'},
        },
        {
          'title': 'Scanner',
          'icon': Icons.qr_code_scanner,
          'submenus': {'Scan QR': 'scan_qr'},
        },
      ]);
    }

    baseMenus.add({
      'title': 'Logout',
      'icon': Icons.logout,
      'submenus': {},
    });

    return baseMenus;
  }

  // 🔸 Handle menu actions
  void _openMenu(String title, String viewName) async {
    Navigator.pop(context);

    if (viewName == 'scan_qr') {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ScannerPage()),
      );

      if (result != null && result is String) {
        final isUrl = Uri.tryParse(result)?.hasAbsolutePath ?? false;

        if (isUrl) {
          setState(() {
            currentTitle = "Scanned Link";
            currentUrl = result.contains("http") ? result : "https://$result";
          });
        }
      }
    } else {
      setState(() {
        currentTitle = title;
        currentUrl =
            "${Constants.rootUrl}/index.php?view=$viewName&from_app=1";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_sessionChecked) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.red.shade700),
        ),
      );
    }

    final menus = getMenus();

    return Scaffold(
      appBar: AppBar(
        title: Text(currentTitle),
        backgroundColor: Colors.red.shade700,
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade700, Colors.red.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: Text(
                widget.user['name'],
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: Text(widget.user['email']),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  widget.user['name'][0].toUpperCase(),
                  style: TextStyle(fontSize: 24, color: Colors.red.shade900),
                ),
              ),
            ),
            ...menus.map((menu) {
              final title = menu['title'] as String;
              final icon = menu['icon'] as IconData;
              final submenus = Map<String, dynamic>.from(menu['submenus']);

              if (submenus.isEmpty && title == 'Logout') {
                return ListTile(
                  leading: Icon(icon, color: Colors.red.shade800),
                  title: Text(
                    title,
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  onTap: _logout,
                );
              }

              return ExpansionTile(
                leading: Icon(icon, color: Colors.red.shade700),
                title: Text(
                  title,
                  style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      fontSize: 16),
                ),
                iconColor: Colors.red.shade700,
                children: submenus.entries.map((entry) {
                  final subTitle = entry.key;
                  final viewName = entry.value.toString();
                  return ListTile(
                    dense: true,
                    leading:
                        const Icon(Icons.arrow_right, color: Colors.black54),
                    title: Text(
                      subTitle,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () => _openMenu(subTitle, viewName),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
      body: WebViewPage(
        key: ValueKey(currentUrl),
        title: currentTitle,
        url: currentUrl,
      ),
    );
  }
}
