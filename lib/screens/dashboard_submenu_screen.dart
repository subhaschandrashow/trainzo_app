import 'package:flutter/material.dart';

class DashboardSubmenuScreen extends StatelessWidget {
  final String title;
  final List<dynamic> submenus;

  const DashboardSubmenuScreen({
    super.key,
    required this.title,
    required this.submenus,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: submenus.length,
        itemBuilder: (context, index) {
          final submenu = submenus[index];
          return ListTile(
            leading: const Icon(Icons.arrow_right),
            title: Text(submenu),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Opening $submenu...")),
              );
            },
          );
        },
      ),
    );
  }
}
