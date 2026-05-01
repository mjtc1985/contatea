import 'package:flutter/material.dart';
import 'dart:io';
import '../models/level.dart';
import 'association_screen.dart';

class AssociationSelectionScreen extends StatefulWidget {
  final GameLevel level;

  const AssociationSelectionScreen({super.key, required this.level});

  @override
  State<AssociationSelectionScreen> createState() => _AssociationSelectionScreenState();
}

class _AssociationSelectionScreenState extends State<AssociationSelectionScreen> {
  final List<AssociationPair> _selected = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elige las palabras'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Selecciona qué palabras quieres que aparezcan hoy:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // Más columnas para que sean más pequeñas
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85, // Ajustar proporción para que no sean cuadradas gigantes
              ),
              itemCount: widget.level.pairs.length,
              itemBuilder: (context, index) {
                final pair = widget.level.pairs[index];
                final isSelected = _selected.contains(pair);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selected.remove(pair);
                      } else {
                        _selected.add(pair);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange[50] : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected ? Colors.orange : Colors.grey[200]!,
                        width: isSelected ? 4 : 2,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(color: Colors.orange.withValues(alpha: 0.2), blurRadius: 8)
                        else
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: pair.localImagePath != null && File(pair.localImagePath!).existsSync()
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(File(pair.localImagePath!), fit: BoxFit.contain),
                                  )
                                : pair.imageUrl != null
                                    ? Image.network(pair.imageUrl!, fit: BoxFit.contain)
                                    : const Icon(Icons.image, size: 50),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.orange : Colors.grey[100],
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            pair.word,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _selected.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AssociationScreen(
                              level: widget.level,
                              selectedPairs: _selected,
                            ),
                          ),
                        );
                      },
                child: Text(
                  '¡A JUGAR! (${_selected.length})',
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
