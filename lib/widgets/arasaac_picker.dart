import 'package:flutter/material.dart';
import '../models/pictogram.dart';
import '../services/arasaac_service.dart';

class ArasaacPicker extends StatefulWidget {
  final String title;
  final Function(Pictogram) onSelected;

  const ArasaacPicker({super.key, required this.title, required this.onSelected});

  @override
  State<ArasaacPicker> createState() => _ArasaacPickerState();
}

class _ArasaacPickerState extends State<ArasaacPicker> {
  final ArasaacService _arasaacService = ArasaacService();
  final TextEditingController _searchController = TextEditingController();
  List<Pictogram> _results = [];
  bool _isLoading = false;

  void _search() async {
    if (_searchController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      final results = await _arasaacService.searchPictograms(_searchController.text);
      setState(() => _results = results);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar pictograma...',
              suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? const Center(child: Text('No hay resultados'))
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final picto = _results[index];
                          return GestureDetector(
                            onTap: () {
                              widget.onSelected(picto);
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(picto.imageUrl),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
