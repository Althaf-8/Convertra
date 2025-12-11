import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_app_bar.dart';
import 'country.dart';
import 'countries_service.dart';
import 'exchange_rate_service.dart';

class CurrencyConversionScreen extends StatefulWidget {
  const CurrencyConversionScreen({super.key});

  @override
  State<CurrencyConversionScreen> createState() =>
      _CurrencyConversionScreenState();
}

class _CurrencyConversionScreenState extends State<CurrencyConversionScreen> {
  final TextEditingController _inputController = TextEditingController();
  final CountriesService _countriesService = CountriesService();
  final ExchangeRateService _exchangeRateService = ExchangeRateService();

  List<Country> _countries = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isConverting = false;

  Country? _fromCountry;
  Country? _toCountry;
  String _result = '0';
  double? _exchangeRate;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadCountries();
    _inputController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Create new timer for debouncing
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        _convert();
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _inputController.removeListener(_onInputChanged);
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final countries = await _countriesService.getAllCountries();
      setState(() {
        _countries = countries;
        _isLoading = false;

        // Set default countries if available
        if (_countries.isNotEmpty) {
          // Try to find USD and EUR as defaults
          try {
            _fromCountry = _countries.firstWhere(
              (c) => c.currencyCode == 'USD',
            );
          } catch (_) {
            _fromCountry = _countries[0];
          }

          try {
            _toCountry = _countries.firstWhere(
              (c) => c.currencyCode == 'EUR' && c != _fromCountry,
            );
          } catch (_) {
            _toCountry = _countries.length > 1 ? _countries[1] : _countries[0];
          }
          _convert();
        } else {
          _errorMessage =
              'No countries with currencies found. Please check your internet connection.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Failed to load countries: $e\n\nPlease check your internet connection and try again.';
      });
    }
  }

  Future<void> _convert() async {
    final input = _inputController.text.trim();
    if (input.isEmpty || _fromCountry == null || _toCountry == null) {
      setState(() {
        _result = '0';
        _exchangeRate = null;
      });
      return;
    }

    // If same currency selected, just return the same amount
    if (_fromCountry!.currencyCode == _toCountry!.currencyCode) {
      setState(() {
        _result = input;
        _exchangeRate = 1.0;
      });
      return;
    }

    try {
      final value = double.parse(input);
      debugPrint(
        '💰 Starting conversion: $value ${_fromCountry!.currencyCode} → ${_toCountry!.currencyCode}',
      );

      setState(() {
        _isConverting = true;
      });

      // Fetch real-time exchange rate from API
      final convertedAmount = await _exchangeRateService.convertCurrency(
        from: _fromCountry!.currencyCode,
        to: _toCountry!.currencyCode,
        amount: value,
      );

      debugPrint('💰 Converted amount received: $convertedAmount');

      // Get exchange rate for 1 unit to display
      final rate = await _exchangeRateService.getExchangeRate(
        from: _fromCountry!.currencyCode,
        to: _toCountry!.currencyCode,
      );

      debugPrint('💰 Exchange rate received: $rate');

      if (convertedAmount != null && rate != null) {
        setState(() {
          _isConverting = false;
          _exchangeRate = rate;

          // Format result to avoid unnecessary decimals
          if (convertedAmount % 1 == 0) {
            _result = convertedAmount.toInt().toString();
          } else {
            _result = convertedAmount
                .toStringAsFixed(2)
                .replaceAll(RegExp(r'0+$'), '')
                .replaceAll(RegExp(r'\.$'), '');
          }
        });
        debugPrint(
          '✅ Conversion successful: $value ${_fromCountry!.currencyCode} = $_result ${_toCountry!.currencyCode}',
        );
      } else {
        debugPrint('⚠️ Conversion failed - received null values');
        debugPrint('   Converted amount: $convertedAmount');
        debugPrint('   Exchange rate: $rate');
        setState(() {
          _isConverting = false;
          _result = 'Error';
          _exchangeRate = null;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in _convert method: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      setState(() {
        _isConverting = false;
        _result = 'Error';
        _exchangeRate = null;
      });
    }
  }

  void _clearForm() {
    _inputController.clear();
    setState(() {
      _result = '0';
      _exchangeRate = null;
    });
  }

  Future<void> _showCountrySelector({required bool isFromCountry}) async {
    final selectedCountry = await showDialog<Country>(
      context: context,
      builder: (context) => _CountrySelectorDialog(
        allCountries: _countries,
        initialSearchQuery: '',
        onSearchChanged: (query) {
          // Callback is handled internally by the dialog
        },
      ),
    );

    if (selectedCountry != null) {
      setState(() {
        if (isFromCountry) {
          _fromCountry = selectedCountry;
        } else {
          _toCountry = selectedCountry;
        }
      });
      _convert();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const CustomAppBar(title: 'Currency Converter'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[50]!,
              Colors.teal[50]!,
              Colors.green[100]!,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCountries,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Info Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                Colors.green[600]!,
                                Colors.teal[500]!,
                                Colors.green[400]!,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Real-time exchange rates updated hourly. Rates are for informational purposes only.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Conversion Card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                Colors.green[700]!,
                                Colors.green[600]!,
                                Colors.teal[500]!,
                                Colors.green[400]!,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              // From Currency Input
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'From',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.5,
                                          ),
                                          width: 2,
                                        ),
                                      ),
                                      child: TextField(
                                        controller: _inputController,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d+\.?\d*'),
                                          ),
                                        ],
                                        decoration: InputDecoration(
                                          hintText: 'Enter amount',
                                          hintStyle: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.6,
                                            ),
                                            fontSize: 16,
                                          ),
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    GestureDetector(
                                      onTap: () => _showCountrySelector(
                                        isFromCountry: true,
                                      ),
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          maxWidth: double.infinity,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            if (_fromCountry != null) ...[
                                              SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    _fromCountry!
                                                            .flag
                                                            .isNotEmpty &&
                                                        _fromCountry!.isFlagUrl
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                        child: Image.network(
                                                          _fromCountry!.flag,
                                                          width: 20,
                                                          height: 20,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return const Icon(
                                                                  Icons.flag,
                                                                  size: 16,
                                                                );
                                                              },
                                                        ),
                                                      )
                                                    : Text(
                                                        _fromCountry!
                                                                .flag
                                                                .isNotEmpty
                                                            ? _fromCountry!.flag
                                                            : '🌍',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                              ),
                                              const SizedBox(width: 4),
                                            ],
                                            Expanded(
                                              child: Text(
                                                _fromCountry != null
                                                    ? '${_fromCountry!.name} (${_fromCountry!.currencyCode})'
                                                    : 'Select Currency',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                softWrap: false,
                                              ),
                                            ),
                                            const SizedBox(width: 2),
                                            const Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Swap Button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        final temp = _fromCountry;
                                        _fromCountry = _toCountry;
                                        _toCountry = temp;
                                        _convert();
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.swap_vert,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // To Currency Dropdown
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'To',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    GestureDetector(
                                      onTap: () => _showCountrySelector(
                                        isFromCountry: false,
                                      ),
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          maxWidth: double.infinity,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            if (_toCountry != null) ...[
                                              SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    _toCountry!
                                                            .flag
                                                            .isNotEmpty &&
                                                        _toCountry!.isFlagUrl
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                        child: Image.network(
                                                          _toCountry!.flag,
                                                          width: 20,
                                                          height: 20,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return const Icon(
                                                                  Icons.flag,
                                                                  size: 16,
                                                                );
                                                              },
                                                        ),
                                                      )
                                                    : Text(
                                                        _toCountry!
                                                                .flag
                                                                .isNotEmpty
                                                            ? _toCountry!.flag
                                                            : '🌍',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                              ),
                                              const SizedBox(width: 4),
                                            ],
                                            Expanded(
                                              child: Text(
                                                _toCountry != null
                                                    ? '${_toCountry!.name} (${_toCountry!.currencyCode})'
                                                    : 'Select Currency',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                softWrap: false,
                                              ),
                                            ),
                                            const SizedBox(width: 2),
                                            const Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Clear Form Button
                              ElevatedButton(
                                onPressed: _clearForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.3,
                                  ),
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Clear Form',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Result Card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                Colors.green[700]!,
                                Colors.green[600]!,
                                Colors.teal[500]!,
                                Colors.green[400]!,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Result',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: _isConverting
                                    ? const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        ),
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _result,
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _toCountry != null
                                                ? '${_toCountry!.currencyName} (${_toCountry!.currencyCode})'
                                                : '',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (_exchangeRate != null &&
                                              _fromCountry != null &&
                                              _toCountry != null) ...[
                                            const SizedBox(height: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(
                                                  alpha: 0.15,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '1 ${_fromCountry!.currencyCode} = ${_exchangeRate!.toStringAsFixed(_exchangeRate! < 1 ? 4 : 2)} ${_toCountry!.currencyCode}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.8),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _CountrySelectorDialog extends StatefulWidget {
  final List<Country> allCountries;
  final String initialSearchQuery;
  final Function(String) onSearchChanged;

  const _CountrySelectorDialog({
    required this.allCountries,
    required this.initialSearchQuery,
    required this.onSearchChanged,
  });

  @override
  State<_CountrySelectorDialog> createState() => _CountrySelectorDialogState();
}

class _CountrySelectorDialogState extends State<_CountrySelectorDialog> {
  late TextEditingController _searchController;
  List<Country> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearchQuery);
    _filteredCountries = widget.allCountries;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    widget.onSearchChanged(query);

    setState(() {
      if (query.isEmpty) {
        _filteredCountries = widget.allCountries;
      } else {
        _filteredCountries = widget.allCountries
            .where(
              (country) =>
                  country.name.toLowerCase().contains(query.toLowerCase()) ||
                  country.currencyCode.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  country.currencyName.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search countries or currencies...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredCountries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No countries found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredCountries.length,
                      itemBuilder: (context, index) {
                        final country = _filteredCountries[index];
                        return ListTile(
                          leading: SizedBox(
                            width: 40,
                            height: 40,
                            child: country.flag.isNotEmpty && country.isFlagUrl
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      country.flag,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: const Icon(
                                                Icons.flag,
                                                size: 24,
                                              ),
                                            );
                                          },
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: const Center(
                                                child: SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                              ),
                                            );
                                          },
                                    ),
                                  )
                                : Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        country.flag.isNotEmpty
                                            ? country.flag
                                            : '🌍',
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),
                          ),
                          title: Text(
                            country.name.isNotEmpty ? country.name : 'Unknown',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          subtitle: Text(
                            country.currencyCode.isNotEmpty
                                ? '${country.currencyName}${country.currencySymbol.isNotEmpty ? ' (${country.currencySymbol})' : ''} (${country.currencyCode})'
                                : 'No currency',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          onTap: () {
                            Navigator.of(context).pop(country);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
