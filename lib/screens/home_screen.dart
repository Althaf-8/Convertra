import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_app_bar.dart';
import 'length_conversion_screen.dart';
import 'temperature_conversion_screen.dart';
import 'time_conversion_screen.dart';
import 'speed_conversion_screen.dart';
import 'energy_conversion_screen.dart';
import 'fuel_economy_conversion_screen.dart';
import 'data_storage_conversion_screen.dart';
import 'mass_conversion_screen.dart';
import 'volume_conversion_screen.dart';
import 'area_conversion_screen.dart';
import 'bill_split_screen.dart';
import 'profit_loss_screen.dart';
import '../currencyscreens/currency_conversion_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _conversionOptions = [
    {
      'title': 'Length / Distance',
      'icon': Icons.landscape,
      'color': Colors.green,
      'screen': const LengthConversionScreen(),
    },
    {
      'title': 'Area',
      'icon': Icons.square_foot,
      'color': Colors.deepPurple,
      'screen': const AreaConversionScreen(),
    },
    {
      'title': 'Currency',
      'icon': Icons.attach_money,
      'color': Colors.green[700]!,
      'screen': const CurrencyConversionScreen(),
    },
    {
      'title': 'Mass / Weight',
      'icon': Icons.scale,
      'color': Colors.brown,
      'screen': const MassConversionScreen(),
    },
    {
      'title': 'Volume / Capacity',
      'icon': Icons.invert_colors,
      'color': Colors.cyan,
      'screen': const VolumeConversionScreen(),
    },
    {
      'title': 'Temperature',
      'icon': Icons.thermostat,
      'color': Colors.red,
      'screen': const TemperatureConversionScreen(),
    },
    {
      'title': 'Time / Duration',
      'icon': Icons.access_time,
      'color': Colors.blue,
      'screen': const TimeConversionScreen(),
    },
    {
      'title': 'Speed / Velocity',
      'icon': Icons.speed,
      'color': Colors.orange,
      'screen': const SpeedConversionScreen(),
    },
    {
      'title': 'Energy & Power',
      'icon': Icons.bolt,
      'color': Colors.amber,
      'screen': const EnergyConversionScreen(),
    },
    {
      'title': 'Data Storage',
      'icon': Icons.storage,
      'color': Colors.indigo,
      'screen': const DataStorageConversionScreen(),
    },
    {
      'title': 'Bill Splitter',
      'icon': Icons.receipt_long,
      'color': Colors.purple,
      'screen': const BillSplitScreen(),
    },
    {
      'title': 'Profit & Loss',
      'icon': Icons.account_balance_wallet,
      'color': Colors.teal,
      'screen': const ProfitLossScreen(),
    },
    {
      'title': 'Fuel Economy',
      'icon': Icons.local_gas_station,
      'color': Colors.teal,
      'screen': const FuelEconomyConversionScreen(),
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredOptions {
    if (_searchQuery.isEmpty) {
      return _conversionOptions;
    }
    return _conversionOptions
        .where(
          (option) => option['title'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _isSearching
          ? AppBar(
              elevation: 0,
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _toggleSearch,
              ),
              title: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search conversions...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              actions: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  ),
              ],
            )
          : CustomAppBar(
              title: 'Convertra',
              showSearch: true,
              showMenu: true,
              onSearchPressed: _toggleSearch,
            ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white, Colors.grey[50]!],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  'ALL IN ONE CONVERTER',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue[700],
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 24),

                // Quick Actions Grid
                if (!_isSearching)
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                if (_isSearching && _searchQuery.isNotEmpty)
                  Text(
                    'Search Results (${_filteredOptions.length})',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                if (_isSearching && _searchQuery.isEmpty)
                  Text(
                    'Search Conversions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                const SizedBox(height: 16),
                _filteredOptions.isEmpty && _searchQuery.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No results found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try a different search term',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.0,
                        children: _filteredOptions.map((option) {
                          return _buildActionCard(
                            context,
                            icon: option['icon'],
                            title: option['title'],
                            color: option['color'],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => option['screen'],
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap:
          onTap ??
          () {
            // Add navigation functionality
          },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.visible,
                softWrap: true,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
