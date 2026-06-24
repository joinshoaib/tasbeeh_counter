class DhikrModel {
  final String name;
  final String arabic;
  final String transliteration;
  final String meaning;
  final int defaultTarget;

  const DhikrModel({
    required this.name,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    this.defaultTarget = 33,
  });
}

final List<DhikrModel> defaultDhikrs = [
  const DhikrModel(
    name: 'SubhanAllah',
    arabic: 'سُبْحَانَ اللَّه',
    transliteration: 'SubhanAllah',
    meaning: 'Glory be to Allah',
    defaultTarget: 33,
  ),
  const DhikrModel(
    name: 'Alhamdulillah',
    arabic: 'الْحَمْدُ لِلَّه',
    transliteration: 'Alhamdulillah',
    meaning: 'Praise be to Allah',
    defaultTarget: 33,
  ),
  const DhikrModel(
    name: 'Allahu Akbar',
    arabic: 'اللَّهُ أَكْبَر',
    transliteration: 'Allahu Akbar',
    meaning: 'Allah is the Greatest',
    defaultTarget: 33,
  ),
  const DhikrModel(
    name: 'La ilaha illallah',
    arabic: 'لَا إِلَٰهَ إِلَّا اللَّه',
    transliteration: 'La ilaha illallah',
    meaning: 'There is no god but Allah',
    defaultTarget: 100,
  ),
  const DhikrModel(
    name: 'Astaghfirullah',
    arabic: 'أَسْتَغْفِرُ اللَّه',
    transliteration: 'Astaghfirullah',
    meaning: 'I seek forgiveness from Allah',
    defaultTarget: 100,
  ),
  const DhikrModel(
    name: 'SubhanAllahi wa bihamdihi',
    arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    transliteration: 'SubhanAllahi wa bihamdihi',
    meaning: 'Glory be to Allah and praise Him',
    defaultTarget: 100,
  ),
  const DhikrModel(
    name: 'SubhanAllahil Azeem',
    arabic: 'سُبْحَانَ اللَّهِ الْعَظِيم',
    transliteration: 'SubhanAllahil Azeem',
    meaning: 'Glory be to Allah, the Supreme',
    defaultTarget: 33,
  ),
  const DhikrModel(
    name: 'Allahumma salli',
    arabic: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّد',
    transliteration: 'Allahumma salli ala Muhammad',
    meaning: 'O Allah, send blessings upon Muhammad',
    defaultTarget: 100,
  ),
];
