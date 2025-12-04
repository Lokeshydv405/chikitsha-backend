import 'package:flutter/material.dart';

class ThemeTestPage extends StatelessWidget {
  const ThemeTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Test Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Text Styles',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text('Body Medium Text', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),

              Text('Elevated Button'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Test Elevated Button'),
              ),
              const SizedBox(height: 16),

              Text('Outlined Button'),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Test Outlined Button'),
              ),
              const SizedBox(height: 16),

              Text('Text Button'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {},
                child: const Text('Test Text Button'),
              ),
              const SizedBox(height: 16),

              Text('Input Field'),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Enter something',
                  hintText: 'Hint text',
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),

              Text('Container with Background Color'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Text(
                  'This is a test container',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 16),

              Text('Icons Preview'),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Icon(Icons.home),
                  SizedBox(width: 8),
                  Icon(Icons.favorite),
                  SizedBox(width: 8),
                  Icon(Icons.settings),
                ],
              ),
              const SizedBox(height: 32),

              Center(
                child: Switch(
                  value: theme.brightness == Brightness.dark,
                  onChanged: (_) {
                    // Manually test with system/theme switch
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Switch system theme to test both modes.'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
