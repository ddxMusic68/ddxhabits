import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionHeader(title: 'Why this app was made'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                // TODO: Replace this with the story of why the app was made.
                'Hey my name is Jackson and I built this app off of the book Atomic Habits by James Clear. I really liked the book and the idea of building systems and specifically how visual progress can help you build habits. so I thought an app would be a great way to make visual trackers convenient and easy to use. This app is apart of ptoject "ddx" which is a bunch of apps im building to help peoples lives.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Learn more'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.web, color: AppColors.mintDark),
              title: const Text('My Project'),
              subtitle: const Text('ddxmusic68.github.io/ddxwebsite'),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () => _openUrl(context, Uri.parse('https://ddxmusic68.github.io/ddxwebsite/')),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book, color: AppColors.mintDark),
              title: const Text('James Clear'),
              subtitle: const Text('Books and articles at jamesclear.com'),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () => _openUrl(context, Uri.parse('https://jamesclear.com')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the link')),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
