import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ExchangeRateService {
  static const String _baseUrl = 'https://open.er-api.com/v6/latest';

  /// Converts an amount from one currency to another using real-time exchange rates
  /// Returns the converted amount, or null if conversion fails
  Future<double?> convertCurrency({
    required String from,
    required String to,
    required double amount,
  }) async {
    try {
      final dio = Dio();
      final url = '$_baseUrl/$from';

      debugPrint('🔄 Converting Currency: $amount $from → $to');
      debugPrint('📡 API URL: $url');

      final response = await dio.get(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      debugPrint('✅ API Response Status: ${response.statusCode}');
      debugPrint('✅ Response URL: ${response.requestOptions.uri}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data == null) {
          debugPrint('⚠️ Response data is null');
          return null;
        }

        debugPrint('📊 Result: ${data['result']}');
        debugPrint('📊 Base Code: ${data['base_code']}');
        debugPrint('📊 Time Last Update: ${data['time_last_update_utc']}');

        if (data['result'] == 'success') {
          final rates = data['rates'] as Map<String, dynamic>?;

          if (rates == null) {
            debugPrint('⚠️ Rates object is null');
            return null;
          }

          // If converting from base currency to itself
          if (from == to) {
            debugPrint('✅ Same currency: $amount $from = $amount $to');
            return amount;
          }

          // Get the exchange rate for the target currency
          final rate = rates[to];

          if (rate == null) {
            debugPrint('⚠️ Target currency "$to" not found in rates');
            debugPrint(
              '📊 Available currencies: ${rates.keys.take(10).join(", ")}...',
            );
            return null;
          }

          final rateValue = (rate as num).toDouble();
          final convertedAmount = rateValue * amount;

          debugPrint('📊 Exchange rate: 1 $from = $rateValue $to');
          debugPrint(
            '✅ Conversion successful: $amount $from = $convertedAmount $to',
          );

          return convertedAmount;
        } else {
          debugPrint('⚠️ API returned result: ${data['result']}');
          debugPrint('⚠️ Full response: $data');
          return null;
        }
      } else {
        debugPrint('⚠️ HTTP Status Code: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      debugPrint('❌ Exchange Rate API DioException');
      debugPrint('❌ Error Type: ${e.type}');
      debugPrint('❌ Error Message: ${e.message}');
      debugPrint('❌ Request URI: ${e.requestOptions.uri}');

      if (e.response != null) {
        debugPrint('❌ Response Status Code: ${e.response!.statusCode}');
        debugPrint('❌ Response Data: ${e.response!.data}');
      } else {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          debugPrint('❌ Request timeout - check internet connection');
        } else if (e.type == DioExceptionType.connectionError) {
          debugPrint('❌ Connection error - unable to reach server');
        }
      }
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error converting currency: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      return null;
    }
  }

  /// Gets the exchange rate between two currencies (for 1 unit)
  /// Returns the rate, or null if fetching fails
  Future<double?> getExchangeRate({
    required String from,
    required String to,
  }) async {
    debugPrint('🔄 Getting exchange rate: 1 $from → $to');

    // If same currency, return 1.0
    if (from == to) {
      debugPrint('✅ Same currency: 1 $from = 1.0 $to');
      return 1.0;
    }

    try {
      final dio = Dio();
      final url = '$_baseUrl/$from';

      final response = await dio.get(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null &&
            data['result'] == 'success' &&
            data['rates'] != null) {
          final rates = data['rates'] as Map<String, dynamic>;
          final rate = rates[to];

          if (rate != null) {
            final rateValue = (rate as num).toDouble();
            debugPrint('✅ Exchange rate: 1 $from = $rateValue $to');
            return rateValue;
          } else {
            debugPrint('⚠️ Target currency "$to" not found in rates');
            return null;
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting exchange rate: $e');
      return null;
    }
  }
}
