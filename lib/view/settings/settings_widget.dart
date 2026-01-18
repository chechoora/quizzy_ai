import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poc_ai_quiz/util/navigation.dart';

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.smart_toy),
            title: const Text('AI Validator'),
            subtitle: const Text('Configure answer validation settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.pushNamed(SettingsAIValidatorRoute().name);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('In-App Features'),
            subtitle: const Text('Manage premium features'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.pushNamed(SettingsInAppFeaturesRoute().name);
            },
          ),
        ],
      ),
    );
  }
}
