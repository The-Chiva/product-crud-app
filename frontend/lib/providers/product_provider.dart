import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/models/product_model.dart'; // Using ProductModel
import 'package:http/http.dart' as http;

/// Enum to define sorting options for products.
enum ProductSortOrder {
  none,
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
  stockAsc,
  stockDesc,
}

class ProductProvider with ChangeNotifier {
  // Base URL for the backend API.
  /*
    --> For Android Emulators: 'http://10.0.2.2:3000/api/products'
    --> For iOS Emulators: 'http://localhost:3000/api/products'
    --> For Android Real Devices: 'http://<your-ip-address>:3000/api/products' example: http://192.168.9.39:3000/api/products
   */
  static const String _baseUrl = 'http://10.0.2.2:3000/api/products';

  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  ProductSortOrder _sortOrder = ProductSortOrder.none;

  // Getters for filtered products and state
  List<ProductModel> get products => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  ProductSortOrder get sortOrder => _sortOrder;

  /// Sets the loading state and notifies listeners.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Sets the error message and notifies listeners.
  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Sets the search query and applies filtering.
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFiltersAndSorting();
  }

  /// Sets the sort order and applies sorting.
  void setSortOrder(ProductSortOrder order) {
    _sortOrder = order;
    _applyFiltersAndSorting();
  }

  /// Applies the current search query and sort order to the product list.
  void _applyFiltersAndSorting() {
    List<ProductModel> currentProducts = List.from(_allProducts);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      currentProducts = currentProducts.where((product) {
        return product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply sorting
    switch (_sortOrder) {
      case ProductSortOrder.nameAsc:
        currentProducts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case ProductSortOrder.nameDesc:
        currentProducts.sort((a, b) => b.name.compareTo(a.name));
        break;
      case ProductSortOrder.priceAsc:
        currentProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOrder.priceDesc:
        currentProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOrder.stockAsc:
        currentProducts.sort((a, b) => a.stock.compareTo(b.stock));
        break;
      case ProductSortOrder.stockDesc:
        currentProducts.sort((a, b) => b.stock.compareTo(a.stock));
        break;
      case ProductSortOrder.none:
        break;
    }

    _filteredProducts = currentProducts;
    notifyListeners();
  }

  /// Fetches all products from the backend API.
  Future<void> fetchProducts() async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        List<dynamic> productJson = json.decode(response.body);
        _allProducts = productJson
            .map((json) => ProductModel.fromJson(json))
            .toList();
        _applyFiltersAndSorting();
      } else {
        _setErrorMessage(
          'Failed to load products: ${response.statusCode} ${response.reasonPhrase}',
        );
        log('Failed to load products: ${response.body}');
      }
    } catch (e) {
      _setErrorMessage('Network error: $e');
      log('Error fetching products: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Adds a new product to the backend API.
  Future<bool> addProduct(ProductModel product) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 201) {
        // If successful, re-fetch products to update the list
        await fetchProducts();
        return true;
      } else if (response.statusCode == 409) {
        try {
          final errorBody = json.decode(response.body);
          _setErrorMessage(
            errorBody['message'] ?? 'Product name have already exists',
          );
          log('Duplicate product error: ${response.body}');
        } catch (e) {
          _setErrorMessage(
            'Failed to add product: Product name \'${product.name}\' error.',
          );
          log('Error decoding 409 response body: $e');
        }
        return false;
      } else {
        _setErrorMessage(
          'Failed to add product: ${response.statusCode} ${response.reasonPhrase}',
        );
        log('Failed to add product: ${response.body}');
        return false;
      }
    } catch (e) {
      _setErrorMessage('Network error: $e');
      log('Error adding product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing product via the backend API.
  Future<bool> updateProduct(ProductModel product) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/${product.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 200) {
        await fetchProducts(); 
        return true;
      } else {
        _setErrorMessage(
          'Failed to update product: ${response.statusCode} ${response.reasonPhrase}',
        );
        log('Failed to update product: ${response.body}');
        return false;
      }
    } catch (e) {
      _setErrorMessage('Network error: $e');
      log('Error updating product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes a product from the backend API by its ID.
  Future<bool> deleteProduct(int id) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$id'));

      if (response.statusCode == 200) {
        _allProducts.removeWhere((product) => product.id == id);
        _applyFiltersAndSorting();
        return true;
      } else {
        _setErrorMessage(
          'Failed to delete product: ${response.statusCode} ${response.reasonPhrase}',
        );
        log('Failed to delete product: ${response.body}');
        return false;
      }
    } catch (e) {
      _setErrorMessage('Network error: $e');
      log('Error deleting product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
