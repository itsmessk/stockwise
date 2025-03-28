class CompanyProfile {
  final String symbol;
  final String name;
  final String exchange;
  final String industry;
  final String sector;
  final String description;
  final String website;
  final String ceo;
  final String logoUrl;
  final int employees;
  final String address;
  final String city;
  final String state;
  final String country;
  final String zip;
  final double marketCap;

  CompanyProfile({
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.industry,
    required this.sector,
    required this.description,
    required this.website,
    required this.ceo,
    required this.logoUrl,
    required this.employees,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.zip,
    required this.marketCap,
  });

  factory CompanyProfile.fromJson(Map<String, dynamic> json) {
    return CompanyProfile(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      exchange: json['exchange'] ?? '',
      industry: json['industry'] ?? '',
      sector: json['sector'] ?? '',
      description: json['description'] ?? '',
      website: json['website'] ?? '',
      ceo: json['ceo'] ?? '',
      logoUrl: json['logo_url'] ?? '',
      employees: json['employees'] ?? 0,
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      zip: json['zip'] ?? '',
      marketCap: (json['market_cap'] ?? 0.0).toDouble(),
    );
  }
}
