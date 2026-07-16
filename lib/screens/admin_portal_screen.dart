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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
            product.urduName ?? '',
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

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete product?'),
          content: Text('Delete "${product.name}" from Firebase?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _statusMessage = 'Deleting ${product.name}...';
      _statusColor = Daana.ink70;
    });

    try {
      await _firestoreService.deleteProduct(product.key);
      await _loadProducts();
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Deleted ${product.name} from Firebase.';
        _statusColor = Colors.red.shade700;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Failed to delete ${product.name}.';
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

  Future<void> _showAddProductDialog() async {
    final nameController = TextEditingController();
    final urduController = TextEditingController();
    final labelController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    final whatController = TextEditingController();
    final categoryController = TextEditingController();
    final stockController = TextEditingController();
    final imageController = TextEditingController();
    final thumbs = List.generate(4, (_) => TextEditingController());

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add new product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: urduController,
                  decoration: const InputDecoration(labelText: 'Urdu name'),
                ),
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(labelText: 'Label'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: stockController,
                  decoration: const InputDecoration(labelText: 'Available stock'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(labelText: 'Main image URL'),
                ),
                const SizedBox(height: 8),
                ...List.generate(4, (i) {
                  return TextField(
                    controller: thumbs[i],
                    decoration: InputDecoration(labelText: 'Thumbnail ${i + 1}'),
                  );
                }),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: whatController,
                  decoration: const InputDecoration(labelText: 'What you can make'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                for (final c in [
                  nameController,
                  urduController,
                  labelController,
                  priceController,
                  descriptionController,
                  whatController,
                  categoryController,
                  stockController,
                  imageController,
                  ...thumbs
                ]) {
                  c.dispose();
                }
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final label = labelController.text.trim();
                final price = int.tryParse(priceController.text.trim()) ?? 0;
                final availableStock = int.tryParse(stockController.text.trim()) ?? 0;
                if (name.isEmpty || label.isEmpty || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide name, label and valid price')),
                  );
                  return;
                }

                final payload = <String, dynamic>{
                  'name': name,
                  'label': label,
                  'price': price,
                  'category': categoryController.text.trim(),
                  'availableStock': availableStock,
                  'urduName': urduController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'whatYouCanMake': whatController.text.trim(),
                  'imageUrl': imageController.text.trim().isEmpty ? null : imageController.text.trim(),
                  'tone': 'd',
                  'salesCount': 0,
                  'trendingScore': 0,
                };

                final thumbsList = thumbs.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
                if (thumbsList.isNotEmpty) payload['thumbnailImageUrls'] = thumbsList;

                try {
                  await _firestoreService.createProduct(payload);
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  setState(() {
                    _statusMessage = 'Product "$name" added.';
                    _statusColor = Daana.moss;
                  });
                  await _loadProducts();
                } catch (e) {
                  if (!mounted) return;
                  setState(() {
                    _statusMessage = 'Failed to add product.';
                    _statusColor = Colors.red.shade700;
                  });
                } finally {
                  for (final c in [
                    nameController,
                    urduController,
                    labelController,
                    priceController,
                    descriptionController,
                    whatController,
                    categoryController,
                    stockController,
                    imageController,
                    ...thumbs
                  ]) {
                    c.dispose();
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
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
    final lowStockCount = _products.where((p) => (p.availableStock ?? 0) < 10).length;
    return Scaffold(
      key: _scaffoldKey,
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
          // Shortage button with badge
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                TextButton(
                  onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Daana.ink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text('Shortage'),
                ),
                if (lowStockCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      child: Center(
                        child: Text(
                          '$lowStockCount',
                          style: Daana.sans(size: 12, color: Colors.white, weight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Low stock products', style: Daana.serif(size: 18, weight: FontWeight.w700)),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Builder(builder: (context) {
                    final lowStockProducts = _products.where((p) => (p.availableStock ?? 0) < 10).toList();
                    if (lowStockProducts.isEmpty) {
                      return Center(child: Text('No products with low stock.', style: Daana.sans(size: 14, color: Daana.ink70)));
                    }

                    return ListView.separated(
                      itemCount: lowStockProducts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final p = lowStockProducts[index];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          child: ListTile(
                            title: Text(p.name, style: Daana.sans(size: 14, weight: FontWeight.w600)),
                            subtitle: Text('Available: ${p.availableStock ?? 0}', style: Daana.sans(size: 12, color: Daana.ink70)),
                            trailing: ElevatedButton(
                              onPressed: () {
                                // close drawer and scroll to product in main list? For now just close.
                                Navigator.of(context).maybePop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Daana.ink,
                                foregroundColor: Daana.bg,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                              ),
                              child: const Text('Close'),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
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
                const SizedBox(width: 12),
                FilledButton.tonal(
                  onPressed: _showAddProductDialog,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Daana.ink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text('Add New Product'),
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
                              onDelete: () => _deleteProduct(product),
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
    required this.onDelete,
  });

  final Product product;
  final _ProductDraft? draft;
  final void Function(String field, String value) onChanged;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

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
            if ((product.urduName ?? '').isNotEmpty)
              Text(product.urduName!, style: Daana.sans(size: 13, color: Daana.ink70)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 220,
                  child: _buildField(
                    'Name',
                    fields?.nameController,
                    (value) => onChanged('name', value),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: _buildField(
                    'Urdu name',
                    fields?.urduNameController,
                    (value) => onChanged('urduName', value),
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
                    'Label',
                    fields?.labelController,
                    (value) => onChanged('label', value),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: _buildField(
                    'Category',
                    fields?.categoryController,
                    (value) => onChanged('category', value),
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: _buildField(
                    'Available stock',
                    fields?.availableStockController,
                    (value) => onChanged('availableStock', value),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(
                  width: 360,
                  child: _buildField(
                    'Description',
                    fields?.descriptionController,
                    (value) => onChanged('description', value),
                  ),
                ),
                SizedBox(
                  width: 360,
                  child: _buildField(
                    'What you can make',
                    fields?.whatYouCanMakeController,
                    (value) => onChanged('whatYouCanMake', value),
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: _buildField(
                    'Main image URL',
                    fields?.imageUrlController,
                    (value) => onChanged('imageUrl', value),
                  ),
                ),
                // Thumbnail links (up to 4)
                for (var i = 0; i < 4; i++)
                  SizedBox(
                    width: 320,
                    child: _buildField(
                      'Thumbnail link ${i + 1}',
                      (fields?.thumbnailControllers.length ?? 0) > i
                          ? fields?.thumbnailControllers[i]
                          : null,
                      (value) => onChanged('thumbnail_$i', value),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
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
                ],
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
    required this.urduNameController,
    required this.priceController,
    required this.labelController,
    required this.descriptionController,
    required this.whatYouCanMakeController,
    required this.categoryController,
    required this.availableStockController,
    required this.imageUrlController,
    required this.thumbnailControllers,
  });

  final TextEditingController nameController;
  final TextEditingController urduNameController;
  final TextEditingController priceController;
  final TextEditingController labelController;
  final TextEditingController descriptionController;
  final TextEditingController whatYouCanMakeController;
  final TextEditingController categoryController;
  final TextEditingController availableStockController;
  final TextEditingController imageUrlController;
  final List<TextEditingController> thumbnailControllers;

  factory _ProductDraft.fromProduct(Product product) {
    final thumbnails = List<TextEditingController>.generate(
      4,
      (i) => TextEditingController(
        text: (product.thumbnailImageUrls ?? []).length > i
          ? product.thumbnailImageUrls![i]
          : ''),
    );

    return _ProductDraft(
      nameController: TextEditingController(text: product.name),
      urduNameController: TextEditingController(text: product.urduName ?? ''),
      priceController: TextEditingController(text: product.price.toString()),
      labelController: TextEditingController(text: product.label),
      descriptionController: TextEditingController(text: product.description ?? ''),
      whatYouCanMakeController: TextEditingController(text: product.whatYouCanMake ?? ''),
      categoryController: TextEditingController(text: product.category ?? ''),
      availableStockController: TextEditingController(text: product.availableStock?.toString() ?? ''),
      imageUrlController: TextEditingController(text: product.imageUrl ?? ''),
      thumbnailControllers: thumbnails,
    );
  }

  void update(String field, String value) {
    if (field.startsWith('thumbnail_')) {
      final idx = int.tryParse(field.split('_').last) ?? -1;
      if (idx >= 0 && idx < thumbnailControllers.length) {
        thumbnailControllers[idx].text = value;
      }
      return;
    }

    switch (field) {
      case 'name':
        nameController.text = value;
        break;
      case 'urduName':
        urduNameController.text = value;
        break;
      case 'price':
        priceController.text = value;
        break;
      case 'label':
        labelController.text = value;
        break;
      case 'description':
        descriptionController.text = value;
        break;
      case 'whatYouCanMake':
        whatYouCanMakeController.text = value;
        break;
      case 'category':
        categoryController.text = value;
        break;
      case 'availableStock':
        availableStockController.text = value;
        break;
      case 'imageUrl':
        imageUrlController.text = value;
        break;
    }
  }

  Map<String, dynamic> toPayload(Product product) {
    final payload = <String, dynamic>{
      'name': nameController.text.trim().isEmpty
          ? product.name
          : nameController.text.trim(),
      'price': int.tryParse(priceController.text.trim()) ?? product.price,
      'label': labelController.text.trim().isEmpty
          ? product.label
          : labelController.text.trim(),
      'urduName': urduNameController.text.trim().isEmpty
          ? (product.urduName ?? '')
          : urduNameController.text.trim(),
      'description': descriptionController.text.trim().isEmpty
          ? (product.description ?? '')
          : descriptionController.text.trim(),
      'whatYouCanMake': whatYouCanMakeController.text.trim().isEmpty
          ? (product.whatYouCanMake ?? '')
          : whatYouCanMakeController.text.trim(),
      'category': categoryController.text.trim().isEmpty
          ? (product.category ?? '')
          : categoryController.text.trim(),
      'availableStock': int.tryParse(availableStockController.text.trim()) ?? product.availableStock ?? 0,
    };

    if (imageUrlController.text.trim().isNotEmpty) {
      payload['imageUrl'] = imageUrlController.text.trim();
    }

    final thumbs = thumbnailControllers
      .map((c) => c.text.trim())
      .where((t) => t.isNotEmpty)
      .toList();
    if (thumbs.isNotEmpty) payload['thumbnailImageUrls'] = thumbs;

    return payload;
  }

  void dispose() {
    nameController.dispose();
    urduNameController.dispose();
    priceController.dispose();
    labelController.dispose();
    descriptionController.dispose();
    whatYouCanMakeController.dispose();
    categoryController.dispose();
    availableStockController.dispose();
    imageUrlController.dispose();
    for (final c in thumbnailControllers) {
      c.dispose();
    }
  }
}
