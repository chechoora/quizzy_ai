import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 1, // Number of settings items
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      itemBuilder: (BuildContext context, int index) {
        // This function returns a ListTile for each setting item
        return ListTile(
          title: Text(
            'Premium Settings',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          leading: Icon(
            Icons.workspace_premium,
            color: Theme.of(context).colorScheme.primary,
          ), // You can change the icon as per your requirement
          onTap: () {
            context.push(
              '/premiumSettings',
            );
          },
        );
      },
    );
  }
}
