import 'package:flutter/material.dart';
import '../models/selected_item.dart';
import '../widgets/app_drawer.dart';
import '../widgets/home_body.dart';
import '../screens/create_dialogs.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SelectedItem? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ddxHabits'),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        selected: _selected,
        onSelect: (item) => setState(() => _selected = item),
        onDelete: (item) => setState(() {
          if (_selected?.type == item.type && _selected?.index == item.index) {
            _selected = null;
          }
        }),
      ),
      body: HomeBody(selected: _selected),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateChoiceDialog(
          context,
          (item) => setState(() => _selected = item),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
