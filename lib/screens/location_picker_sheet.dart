import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../theme/tokens.dart';
import '../widgets/btn.dart';
import 'location_picker_utils.dart';

class LocationPickerSheet extends StatefulWidget {
  const LocationPickerSheet({super.key});

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  static const LatLng _pakistanCenter = LatLng(30.3753, 69.3451);

  LatLng _selectedPoint = _pakistanCenter;
  String _selectedAddress = 'Tap the map or search for an address';
  bool _isLoading = false;
  String? _searchError;
  List<_SearchCandidate> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _resolveAddress(_selectedPoint);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _resolveAddress(LatLng point) async {
    if (!isWithinPakistanBounds(point.latitude, point.longitude)) {
      setState(() {
        _selectedAddress = 'Please choose a point inside Pakistan';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchError = null;
    });

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${point.latitude}&lon=${point.longitude}&zoom=18&addressdetails=1',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'DaanaGroceryApp/1.0'},
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final displayName = (body['display_name'] as String?)?.trim();
        final resolvedDisplayName =
            displayName != null && displayName.isNotEmpty
                ? displayName
                : 'Selected location in Pakistan';
        setState(() {
          _selectedAddress = resolvedDisplayName;
        });
      } else {
        setState(() {
          _selectedAddress = 'Selected location in Pakistan';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _selectedAddress = 'Selected location in Pakistan';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _searchPlaces(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchError = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchError = null;
    });

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=jsonv2&limit=5&q=${Uri.encodeComponent(trimmed)}&countrycodes=pk&addressdetails=1',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'DaanaGroceryApp/1.0'},
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as List<dynamic>;
        final results = decoded
            .whereType<Map<String, dynamic>>()
            .map(
              (entry) => _SearchCandidate(
                displayName: entry['display_name'] as String? ?? 'Address',
                latitude: double.tryParse(entry['lat']?.toString() ?? '') ?? 0,
                longitude: double.tryParse(entry['lon']?.toString() ?? '') ?? 0,
              ),
            )
            .where((candidate) => isWithinPakistanBounds(candidate.latitude, candidate.longitude))
            .toList();

        setState(() {
          _searchResults = results;
          if (results.isEmpty) {
            _searchError = 'No Pakistan addresses matched your search.';
          }
        });
      } else {
        setState(() {
          _searchError = 'Unable to search addresses right now.';
          _searchResults = [];
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _searchError = 'Unable to search addresses right now.';
        _searchResults = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectPoint(LatLng point) async {
    if (!isWithinPakistanBounds(point.latitude, point.longitude)) {
      setState(() {
        _searchError = 'Please choose a location inside Pakistan.';
      });
      return;
    }

    setState(() {
      _selectedPoint = point;
      _searchError = null;
    });
    await _resolveAddress(point);
  }

  void _useSelectedLocation() {
    Navigator.of(context).pop(
      formatLocationSummary(
        latitude: _selectedPoint.latitude,
        longitude: _selectedPoint.longitude,
        displayName: _selectedAddress,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.94,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pick delivery point',
                            style: Daana.sans(size: 18, weight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pakistan-only map • tap to pin your address',
                            style: Daana.sans(size: 13, color: Daana.ink70),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: _searchPlaces,
                        decoration: InputDecoration(
                          hintText: 'Search your address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () => _searchPlaces(_searchController.text),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_searchError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    _searchError!,
                    style: Daana.sans(size: 12, color: Colors.red.shade700),
                  ),
                ),
              if (_searchResults.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  constraints: const BoxConstraints(maxHeight: 160),
                  decoration: BoxDecoration(
                    color: Daana.ink08,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _searchResults[index];
                      return ListTile(
                        dense: true,
                        title: Text(item.displayName, style: Daana.sans(size: 13)),
                        onTap: () {
                          _mapController.move(LatLng(item.latitude, item.longitude), 14);
                          _selectPoint(LatLng(item.latitude, item.longitude));
                        },
                      );
                    },
                  ),
                ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _pakistanCenter,
                      initialZoom: 5.2,
                      minZoom: 4.0,
                      maxZoom: 18.0,
                      onTap: (_, point) async => _selectPoint(point),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.daana.grocery',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedPoint,
                            width: 48,
                            height: 48,
                            child: const Icon(Icons.location_pin, size: 36, color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isLoading ? 'Looking up your address…' : 'Selected point',
                      style: Daana.sans(size: 12, weight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedAddress,
                      style: Daana.sans(size: 13, color: Daana.ink70),
                    ),
                    const SizedBox(height: 14),
                    Btn(
                      'Use this location',
                      full: true,
                      onPressed: _useSelectedLocation,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchCandidate {
  const _SearchCandidate({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  final String displayName;
  final double latitude;
  final double longitude;
}
