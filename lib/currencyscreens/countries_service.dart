import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'country.dart';

class CountriesService {
  /// Fetches all countries from REST Countries API using Dio
  Future<List<Country>> getAllCountries() async {
    try {
      // REST Countries API v3.1 requires 'fields' query parameter
      // Include all fields we need: name, currencies, flags, region, subregion, population, capital
      const url =
          'https://restcountries.com/v3.1/all?fields=name,currencies,flags,region,subregion,population,capital';

      // Create a fresh Dio instance without any global interceptors or base options
      final dio = Dio();

      // Make request with minimal options - no headers that could cause 400
      final response = await dio.get(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          // Explicitly set headers to empty to avoid any defaults
          headers: {},
        ),
      );

      // Debug: Print success status
      debugPrint('✅ API Response Status: ${response.statusCode}');
      debugPrint('✅ URL: ${response.requestOptions.uri}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        debugPrint('✅ Countries received: ${data.length}');

        final countries = <Country>[];

        for (final countryData in data) {
          try {
            final country = Country.fromJson(
              countryData as Map<String, dynamic>,
            );
            // Only include countries with valid currency codes
            if (country.currencyCode.isNotEmpty && country.name.isNotEmpty) {
              countries.add(country);
            }
          } catch (e) {
            // Skip countries that can't be parsed
            continue;
          }
        }

        debugPrint('✅ Countries with currencies: ${countries.length}');

        if (countries.isEmpty) {
          throw Exception('No countries with currencies found in API response');
        }

        countries.sort((a, b) => a.name.compareTo(b.name));
        return countries;
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: Failed to load countries\n'
          'URL: $url',
        );
      }
    } on DioException catch (e) {
      // Detailed error logging
      debugPrint('❌ DioException Type: ${e.type}');
      debugPrint('❌ Status Code: ${e.response?.statusCode}');
      debugPrint('❌ Response Data: ${e.response?.data}');
      debugPrint('❌ Request URI: ${e.requestOptions.uri}');
      debugPrint('❌ Error Message: ${e.message}');

      if (e.response != null) {
        // Server responded with error
        final statusCode = e.response!.statusCode;
        final errorBody = e.response!.data?.toString() ?? 'No error body';
        throw Exception(
          'HTTP $statusCode: $errorBody\n'
          'URL: ${e.requestOptions.uri}',
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          'Request timeout: Unable to fetch countries\n\nPlease check your internet connection.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Network error: Unable to connect to server\n\nPlease check your internet connection.',
        );
      } else {
        throw Exception(
          'Network error: ${e.message}\n\nPlease check your internet connection.',
        );
      }
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('Error fetching countries: $e');
    }
  }

  /// Fetches unique currencies from all countries
  Future<Map<String, List<Country>>> getCurrenciesByCountry() async {
    final countries = await getAllCountries();
    final Map<String, List<Country>> currencyMap = {};

    for (final country in countries) {
      if (country.currencyCode.isNotEmpty) {
        if (!currencyMap.containsKey(country.currencyCode)) {
          currencyMap[country.currencyCode] = [];
        }
        currencyMap[country.currencyCode]!.add(country);
      }
    }

    return currencyMap;
  }

  /// Gets a list of unique currencies
  Future<List<String>> getUniqueCurrencies() async {
    final countries = await getAllCountries();
    final Set<String> currencies = {};

    for (final country in countries) {
      if (country.currencyCode.isNotEmpty) {
        currencies.add(country.currencyCode);
      }
    }

    return currencies.toList()..sort();
  }
}
