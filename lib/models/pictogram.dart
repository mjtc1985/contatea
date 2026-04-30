class Pictogram {
  final int id;
  final List<String> keywords;

  Pictogram({required this.id, required this.keywords});

  factory Pictogram.fromJson(Map<String, dynamic> json) {
    var keywordList = (json['keywords'] as List)
        .map((k) => k['keyword'] as String)
        .toList();
    return Pictogram(
      id: json['_id'],
      keywords: keywordList,
    );
  }

  String get imageUrl => 'https://static.arasaac.org/pictograms/$id/${id}_300.png';
}
