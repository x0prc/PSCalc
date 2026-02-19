import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../application/settings_controller.dart';
import '../domain/domain.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: const Text('PSCalc Settings',
            style: TextStyle(fontFamily: 'DMBezel')),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // INPUT MODE
          Card(
            color: Colors.grey.shade800,
            child: SwitchListTile(
              title: const Text('RPN Mode',
                  style: TextStyle(fontFamily: 'DMSansMono')),
              subtitle: const Text('Reverse Polish Notation'),
              value: context.watch<SettingsController>().inputMode == 'rpn',
              onChanged: (value) => context
                  .read<SettingsController>()
                  .setInputMode(value ? 'rpn' : 'algebraic'),
              secondary: const Icon(Icons.calculate, color: Colors.orange),
            ),
          ),

          const SizedBox(height: 16),

          // NUMBER FORMATTING
          Card(
            color: Colors.grey.shade800,
            child: SwitchListTile(
              title: const Text('Lakh/Crore',
                  style: TextStyle(fontFamily: 'DMSansMono')),
              subtitle: const Text('12,34,56,789 format'),
              value: context.watch<SettingsController>().useLakhCrore,
              onChanged: context.read<SettingsController>().setLakhCrore,
              secondary:
                  const Icon(Icons.format_list_numbered, color: Colors.green),
            ),
          ),

          Card(
            color: Colors.grey.shade800,
            child: SwitchListTile(
              title: const Text('Stack Preview',
                  style: TextStyle(fontFamily: 'DMSansMono')),
              subtitle: const Text('Show Y Z T registers'),
              value: context.watch<SettingsController>().showStackPreview,
              onChanged: (_) =>
                  context.read<SettingsController>().toggleStackPreview(),
              secondary: const Icon(Icons.layers, color: Colors.blue),
            ),
          ),

          const SizedBox(height: 24),

          // DOMAIN MANAGEMENT
          const Text(
            'Domain Order',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'DMBezel',
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: (oldIndex, newIndex) {
              final controller = context.read<SettingsController>();
              final newOrder = List<String>.from(controller.domainOrder);
              if (newIndex > oldIndex) newIndex--;
              final item = newOrder.removeAt(oldIndex);
              newOrder.insert(newIndex, item);
              controller.reorderDomains(newOrder);
            },
            children:
                context.watch<SettingsController>().domainOrder.map((domainId) {
              final domain = allDomains.firstWhere((d) => d.id == domainId);
              return Card(
                key: ValueKey(domainId),
                color: Colors.grey.shade800,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.shade600,
                    child: Text(domain.shortLabel,
                        style: const TextStyle(fontFamily: 'DMBezel')),
                  ),
                  title: Text(domain.name,
                      style: const TextStyle(fontFamily: 'DMSansMono')),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.arrow_upward, color: Colors.green),
                        onPressed: () => context
                            .read<SettingsController>()
                            .moveDomainUp(domainId),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_downward,
                            color: Colors.orange),
                        onPressed: () => context
                            .read<SettingsController>()
                            .moveDomainDown(domainId),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
