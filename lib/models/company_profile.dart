class CompanyProfile {
  final String symbol;
  final String name;
  final String description;
  final String exchange;
  final String currency;
  final String country;
  final String sector;
  final String industry;
  final String address;
  final String fiscalYearEnd;
  final String latestQuarter;
  final double marketCapitalization;
  final double ebitda;
  final double peRatio;
  final double pegRatio;
  final double bookValue;
  final double dividendPerShare;
  final double dividendYield;
  final double eps;
  final double revenuePerShareTTM;
  final double profitMargin;
  final double operatingMarginTTM;
  final double returnOnAssetsTTM;
  final double returnOnEquityTTM;
  final double revenueTTM;
  final double grossProfitTTM;
  final double dilutedEPSTTM;
  final double quarterlyEarningsGrowthYOY;
  final double quarterlyRevenueGrowthYOY;
  final double analystTargetPrice;
  final double trailingPE;
  final double forwardPE;
  final double priceToSalesRatioTTM;
  final double priceToBookRatio;
  final double evToRevenue;
  final double evToEBITDA;
  final double beta;
  final double fiftyTwoWeekHigh;
  final double fiftyTwoWeekLow;
  final double fiftyDayMovingAverage;
  final double twoHundredDayMovingAverage;
  final int sharesOutstanding;
  final int sharesFloat;
  final int sharesShort;
  final int sharesShortPriorMonth;
  final double shortRatio;
  final double shortPercentOutstanding;
  final double shortPercentFloat;
  final double percentInsiders;
  final double percentInstitutions;
  final double forwardAnnualDividendRate;
  final double forwardAnnualDividendYield;
  final double payoutRatio;
  final String dividendDate;
  final String exDividendDate;
  final String lastSplitFactor;
  final String lastSplitDate;

  CompanyProfile({
    required this.symbol,
    required this.name,
    required this.description,
    required this.exchange,
    required this.currency,
    required this.country,
    required this.sector,
    required this.industry,
    required this.address,
    required this.fiscalYearEnd,
    required this.latestQuarter,
    required this.marketCapitalization,
    required this.ebitda,
    required this.peRatio,
    required this.pegRatio,
    required this.bookValue,
    required this.dividendPerShare,
    required this.dividendYield,
    required this.eps,
    required this.revenuePerShareTTM,
    required this.profitMargin,
    required this.operatingMarginTTM,
    required this.returnOnAssetsTTM,
    required this.returnOnEquityTTM,
    required this.revenueTTM,
    required this.grossProfitTTM,
    required this.dilutedEPSTTM,
    required this.quarterlyEarningsGrowthYOY,
    required this.quarterlyRevenueGrowthYOY,
    required this.analystTargetPrice,
    required this.trailingPE,
    required this.forwardPE,
    required this.priceToSalesRatioTTM,
    required this.priceToBookRatio,
    required this.evToRevenue,
    required this.evToEBITDA,
    required this.beta,
    required this.fiftyTwoWeekHigh,
    required this.fiftyTwoWeekLow,
    required this.fiftyDayMovingAverage,
    required this.twoHundredDayMovingAverage,
    required this.sharesOutstanding,
    required this.sharesFloat,
    required this.sharesShort,
    required this.sharesShortPriorMonth,
    required this.shortRatio,
    required this.shortPercentOutstanding,
    required this.shortPercentFloat,
    required this.percentInsiders,
    required this.percentInstitutions,
    required this.forwardAnnualDividendRate,
    required this.forwardAnnualDividendYield,
    required this.payoutRatio,
    required this.dividendDate,
    required this.exDividendDate,
    required this.lastSplitFactor,
    required this.lastSplitDate,
  });

  factory CompanyProfile.fromJson(Map<String, dynamic> json) {
    return CompanyProfile(
      symbol: json['Symbol'] ?? '',
      name: json['Name'] ?? '',
      description: json['Description'] ?? '',
      exchange: json['Exchange'] ?? '',
      currency: json['Currency'] ?? '',
      country: json['Country'] ?? '',
      sector: json['Sector'] ?? '',
      industry: json['Industry'] ?? '',
      address: json['Address'] ?? '',
      fiscalYearEnd: json['FiscalYearEnd'] ?? '',
      latestQuarter: json['LatestQuarter'] ?? '',
      marketCapitalization: double.tryParse(json['MarketCapitalization'] ?? '0') ?? 0,
      ebitda: double.tryParse(json['EBITDA'] ?? '0') ?? 0,
      peRatio: double.tryParse(json['PERatio'] ?? '0') ?? 0,
      pegRatio: double.tryParse(json['PEGRatio'] ?? '0') ?? 0,
      bookValue: double.tryParse(json['BookValue'] ?? '0') ?? 0,
      dividendPerShare: double.tryParse(json['DividendPerShare'] ?? '0') ?? 0,
      dividendYield: double.tryParse(json['DividendYield'] ?? '0') ?? 0,
      eps: double.tryParse(json['EPS'] ?? '0') ?? 0,
      revenuePerShareTTM: double.tryParse(json['RevenuePerShareTTM'] ?? '0') ?? 0,
      profitMargin: double.tryParse(json['ProfitMargin'] ?? '0') ?? 0,
      operatingMarginTTM: double.tryParse(json['OperatingMarginTTM'] ?? '0') ?? 0,
      returnOnAssetsTTM: double.tryParse(json['ReturnOnAssetsTTM'] ?? '0') ?? 0,
      returnOnEquityTTM: double.tryParse(json['ReturnOnEquityTTM'] ?? '0') ?? 0,
      revenueTTM: double.tryParse(json['RevenueTTM'] ?? '0') ?? 0,
      grossProfitTTM: double.tryParse(json['GrossProfitTTM'] ?? '0') ?? 0,
      dilutedEPSTTM: double.tryParse(json['DilutedEPSTTM'] ?? '0') ?? 0,
      quarterlyEarningsGrowthYOY: double.tryParse(json['QuarterlyEarningsGrowthYOY'] ?? '0') ?? 0,
      quarterlyRevenueGrowthYOY: double.tryParse(json['QuarterlyRevenueGrowthYOY'] ?? '0') ?? 0,
      analystTargetPrice: double.tryParse(json['AnalystTargetPrice'] ?? '0') ?? 0,
      trailingPE: double.tryParse(json['TrailingPE'] ?? '0') ?? 0,
      forwardPE: double.tryParse(json['ForwardPE'] ?? '0') ?? 0,
      priceToSalesRatioTTM: double.tryParse(json['PriceToSalesRatioTTM'] ?? '0') ?? 0,
      priceToBookRatio: double.tryParse(json['PriceToBookRatio'] ?? '0') ?? 0,
      evToRevenue: double.tryParse(json['EVToRevenue'] ?? '0') ?? 0,
      evToEBITDA: double.tryParse(json['EVToEBITDA'] ?? '0') ?? 0,
      beta: double.tryParse(json['Beta'] ?? '0') ?? 0,
      fiftyTwoWeekHigh: double.tryParse(json['52WeekHigh'] ?? '0') ?? 0,
      fiftyTwoWeekLow: double.tryParse(json['52WeekLow'] ?? '0') ?? 0,
      fiftyDayMovingAverage: double.tryParse(json['50DayMovingAverage'] ?? '0') ?? 0,
      twoHundredDayMovingAverage: double.tryParse(json['200DayMovingAverage'] ?? '0') ?? 0,
      sharesOutstanding: int.tryParse(json['SharesOutstanding'] ?? '0') ?? 0,
      sharesFloat: int.tryParse(json['SharesFloat'] ?? '0') ?? 0,
      sharesShort: int.tryParse(json['SharesShort'] ?? '0') ?? 0,
      sharesShortPriorMonth: int.tryParse(json['SharesShortPriorMonth'] ?? '0') ?? 0,
      shortRatio: double.tryParse(json['ShortRatio'] ?? '0') ?? 0,
      shortPercentOutstanding: double.tryParse(json['ShortPercentOutstanding'] ?? '0') ?? 0,
      shortPercentFloat: double.tryParse(json['ShortPercentFloat'] ?? '0') ?? 0,
      percentInsiders: double.tryParse(json['PercentInsiders'] ?? '0') ?? 0,
      percentInstitutions: double.tryParse(json['PercentInstitutions'] ?? '0') ?? 0,
      forwardAnnualDividendRate: double.tryParse(json['ForwardAnnualDividendRate'] ?? '0') ?? 0,
      forwardAnnualDividendYield: double.tryParse(json['ForwardAnnualDividendYield'] ?? '0') ?? 0,
      payoutRatio: double.tryParse(json['PayoutRatio'] ?? '0') ?? 0,
      dividendDate: json['DividendDate'] ?? '',
      exDividendDate: json['ExDividendDate'] ?? '',
      lastSplitFactor: json['LastSplitFactor'] ?? '',
      lastSplitDate: json['LastSplitDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Symbol': symbol,
      'Name': name,
      'Description': description,
      'Exchange': exchange,
      'Currency': currency,
      'Country': country,
      'Sector': sector,
      'Industry': industry,
      'Address': address,
      'FiscalYearEnd': fiscalYearEnd,
      'LatestQuarter': latestQuarter,
      'MarketCapitalization': marketCapitalization,
      'EBITDA': ebitda,
      'PERatio': peRatio,
      'PEGRatio': pegRatio,
      'BookValue': bookValue,
      'DividendPerShare': dividendPerShare,
      'DividendYield': dividendYield,
      'EPS': eps,
      'RevenuePerShareTTM': revenuePerShareTTM,
      'ProfitMargin': profitMargin,
      'OperatingMarginTTM': operatingMarginTTM,
      'ReturnOnAssetsTTM': returnOnAssetsTTM,
      'ReturnOnEquityTTM': returnOnEquityTTM,
      'RevenueTTM': revenueTTM,
      'GrossProfitTTM': grossProfitTTM,
      'DilutedEPSTTM': dilutedEPSTTM,
      'QuarterlyEarningsGrowthYOY': quarterlyEarningsGrowthYOY,
      'QuarterlyRevenueGrowthYOY': quarterlyRevenueGrowthYOY,
      'AnalystTargetPrice': analystTargetPrice,
      'TrailingPE': trailingPE,
      'ForwardPE': forwardPE,
      'PriceToSalesRatioTTM': priceToSalesRatioTTM,
      'PriceToBookRatio': priceToBookRatio,
      'EVToRevenue': evToRevenue,
      'EVToEBITDA': evToEBITDA,
      'Beta': beta,
      '52WeekHigh': fiftyTwoWeekHigh,
      '52WeekLow': fiftyTwoWeekLow,
      '50DayMovingAverage': fiftyDayMovingAverage,
      '200DayMovingAverage': twoHundredDayMovingAverage,
      'SharesOutstanding': sharesOutstanding,
      'SharesFloat': sharesFloat,
      'SharesShort': sharesShort,
      'SharesShortPriorMonth': sharesShortPriorMonth,
      'ShortRatio': shortRatio,
      'ShortPercentOutstanding': shortPercentOutstanding,
      'ShortPercentFloat': shortPercentFloat,
      'PercentInsiders': percentInsiders,
      'PercentInstitutions': percentInstitutions,
      'ForwardAnnualDividendRate': forwardAnnualDividendRate,
      'ForwardAnnualDividendYield': forwardAnnualDividendYield,
      'PayoutRatio': payoutRatio,
      'DividendDate': dividendDate,
      'ExDividendDate': exDividendDate,
      'LastSplitFactor': lastSplitFactor,
      'LastSplitDate': lastSplitDate,
    };
  }
}
