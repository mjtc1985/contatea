import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/level.dart';
import '../widgets/arasaac_picker.dart';

class SettingsScreen extends StatefulWidget {
  final GameLevel level;
  const SettingsScreen({super.key, required this.level});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ImagePicker _picker = ImagePicker();
  late int _targetCount;

  @override
  void initState() {
    super.initState();
    _targetCount = widget.level.targetCount;
  }

  void _openArasaacPicker({required bool isReward}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ArasaacPicker(
        title: isReward ? 'Seleccionar Premio' : 'Seleccionar Objeto',
        onSelected: (picto) {
          setState(() {
            if (isReward) {
              widget.level.rewardPictogramUrl = picto.imageUrl;
              widget.level.rewardImagePath = null;
            } else {
              widget.level.selectedPictogramUrl = picto.imageUrl;
              widget.level.query = picto.keywords.first;
            }
          });
        },
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        widget.level.rewardImagePath = image.path;
        widget.level.rewardPictogramUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Ajustes: ${widget.level.title}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Objetivo'),
          _buildCard(
            child: ListTile(
              title: const Text('Cantidad de elementos'),
              subtitle: Text('Máximo de elementos a contar en este nivel'),
              trailing: DropdownButton<int>(
                value: _targetCount,
                items: List.generate(10, (i) => i + 1).map((val) => 
                  DropdownMenuItem(value: val, child: Text('$val', style: const TextStyle(fontSize: 18)))
                ).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _targetCount = val;
                      widget.level.targetCount = val;
                    });
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 20),
          _buildSectionTitle('Elemento a Contar'),
          _buildCard(
            child: Column(
              children: [
                if (widget.level.selectedPictogramUrl != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(widget.level.selectedPictogramUrl!, width: 100, height: 100),
                  ),
                ListTile(
                  leading: const Icon(Icons.search, color: Colors.blue),
                  title: Text(widget.level.selectedPictogramUrl == null ? 'Seleccionar Pictograma' : 'Cambiar Pictograma'),
                  subtitle: Text('Actual: ${widget.level.query}'),
                  onTap: () => _openArasaacPicker(isReward: false),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _buildSectionTitle('Premio Final'),
          _buildCard(
            child: Column(
              children: [
                if (widget.level.rewardPictogramUrl != null || widget.level.rewardImagePath != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: widget.level.rewardImagePath != null
                        ? Image.file(File(widget.level.rewardImagePath!), width: 100, height: 100)
                        : Image.network(widget.level.rewardPictogramUrl!, width: 100, height: 100),
                  ),
                ListTile(
                  leading: const Icon(Icons.emoji_events, color: Colors.orange),
                  title: const Text('Elegir de ARASAAC'),
                  onTap: () => _openArasaacPicker(isReward: true),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.green),
                  title: const Text('Usar mi propia foto'),
                  onTap: _pickImage,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('Confirmar y Guardar', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }
}
