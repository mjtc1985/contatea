class GameLevel {
  final String title;
  
  // Configuración de conteo
  int targetCount;
  String query;
  String? selectedPictogramUrl; // URL fija si se selecciona manualmente
  
  // Configuración de premio
  String rewardQuery;
  String? rewardPictogramUrl; // URL fija si se selecciona manualmente
  String? rewardImagePath; // Foto local

  GameLevel({
    required this.title,
    required this.targetCount,
    required this.query,
    this.rewardQuery = 'caramelo',
    this.selectedPictogramUrl,
    this.rewardPictogramUrl,
    this.rewardImagePath,
  });
}

// Un solo nivel base que el tutor configurará a su gusto
final List<GameLevel> levels = [
  GameLevel(
    title: 'Juego de Contar', 
    targetCount: 5, 
    query: 'manzana',
  ),
];
