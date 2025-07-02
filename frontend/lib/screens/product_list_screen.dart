import 'package:flutter/material.dart';
import 'package:frontend/models/product_model.dart';
import 'package:frontend/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import '../providers/product_provider.dart';
import '../widgets/error_message.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _searchSubject = PublishSubject<String>();

  @override
  void initState() {
    super.initState();
    // Fetch products when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });

    // Set up debouncing for search input
    _searchSubject.debounceTime(const Duration(milliseconds: 500)).listen((
      query,
    ) {
      Provider.of<ProductProvider>(
        context,
        listen: false,
      ).setSearchQuery(query);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchSubject.close();
    super.dispose();
  }

  /// Shows a confirmation dialog before deleting a product.
  Future<void> _confirmDelete(
    BuildContext context,
    ProductModel product,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete "${product.name}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      final success = await productProvider.deleteProduct(product.id!);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} deleted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete ${product.name}. ${productProvider.errorMessage ?? ''}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product List API')),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search by Name',
                          hintText: 'Enter product name',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _searchSubject.add('');
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          _searchSubject.add(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<ProductSortOrder>(
                      value: productProvider.sortOrder,
                      icon: const Icon(Icons.sort),
                      elevation: 16,
                      style: const TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (ProductSortOrder? newValue) {
                        if (newValue != null) {
                          productProvider.setSortOrder(newValue);
                        }
                      },
                      items: const <DropdownMenuItem<ProductSortOrder>>[
                        DropdownMenuItem(
                          value: ProductSortOrder.none,
                          child: Text('Sort: None'),
                        ),
                        DropdownMenuItem(
                          value: ProductSortOrder.nameAsc,
                          child: Text('Name (A-Z)'),
                        ),
                        DropdownMenuItem(
                          value: ProductSortOrder.nameDesc,
                          child: Text('Name (Z-A)'),
                        ),
                        DropdownMenuItem(
                          value: ProductSortOrder.priceAsc,
                          child: Text('Price (Low to High)'),
                        ),
                        DropdownMenuItem(
                          value: ProductSortOrder.priceDesc,
                          child: Text('Price (High to Low)'),
                        ),
                        DropdownMenuItem(
                          value: ProductSortOrder.stockAsc,
                          child: Text('Stock (Low to High)'),
                        ),
                        DropdownMenuItem(
                          value: ProductSortOrder.stockDesc,
                          child: Text('Stock (High to Low)'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    if (productProvider.errorMessage != null)
                      Center(
                        child: ErrorMessage(
                          message: productProvider.errorMessage!,
                          onRetry: () => productProvider.fetchProducts(),
                        ),
                      )
                    else if (productProvider.products.isEmpty &&
                        !productProvider.isLoading)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No products found.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => productProvider.fetchProducts(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                            ),
                          ],
                        ),
                      )
                    else
                      RefreshIndicator(
                        onRefresh: () => productProvider.fetchProducts(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: productProvider.products.length,
                          itemBuilder: (context, index) {
                            final product = productProvider.products[index];
                            return Card(
                              margin: EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 4.0,
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 16.0,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blueAccent
                                      .withOpacity(0.1),
                                  child: Text(
                                    product.name[0].toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Price: \$${product.price.toStringAsFixed(2)}',
                                    ),
                                    Text('Stock: ${product.stock}'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pushNamed(
                                          '/edit_product',
                                          arguments: product,
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _confirmDelete(context, product),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    // Show loading overlay if provider is loading
                    if (productProvider.isLoading)
                      const Opacity(
                        opacity: 0.8,
                        child: ModalBarrier(
                          dismissible: false,
                          color: Colors.grey,
                        ),
                      ),
                    if (productProvider.isLoading)
                      const Center(child: LoadingIndicator()),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the add product screen
          Navigator.of(context).pushNamed('/add_product');
        },
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }
}
