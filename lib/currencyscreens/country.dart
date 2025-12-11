class Country {
  final String name;
  final String officialName;
  final List<String> currencies;
  final String currencyCode;
  final String currencyName;
  final String currencySymbol;
  final String flag;
  final String region;
  final String subregion;
  final int population;
  final String capital;

  Country({
    required this.name,
    required this.officialName,
    required this.currencies,
    required this.currencyCode,
    required this.currencyName,
    required this.currencySymbol,
    required this.flag,
    required this.region,
    required this.subregion,
    required this.population,
    required this.capital,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    // Extract currency information
    final currenciesJson = json['currencies'] as Map<String, dynamic>?;
    String currencyCode = '';
    String currencyName = '';
    List<String> currencyList = [];

    String currencySymbol = '';
    if (currenciesJson != null && currenciesJson.isNotEmpty) {
      currencyList = currenciesJson.keys.toList();
      currencyCode = currencyList.first;
      final currencyInfo =
          currenciesJson[currencyCode] as Map<String, dynamic>?;
      currencyName = currencyInfo?['name'] as String? ?? currencyCode;
      currencySymbol = currencyInfo?['symbol'] as String? ?? '';
    }

    // Extract names
    final names = json['name'] as Map<String, dynamic>? ?? {};
    final commonName = names['common'] as String? ?? '';
    final officialName = names['official'] as String? ?? commonName;

    // Extract flag - prefer PNG flag, fallback to emoji
    String flag = '';
    if (json['flags'] != null) {
      final flags = json['flags'] as Map<String, dynamic>?;
      flag = flags?['png'] as String? ?? flags?['emoji'] as String? ?? '';
    } else if (json['flag'] != null) {
      flag = json['flag'].toString();
    }

    // Extract capital
    final capitals = json['capital'] as List<dynamic>?;
    final capital = capitals?.isNotEmpty == true
        ? capitals![0].toString()
        : 'N/A';

    return Country(
      name: commonName,
      officialName: officialName,
      currencies: currencyList,
      currencyCode: currencyCode,
      currencyName: currencyName,
      currencySymbol: currencySymbol,
      flag: flag,
      region: json['region'] as String? ?? '',
      subregion: json['subregion'] as String? ?? '',
      population: json['population'] as int? ?? 0,
      capital: capital,
    );
  }

  /// Check if flag is a URL (PNG/SVG) or emoji
  bool get isFlagUrl =>
      flag.startsWith('http://') || flag.startsWith('https://');

  @override
  String toString() {
    return '$name ($currencyCode)';
  }
}
