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

enum _AdminPortalView { products, orders }

class _AdminPortalScreenState extends State<AdminPortalScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  final Map<String, _ProductDraft> _drafts = {};

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<StoreOrder> _orders = [];
  List<StoreOrder> _filteredOrders = [];
  bool _isLoading = true;
  bool _isOrdersLoading = true;
  _AdminPortalView _view = _AdminPortalView.products;
  String? _statusMessage;
  Color? _statusColor;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilter);
    _loadProducts();
    _loadOrders();
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

  Future<void> _loadOrders() async {
    setState(() {
      _isOrdersLoading = true;
      _statusMessage = null;
      _statusColor = null;
    });

    try {
      final orders = await _firestoreService.getOrders();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _applyFilter();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Unable to load orders right now.';
        _statusColor = Colors.red.shade700;
      });
    } finally {
      if (mounted) {
        setState(() => _isOrdersLoading = false);
      }
    }
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    if (_view == _AdminPortalView.orders) {
      if (query.isEmpty) {
        _filteredOrders = List.from(_orders);
      } else {
        _filteredOrders = _orders.where((order) {
          final haystack = [
            order.customerName,
            order.phone,
            order.address,
            order.email,
            order.status,
          ].join(' ').toLowerCase();
          return haystack.contains(query);
        }).toList();
      }
    } else {
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

  Future<void> _updateOrderStatus(StoreOrder order, String status) async {
    setState(() {
      _statusMessage = 'Updating order status...';
      _statusColor = Daana.ink70;
    });

    try {
      await _firestoreService.updateOrderStatus(order.id, status);
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Order status updated.';
        _statusColor = Daana.moss;
      });
      await _loadOrders();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Failed to update order status.';
        _statusColor = Colors.red.shade700;
      });
    }
  }

  void _showOrderDetails(StoreOrder order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Order details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order ID: ${order.id}',
                  style: Daana.sans(size: 13, color: Daana.ink70),
                ),
                const SizedBox(height: 10),
                Text(
                  order.customerName.isEmpty
                      ? 'Guest customer'
                      : order.customerName,
                  style: Daana.sans(size: 14, weight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  order.email.isEmpty
                      ? order.phone
                      : '${order.email} • ${order.phone}',
                  style: Daana.sans(size: 12, color: Daana.ink70),
                ),
                const SizedBox(height: 16),
                Text(
                  'Items',
                  style: Daana.sans(size: 14, weight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                ...order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: Daana.sans(
                                  size: 13,
                                  weight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.quantity} × Rs ${Products.formatRs(item.unitPrice)} · ${item.unit}',
                                style: Daana.sans(size: 12, color: Daana.ink70),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Rs ${Products.formatRs(item.lineTotal)}',
                          style: Daana.sans(size: 13, weight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const Divider(),
                const SizedBox(height: 10),
                Text(
                  'Total: Rs ${Products.formatRs(order.total)}',
                  style: Daana.sans(size: 14, weight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Status: ${_orderStatusLabel(order.status)}',
                  style: Daana.sans(size: 13, color: Daana.ink70),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Daana.bg,
      appBar: AppBar(
        backgroundColor: Daana.bg,
        foregroundColor: Daana.ink,
        elevation: 0,
        title: Text(
          'Admin Portal',
          style: Daana.serif(size: 24, weight: FontWeight.w700),
        ),
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
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () {
                      setState(() {
                        _view = _AdminPortalView.products;
                      });
                      _applyFilter();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: _view == _AdminPortalView.products
                          ? Daana.ink
                          : Colors.white,
                      foregroundColor: _view == _AdminPortalView.products
                          ? Daana.bg
                          : Daana.ink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text('All products'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () {
                      setState(() {
                        _view = _AdminPortalView.orders;
                      });
                      _applyFilter();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: _view == _AdminPortalView.orders
                          ? Daana.ink
                          : Colors.white,
                      foregroundColor: _view == _AdminPortalView.orders
                          ? Daana.bg
                          : Daana.ink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text('Order list'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _view == _AdminPortalView.orders
                    ? 'Search orders by customer, phone, or address'
                    : 'Search products by name, label, or unit',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
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
            child: _view == _AdminPortalView.orders
                ? (_isOrdersLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredOrders.isEmpty
                      ? const Center(child: Text('No orders found.'))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: _filteredOrders.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final order = _filteredOrders[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 0,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            order.customerName.isEmpty
                                                ? 'Guest customer'
                                                : order.customerName,
                                            style: Daana.serif(
                                              size: 18,
                                              weight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _orderStatusColor(
                                              order.status,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(
                                            _orderStatusLabel(order.status),
                                            style: Daana.sans(
                                              size: 12,
                                              color: Colors.white,
                                              weight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${order.phone} • ${order.address}',
                                      style: Daana.sans(
                                        size: 13,
                                        color: Daana.ink70,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Items: ${order.items.length} • Total: Rs ${Products.formatRs(order.total)}',
                                      style: Daana.sans(
                                        size: 13,
                                        color: Daana.ink70,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    OutlinedButton(
                                      onPressed: () => _showOrderDetails(order),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Daana.ink,
                                        side: BorderSide(
                                          color: Daana.hairlineSoft,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                      ),
                                      child: const Text('View details'),
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<String>(
                                      value: order.status,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        isDense: true,
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'processing',
                                          child: Text('Processing'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'cancelled',
                                          child: Text('Cancelled'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'delivered',
                                          child: Text('Delivered'),
                                        ),
                                      ],
                                      onChanged: (value) async {
                                        if (value == null ||
                                            value == order.status)
                                          return;
                                        await _updateOrderStatus(order, value);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ))
                : (_isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredProducts.isEmpty
                      ? const Center(child: Text('No products found.'))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: _filteredProducts.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
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
                        )),
          ),
        ],
      ),
    );
  }
}

Color _orderStatusColor(String status) {
  switch (status) {
    case 'delivered':
      return Daana.moss;
    case 'cancelled':
      return Colors.red.shade600;
    default:
      return Daana.ink70;
  }
}

String _orderStatusLabel(String status) {
  switch (status) {
    case 'delivered':
      return 'Delivered';
    case 'cancelled':
      return 'Cancelled';
    default:
      return 'Processing';
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
            Text(
              product.name,
              style: Daana.serif(size: 18, weight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '${product.key} • ${product.unit}',
              style: Daana.sans(size: 13, color: Daana.ink70),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 180,
                  child: _buildField(
                    'Name',
                    fields?.nameController,
                    (value) => onChanged('name', value),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: _buildField(
                    'Unit',
                    fields?.unitController,
                    (value) => onChanged('unit', value),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: _buildField(
                    'Price',
                    fields?.priceController,
                    (value) => onChanged('price', value),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: _buildField(
                    'Old Price',
                    fields?.oldController,
                    (value) => onChanged('old', value),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: _buildField(
                    'Deal %',
                    fields?.dealController,
                    (value) => onChanged('deal', value),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: _buildField(
                    'Label',
                    fields?.labelController,
                    (value) => onChanged('label', value),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: _buildField(
                    'Tone',
                    fields?.toneController,
                    (value) => onChanged('tone', value),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: _buildField(
                    'Image URL',
                    fields?.imageUrlController,
                    (value) => onChanged('imageUrl', value),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: _buildField(
                    'Sales Count',
                    fields?.salesCountController,
                    (value) => onChanged('salesCount', value),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(
                  width: 170,
                  child: _buildField(
                    'Trending Score',
                    fields?.trendingScoreController,
                    (value) => onChanged('trendingScore', value),
                    keyboardType: TextInputType.number,
                  ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
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
      dealController: TextEditingController(
        text: product.deal?.toString() ?? '',
      ),
      labelController: TextEditingController(text: product.label),
      toneController: TextEditingController(text: product.tone),
      imageUrlController: TextEditingController(text: product.imageUrl ?? ''),
      salesCountController: TextEditingController(
        text: product.salesCount.toString(),
      ),
      trendingScoreController: TextEditingController(
        text: product.trendingScore.toString(),
      ),
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
      'name': nameController.text.trim().isEmpty
          ? product.name
          : nameController.text.trim(),
      'unit': unitController.text.trim().isEmpty
          ? product.unit
          : unitController.text.trim(),
      'price': int.tryParse(priceController.text.trim()) ?? product.price,
      'label': labelController.text.trim().isEmpty
          ? product.label
          : labelController.text.trim(),
      'tone': toneController.text.trim().isEmpty
          ? product.tone
          : toneController.text.trim(),
      'salesCount':
          int.tryParse(salesCountController.text.trim()) ?? product.salesCount,
      'trendingScore':
          int.tryParse(trendingScoreController.text.trim()) ??
          product.trendingScore,
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
