import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/level.dart';
import '../widgets/arasaac_picker.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  final GameLevel level;
  const SettingsScreen({super.key, required this.level});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ImagePicker _picker = ImagePicker();
  late int _targetCount;
  late int _totalRounds;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _targetCount = widget.level.targetCount;
    _totalRounds = widget.level.totalRounds;
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

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        widget.level.rewardImagePath = image.path;
        widget.level.rewardPictogramUrl = null;
      });
    }
  }

  Future<void> _pickCountingImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        widget.level.selectedLocalImagePath = image.path;
        widget.level.selectedPictogramUrl = null;
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
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildGeneralSettings(),
              const SizedBox(height: 20),
              if (widget.level.type == GameType.counting) _buildCountingSettings(),
              if (widget.level.type == GameType.association) _buildAssociationSettings(),
              const SizedBox(height: 20),
              _buildRewardSettings(),
              const SizedBox(height: 30),
              _buildSaveButton(),
              const SizedBox(height: 10),
              _buildResetButton(),
            ],
          ),
          if (_isSaving)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 15),
                        Text('Guardando y descargando recursos...', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Objetivo'),
        _buildCard(
          child: Column(
            children: [
              if (widget.level.type == GameType.counting)
                ListTile(
                  title: const Text('Cantidad de elementos'),
                  subtitle: const Text('Máximo de elementos a contar'),
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
              if (widget.level.type == GameType.counting) const Divider(),
              ListTile(
                title: const Text('Rondas por sesión'),
                subtitle: const Text('Cuántas veces debe acertar para ganar'),
                trailing: DropdownButton<int>(
                  value: _totalRounds,
                  items: List.generate(5, (i) => i + 1).map((val) => 
                    DropdownMenuItem(value: val, child: Text('$val', style: const TextStyle(fontSize: 18)))
                  ).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _totalRounds = val;
                        widget.level.totalRounds = val;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCountingSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Elemento a Contar'),
        _buildCard(
          child: Column(
            children: [
              if (widget.level.selectedPictogramUrl != null || widget.level.selectedLocalImagePath != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: widget.level.selectedLocalImagePath != null && File(widget.level.selectedLocalImagePath!).existsSync()
                      ? Image.file(File(widget.level.selectedLocalImagePath!), width: 100, height: 100)
                      : (widget.level.selectedPictogramUrl != null ? Image.network(widget.level.selectedPictogramUrl!, width: 100, height: 100) : const SizedBox()),
                ),
              ListTile(
                leading: const Icon(Icons.search, color: Colors.blue),
                title: const Text('Elegir de ARASAAC'),
                subtitle: Text('Actual: ${widget.level.query}'),
                onTap: () => _openArasaacPicker(isReward: false),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Elegir de mi Galería'),
                onTap: () => _pickCountingImage(ImageSource.gallery),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.deepPurple),
                title: const Text('Hacer foto con la Cámara'),
                onTap: () => _pickCountingImage(ImageSource.camera),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssociationSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Pares de Palabras'),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  widget.level.pairs.add(AssociationPair(word: 'NUEVA'));
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Añadir'),
            ),
          ],
        ),
        ...widget.level.pairs.map((pair) => _buildPairCard(pair)).toList(),
      ],
    );
  }

  Widget _buildPairCard(AssociationPair pair) {
    return _buildCard(
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _openPairPictoPicker(pair),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: pair.localImagePath != null && File(pair.localImagePath!).existsSync()
                      ? Image.file(File(pair.localImagePath!), fit: BoxFit.contain)
                      : (pair.imageUrl != null 
                          ? Image.network(pair.imageUrl!, fit: BoxFit.contain)
                          : const Icon(Icons.add_a_photo, color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Palabra'),
                  controller: TextEditingController(text: pair.word),
                  onChanged: (val) => pair.word = val.toUpperCase(),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    widget.level.pairs.remove(pair);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () => _openPairPictoPicker(pair),
                icon: const Icon(Icons.search, size: 18, color: Colors.blue),
                label: const Text('ARASAAC', style: TextStyle(fontSize: 12)),
              ),
              TextButton.icon(
                onPressed: () => _pickPairImage(pair, ImageSource.gallery),
                icon: const Icon(Icons.photo_library, size: 18, color: Colors.green),
                label: const Text('Galería', style: TextStyle(fontSize: 12)),
              ),
              TextButton.icon(
                onPressed: () => _pickPairImage(pair, ImageSource.camera),
                icon: const Icon(Icons.camera_alt, size: 18, color: Colors.deepPurple),
                label: const Text('Cámara', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Premio Final'),
        _buildCard(
          child: Column(
            children: [
              if (widget.level.rewardPictogramUrl != null || widget.level.rewardImagePath != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: widget.level.rewardImagePath != null && File(widget.level.rewardImagePath!).existsSync()
                      ? Image.file(File(widget.level.rewardImagePath!), width: 100, height: 100)
                      : (widget.level.rewardPictogramUrl != null ? Image.network(widget.level.rewardPictogramUrl!, width: 100, height: 100) : const SizedBox()),
                ),
              ListTile(
                leading: const Icon(Icons.emoji_events, color: Colors.orange),
                title: const Text('Elegir de ARASAAC'),
                onTap: () => _openArasaacPicker(isReward: true),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Elegir de mi Galería'),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.deepPurple),
                title: const Text('Hacer foto con la Cámara'),
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : () async {
        setState(() => _isSaving = true);
        try {
          await StorageService().saveLevels(levels);
          if (mounted) Navigator.pop(context);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al guardar: $e')),
            );
          }
        } finally {
          if (mounted) setState(() => _isSaving = false);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: const Text('Confirmar y Guardar', style: TextStyle(fontSize: 18)),
    );
  }

  Widget _buildResetButton() {
    return TextButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Restablecer todo?'),
            content: const Text('Se perderán todos tus cambios y volverás a los ejemplos iniciales.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (widget.level.type == GameType.counting) {
                      widget.level.targetCount = 5;
                      widget.level.totalRounds = 3;
                      widget.level.query = 'manzana';
                      widget.level.selectedPictogramUrl = null;
                      widget.level.selectedLocalImagePath = null;
                    } else {
                      widget.level.pairs = [
                        AssociationPair(word: 'PERRO', imageUrl: 'https://static.arasaac.org/pictograms/2558/2558_300.png'),
                        AssociationPair(word: 'GATO', imageUrl: 'https://static.arasaac.org/pictograms/2560/2560_300.png'),
                        AssociationPair(word: 'POLLO', imageUrl: 'https://static.arasaac.org/pictograms/2565/2565_300.png'),
                      ];
                      widget.level.totalRounds = 3;
                    }
                  });
                  Navigator.pop(context);
                },
                child: const Text('Restablecer', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: const Text('Restablecer valores por defecto', style: TextStyle(color: Colors.grey)),
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

  void _openPairPictoPicker(AssociationPair pair) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ArasaacPicker(
        title: 'Seleccionar Imagen',
        onSelected: (picto) {
          setState(() {
            pair.imageUrl = picto.imageUrl;
            pair.localImagePath = null;
            pair.word = picto.keywords.first.toUpperCase();
          });
        },
      ),
    );
  }

  Future<void> _pickPairImage(AssociationPair pair, ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        pair.localImagePath = image.path;
        pair.imageUrl = null;
      });
    }
  }
}
