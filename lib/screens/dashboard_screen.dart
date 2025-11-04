import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'webview/webview_screen.dart'; // We'll reuse WebViewPage
import 'login_screen.dart';
import 'scanner.dart';
import '../utils/constants.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const DashboardScreen({required this.user, Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String currentUrl = Constants.rootUrl;
  String currentTitle = "Dashboard";
  String sessionId = "";
  String role = "";

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      sessionId = prefs.getString('sessionId') ?? '';
      role = prefs.getString('role') ?? '';
      currentUrl = "${Constants.rootUrl}/index.php?view=dashboard&session_id=$sessionId&from_app=1";
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  // Dashboard menus and submenus
  List<Map<String, dynamic>> getMenus() {
    if (role == 'gym_owner') {
      return [
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
        {
          'title': 'Logout',
          'icon': Icons.logout,
          'submenus': {},
        },
      ];
    }
    else if (role == 'trainer')
    {
      return [
        {
          'title': 'My Zone',
          'icon': Icons.location_city,
          'submenus': {
            'My Schedule': 'trainer_schedules',
          },
        },
        {
          'title': 'Students',
          'icon': Icons.person,
          'submenus': {
            'All Students': 'students',
            'Student Attendances': 'student_attendance',
            'Attendance Register': 'attendance_register',
            'Assign Workout': 'student_workouts',
            'Assign Diet': 'student_diets',
            'Progress Tracking': 'student_progress',
            'Achievements': 'student_achievements',
          },
        },
        {
          'title': 'Logout',
          'icon': Icons.logout,
          'submenus': {},
        },
      ];

    }
    else if (role == 'student')
    {
      return [
        {
          'title': 'My TODOS',
          'icon': Icons.location_city,
          'submenus': {
            'Workout Plans': 'student_workouts',
            'Diet Plans': 'student_diets',
          },
        },
        {
          'title': 'Membership',
          'icon': Icons.person,
          'submenus': {
            'My Membership': 'subscriptions',
            'Invoice List': 'invoice_list',
            'Payments': 'payments',
            'Feedback': 'feedbacks',
          },
        },
        {
          'title': 'Scanner',
          'icon': Icons.qr_code_scanner,
          'submenus': {
            'Scan QR': 'scan_qr', // special identifier for scanner
          },
        },
        {
          'title': 'Logout',
          'icon': Icons.logout,
          'submenus': {},
        },
      ];

    }

    return [];
  }
  

  // Update WebView URL
 void _openMenu(String title, String viewName) async {
  Navigator.pop(context); // close drawer first

  if (viewName == 'scan_qr') {
    // 🧭 Open scanner and wait for result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScannerPage()),
    );

    if (result != null && result is String) 
    {
      // 🧠 Check if it's a valid URL
      final isUrl = Uri.tryParse(result)?.hasAbsolutePath ?? false;

      if (isUrl) {
        setState(() {
          currentTitle = "Scanned Link";
          currentUrl = result.contains("http")
              ? result
              : "https://$result"; // ensure it’s absolute
        });
      }
      else {
        // 📢 Show the scanned text in a dialog
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('QR Scan Result'),
              content: Text(result),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  } else {
    // Open WebView for other views
    setState(() {
      currentTitle = title;
      currentUrl =
          "${Constants.rootUrl}/index.php?view=$viewName&session_id=$sessionId&from_app=1";
    });
  }
}


  @override
  Widget build(BuildContext context) {
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
                    leading: const Icon(Icons.arrow_right, color: Colors.black54),
                    title: Text(
                      subTitle,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () => _openMenu(subTitle, viewName),
                  );
                }).toList(),
              );
            }).toList(),
          ],
        ),
      ),
      body: WebViewPage(
        key: ValueKey(currentUrl), // ⚡ important: forces rebuild on URL change
        title: currentTitle,
        url: currentUrl,
        sessionId: sessionId,
      ),
    );
  }
}
