enum GameType { counting, association }

class AssociationPair {
  String word;
  String? imageUrl;
  String? localImagePath;

  AssociationPair({
    required this.word,
    this.imageUrl,
    this.localImagePath,
  });

  Map<String, dynamic> toJson() => {
    'word': word,
    'imageUrl': imageUrl,
    'localImagePath': localImagePath,
  };

  factory AssociationPair.fromJson(Map<String, dynamic> json) => AssociationPair(
    word: json['word'],
    imageUrl: json['imageUrl'],
    localImagePath: json['localImagePath'],
  );
}

class GameLevel {
  final String title;
  final GameType type;
  
  // Configuración de conteo
  int targetCount;
  int totalRounds;
  String query;
  String? selectedPictogramUrl;
  String? selectedLocalImagePath;
  
  // Configuración de asociación
  List<AssociationPair> pairs;
  int optionsCount; // Cantidad de botones de palabras (ej: 3)
  
  // Configuración de premio
  String rewardQuery;
  String? rewardPictogramUrl;
  String? rewardImagePath;

  GameLevel({
    required this.title,
    this.type = GameType.counting,
    this.targetCount = 5,
    this.totalRounds = 3,
    this.query = 'manzana',
    this.pairs = const [],
    this.optionsCount = 3,
    this.rewardQuery = 'caramelo',
    this.selectedPictogramUrl,
    this.selectedLocalImagePath,
    this.rewardPictogramUrl,
    this.rewardImagePath,
  });
}

// Niveles base: uno de cada tipo
final List<GameLevel> levels = [
  GameLevel(
    title: 'Aprender a Contar', 
    type: GameType.counting,
  ),
  GameLevel(
    title: 'Aprender Palabras', 
    type: GameType.association,
    pairs: [
      AssociationPair(word: 'PERRO', imageUrl: 'https://static.arasaac.org/pictograms/2558/2558_300.png'),
      AssociationPair(word: 'GATO', imageUrl: 'https://static.arasaac.org/pictograms/2560/2560_300.png'),
      AssociationPair(word: 'POLLO', imageUrl: 'https://static.arasaac.org/pictograms/2565/2565_300.png'),
    ],
  ),
];
