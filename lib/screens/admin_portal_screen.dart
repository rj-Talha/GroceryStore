import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/products.dart';
import '../services/firestore_service.dart';
import '../theme/tokens.dart';

bool isAdminCredential(String? email, String? password) {
  final normalizedEmail = (email ?? '').trim().toLowerCase();
  if (normalizedEmail != 'r.jtalha@gmail.com') {
    return false;
  }

  if (password == null) {
    return true;
  }

  final normalizedPassword = password.trim();
  return normalizedPassword == 'admin123';
}

class AdminPortalScreen extends StatefulWidget {
  const AdminPortalScreen({super.key});

  @override
  State<AdminPortalScreen> createState() => _AdminPortalScreenState();
}

class _AdminPortalScreenState extends State<AdminPortalScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  final Map<String, _ProductDraft> _drafts = {};

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String? _statusMessage;
  Color? _statusColor;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilter);
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilter);
    _searchController.dispose();
    for (final draft in _drafts.values) {
      draft.dispose();
    }
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
      _statusColor = null;
    });

    try {
      final products = await _firestoreService.getProducts();
      for (final draft in _drafts.values) {
        draft.dispose();
      }
      _drafts.clear();
      _products = products;
      _applyFilter();
      for (final product in _products) {
        _drafts[product.key] = _ProductDraft.fromProduct(product);
      }
    } catch (_) {
      setState(() {
        _statusMessage = 'Unable to load products right now.';
        _statusColor = Colors.red.shade700;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products.where((product) {
        final haystack = [
          product.name,
          product.label,
          product.unit,
          product.key,
        ].join(' ').toLowerCase();
        return haystack.contains(query);
      }).toList();
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _updateProduct(Product product) async {
    final draft = _drafts[product.key];
    if (draft == null) {
      return;
    }

    setState(() {
      _statusMessage = 'Updating ${product.name}...';
      _statusColor = Daana.ink70;
    });

    try {
      final payload = draft.toPayload(product);
      await _firestoreService.updateProduct(product.key, payload);
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Updated ${product.name} successfully.';
        _statusColor = Daana.moss;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Failed to update ${product.name}.';
        _statusColor = Colors.red.shade700;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Daana.bg,
      appBar: AppBar(
        backgroundColor: Daana.bg,
        foregroundColor: Daana.ink,
        elevation: 0,
        title: Text('Admin Portal', style: Daana.serif(size: 24, weight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products by name, label, or unit',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          if (_statusMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _statusMessage!,
                style: Daana.sans(size: 14, color: _statusColor ?? Daana.ink70),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? const Center(child: Text('No products found.'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: _filteredProducts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return _ProductCard(
                            product: product,
                            draft: _drafts[product.key],
                            onChanged: (field, value) {
                              final draft = _drafts[product.key];
                              if (draft != null) {
                                draft.update(field, value);
                              }
                            },
                            onUpdate: () => _updateProduct(product),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.draft,
    required this.onChanged,
    required this.onUpdate,
  });

  final Product product;
  final _ProductDraft? draft;
  final void Function(String field, String value) onChanged;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final fields = draft;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name, style: Daana.serif(size: 18, weight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('${product.key} • ${product.unit}', style: Daana.sans(size: 13, color: Daana.ink70)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 180,
                  child: _buildField('Name', fields?.nameController, (value) => onChanged('name', value)),
                ),
                SizedBox(
                  width: 180,
                  child: _buildField('Unit', fields?.unitController, (value) => onChanged('unit', value)),
                ),
                SizedBox(
                  width: 150,
                  child: _buildField('Price', fields?.priceController, (value) => onChanged('price', value), keyboardType: TextInputType.number),
                ),
                SizedBox(
                  width: 150,
                  child: _buildField('Old Price', fields?.oldController, (value) => onChanged('old', value), keyboardType: TextInputType.number),
                ),
                SizedBox(
                  width: 150,
                  child: _buildField('Deal %', fields?.dealController, (value) => onChanged('deal', value), keyboardType: TextInputType.number),
                ),
                SizedBox(
                  width: 150,
                  child: _buildField('Label', fields?.labelController, (value) => onChanged('label', value)),
                ),
                SizedBox(
                  width: 150,
                  child: _buildField('Tone', fields?.toneController, (value) => onChanged('tone', value)),
                ),
                SizedBox(
                  width: 220,
                  child: _buildField('Image URL', fields?.imageUrlController, (value) => onChanged('imageUrl', value)),
                ),
                SizedBox(
                  width: 150,
                  child: _buildField('Sales Count', fields?.salesCountController, (value) => onChanged('salesCount', value), keyboardType: TextInputType.number),
                ),
                SizedBox(
                  width: 170,
                  child: _buildField('Trending Score', fields?.trendingScoreController, (value) => onChanged('trendingScore', value), keyboardType: TextInputType.number),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: onUpdate,
                icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                label: const Text('Update'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Daana.ink,
                  foregroundColor: Daana.bg,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController? controller,
    ValueChanged<String> onChanged, {
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Daana.sans(size: 12, color: Daana.ink70)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            isDense: true,
          ),
        ),
      ],
    );
  }
}

class _ProductDraft {
  _ProductDraft({
    required this.nameController,
    required this.unitController,
    required this.priceController,
    required this.oldController,
    required this.dealController,
    required this.labelController,
    required this.toneController,
    required this.imageUrlController,
    required this.salesCountController,
    required this.trendingScoreController,
  });

  final TextEditingController nameController;
  final TextEditingController unitController;
  final TextEditingController priceController;
  final TextEditingController oldController;
  final TextEditingController dealController;
  final TextEditingController labelController;
  final TextEditingController toneController;
  final TextEditingController imageUrlController;
  final TextEditingController salesCountController;
  final TextEditingController trendingScoreController;

  factory _ProductDraft.fromProduct(Product product) {
    return _ProductDraft(
      nameController: TextEditingController(text: product.name),
      unitController: TextEditingController(text: product.unit),
      priceController: TextEditingController(text: product.price.toString()),
      oldController: TextEditingController(text: product.old?.toString() ?? ''),
      dealController: TextEditingController(text: product.deal?.toString() ?? ''),
      labelController: TextEditingController(text: product.label),
      toneController: TextEditingController(text: product.tone),
      imageUrlController: TextEditingController(text: product.imageUrl ?? ''),
      salesCountController: TextEditingController(text: product.salesCount.toString()),
      trendingScoreController: TextEditingController(text: product.trendingScore.toString()),
    );
  }

  void update(String field, String value) {
    switch (field) {
      case 'name':
        nameController.text = value;
        break;
      case 'unit':
        unitController.text = value;
        break;
      case 'price':
        priceController.text = value;
        break;
      case 'old':
        oldController.text = value;
        break;
      case 'deal':
        dealController.text = value;
        break;
      case 'label':
        labelController.text = value;
        break;
      case 'tone':
        toneController.text = value;
        break;
      case 'imageUrl':
        imageUrlController.text = value;
        break;
      case 'salesCount':
        salesCountController.text = value;
        break;
      case 'trendingScore':
        trendingScoreController.text = value;
        break;
    }
  }

  Map<String, dynamic> toPayload(Product product) {
    final payload = <String, dynamic>{
      'name': nameController.text.trim().isEmpty ? product.name : nameController.text.trim(),
      'unit': unitController.text.trim().isEmpty ? product.unit : unitController.text.trim(),
      'price': int.tryParse(priceController.text.trim()) ?? product.price,
      'label': labelController.text.trim().isEmpty ? product.label : labelController.text.trim(),
      'tone': toneController.text.trim().isEmpty ? product.tone : toneController.text.trim(),
      'salesCount': int.tryParse(salesCountController.text.trim()) ?? product.salesCount,
      'trendingScore': int.tryParse(trendingScoreController.text.trim()) ?? product.trendingScore,
    };

    if (imageUrlController.text.trim().isNotEmpty) {
      payload['imageUrl'] = imageUrlController.text.trim();
    }

    final oldValue = int.tryParse(oldController.text.trim());
    if (oldValue != null) {
      payload['old'] = oldValue;
    } else if (product.old != null) {
      payload['old'] = product.old;
    }

    final dealValue = int.tryParse(dealController.text.trim());
    if (dealValue != null) {
      payload['deal'] = dealValue;
    } else if (product.deal != null) {
      payload['deal'] = product.deal;
    }

    return payload;
  }

  void dispose() {
    nameController.dispose();
    unitController.dispose();
    priceController.dispose();
    oldController.dispose();
    dealController.dispose();
    labelController.dispose();
    toneController.dispose();
    imageUrlController.dispose();
    salesCountController.dispose();
    trendingScoreController.dispose();
  }
}
