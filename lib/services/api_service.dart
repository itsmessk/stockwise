import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stockwise/constants/api_constants.dart';
import 'package:stockwise/models/stock.dart';
import 'package:stockwise/models/company_profile.dart';
import 'package:stockwise/models/news.dart';
import 'package:stockwise/models/forex.dart';
import 'package:stockwise/models/historical_data.dart';
import 'package:intl/intl.dart';

class ApiService {
  // Fetch live stock prices
  Future<List<Stock>> fetchLiveStockPrices(List<String> symbols) async {
    List<Stock> stocks = [];
    
    try {
      // Alpha Vantage has a limit on API calls, so we need to fetch each symbol individually
      for (String symbol in symbols) {
        final response = await http.get(
          Uri.parse('${ApiConstants.baseUrl}?function=${ApiConstants.quoteEndpoint}&symbol=$symbol&apikey=${ApiConstants.apiKey}')
        );
        
        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          
          // Check if the API returned a successful response
          if (jsonResponse.containsKey('Global Quote') && jsonResponse['Global Quote'] != null) {
            final Map<String, dynamic> quoteData = jsonResponse['Global Quote'];
            
            if (quoteData.isNotEmpty) {
              final stock = Stock(
                symbol: symbol,
                name: symbol, // Alpha Vantage doesn't provide name in quote endpoint
                price: double.tryParse(quoteData['05. price'] ?? '0') ?? 0.0,
                change: double.tryParse(quoteData['09. change'] ?? '0') ?? 0.0,
                percentChange: double.tryParse(quoteData['10. change percent']?.replaceAll('%', '') ?? '0') ?? 0.0,
                volume: int.tryParse(quoteData['06. volume'] ?? '0') ?? 0,
                currency: 'USD', // Alpha Vantage defaults to USD
                exchange: quoteData['01. symbol']?.split('.').last ?? '',
                lastUpdated: DateTime.now(),
              );
              
              stocks.add(stock);
              
              // Add a small delay to avoid hitting API rate limits
              await Future.delayed(const Duration(milliseconds: 500));
            }
          }
        } else {
          print('Failed to load stock price for $symbol: ${response.statusCode}');
        }
      }
      
      return stocks;
    } catch (e) {
      print('Error fetching live stock prices: $e');
      return []; // Return empty list instead of throwing to prevent app crashes
    }
  }

  // Fetch historical stock data
  Future<List<HistoricalData>> fetchHistoricalData(String symbol, {String? dateFrom, String? dateTo}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}?function=${ApiConstants.timeSeriesDaily}&symbol=$symbol&outputsize=compact&apikey=${ApiConstants.apiKey}')
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse.containsKey('Time Series (Daily)')) {
          final Map<String, dynamic> timeSeries = jsonResponse['Time Series (Daily)'];
          List<HistoricalData> historicalDataList = [];
          
          timeSeries.forEach((date, data) {
            final historicalData = HistoricalData(
              date: DateTime.parse(date),
              open: double.tryParse(data['1. open'] ?? '0') ?? 0.0,
              high: double.tryParse(data['2. high'] ?? '0') ?? 0.0,
              low: double.tryParse(data['3. low'] ?? '0') ?? 0.0,
              close: double.tryParse(data['4. close'] ?? '0') ?? 0.0,
              volume: int.tryParse(data['5. volume'] ?? '0') ?? 0,
            );
            
            // Filter by date if provided
            if (dateFrom != null && dateTo != null) {
              final fromDate = DateTime.parse(dateFrom);
              final toDate = DateTime.parse(dateTo);
              
              if (historicalData.date.isAfter(fromDate) && 
                  historicalData.date.isBefore(toDate)) {
                historicalDataList.add(historicalData);
              }
            } else {
              historicalDataList.add(historicalData);
            }
          });
          
          // Sort by date (newest first)
          historicalDataList.sort((a, b) => b.date.compareTo(a.date));
          return historicalDataList;
        }
      }
      
      return [];
    } catch (e) {
      print('Error fetching historical data: $e');
      return []; // Return empty list instead of throwing
    }
  }

  // Fetch company profile
  Future<CompanyProfile?> fetchCompanyProfile(String symbol) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}?function=${ApiConstants.companyOverview}&symbol=$symbol&apikey=${ApiConstants.apiKey}')
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        // Check if the response contains data
        if (jsonResponse.containsKey('Symbol') && jsonResponse['Symbol'] != null) {
          return CompanyProfile(
            symbol: jsonResponse['Symbol'] ?? '',
            name: jsonResponse['Name'] ?? '',
            exchange: jsonResponse['Exchange'] ?? '',
            industry: jsonResponse['Industry'] ?? '',
            sector: jsonResponse['Sector'] ?? '',
            description: jsonResponse['Description'] ?? '',
            employees: int.tryParse(jsonResponse['FullTimeEmployees'] ?? '0') ?? 0,
            marketCap: double.tryParse(jsonResponse['MarketCapitalization'] ?? '0') ?? 0.0,
            peRatio: double.tryParse(jsonResponse['PERatio'] ?? '0') ?? 0.0,
            dividendYield: double.tryParse(jsonResponse['DividendYield'] ?? '0') ?? 0.0,
            website: jsonResponse['Website'] ?? '',
            logoUrl: '', // Alpha Vantage doesn't provide logo URLs
            country: jsonResponse['Country'] ?? '',
            ceo: jsonResponse['CEO'] ?? '',
          );
        }
      }
      
      return null;
    } catch (e) {
      print('Error fetching company profile: $e');
      return null; // Return null instead of throwing
    }
  }

  // Fetch market news
  Future<List<News>> fetchMarketNews({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}?function=${ApiConstants.news}&tickers=MARKET&limit=$limit&apikey=${ApiConstants.apiKey}')
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse.containsKey('feed') && jsonResponse['feed'] is List) {
          final List<dynamic> feed = jsonResponse['feed'];
          List<News> newsList = [];
          
          for (var item in feed.take(limit)) {
            final news = News(
              id: item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
              title: item['title'] ?? '',
              summary: item['summary'] ?? '',
              url: item['url'] ?? '',
              source: item['source'] ?? '',
              imageUrl: item['banner_image'] ?? '',
              publishedAt: DateTime.tryParse(item['time_published'] ?? '') ?? DateTime.now(),
              symbols: (item['tickers'] as List?)?.cast<String>() ?? [],
              sentiment: item['overall_sentiment_score']?.toString() ?? '0',
            );
            
            newsList.add(news);
          }
          
          return newsList;
        }
      }
      
      return [];
    } catch (e) {
      print('Error fetching market news: $e');
      return []; // Return empty list instead of throwing
    }
  }

  // Fetch forex rates
  Future<List<Forex>> fetchForexRates() async {
    try {
      List<Forex> forexList = [];
      final List<List<String>> pairs = [
        ['EUR', 'USD'],
        ['USD', 'JPY'],
        ['GBP', 'USD'],
        ['USD', 'CAD'],
        ['AUD', 'USD']
      ];
      
      for (var pair in pairs) {
        final fromCurrency = pair[0];
        final toCurrency = pair[1];
        
        final response = await http.get(
          Uri.parse('${ApiConstants.baseUrl}?function=${ApiConstants.forexRate}&from_currency=$fromCurrency&to_currency=$toCurrency&apikey=${ApiConstants.apiKey}')
        );
        
        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          
          if (jsonResponse.containsKey('Realtime Currency Exchange Rate')) {
            final Map<String, dynamic> rateData = jsonResponse['Realtime Currency Exchange Rate'];
            
            final forex = Forex(
              id: '$fromCurrency$toCurrency',
              baseCurrency: fromCurrency,
              quoteCurrency: toCurrency,
              exchangeRate: double.tryParse(rateData['5. Exchange Rate'] ?? '0') ?? 0.0,
              bidPrice: double.tryParse(rateData['8. Bid Price'] ?? '0') ?? 0.0,
              askPrice: double.tryParse(rateData['9. Ask Price'] ?? '0') ?? 0.0,
              timestamp: DateTime.now(),
            );
            
            forexList.add(forex);
          }
          
          // Add a small delay to avoid hitting API rate limits
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
      
      return forexList;
    } catch (e) {
      print('Error fetching forex rates: $e');
      return []; // Return empty list instead of throwing
    }
  }
  
  // Search stocks
  Future<List<Stock>> searchStocks(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }
      
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}?function=${ApiConstants.searchEndpoint}&keywords=$query&apikey=${ApiConstants.apiKey}')
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse.containsKey('bestMatches') && jsonResponse['bestMatches'] is List) {
          final List<dynamic> matches = jsonResponse['bestMatches'];
          List<Stock> stocks = [];
          
          for (var item in matches) {
            final stock = Stock(
              symbol: item['1. symbol'] ?? '',
              name: item['2. name'] ?? '',
              price: 0.0, // Price not available in search results
              change: 0.0,
              percentChange: 0.0,
              volume: 0,
              currency: item['8. currency'] ?? 'USD',
              exchange: item['4. region'] ?? '',
              lastUpdated: DateTime.now(),
            );
            
            stocks.add(stock);
          }
          
          return stocks;
        }
      }
      
      return [];
    } catch (e) {
      print('Error searching stocks: $e');
      return []; // Return empty list instead of throwing
    }
  }
}
