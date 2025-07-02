import 'package:flutter/material.dart';
import 'package:frontend/models/product_model.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/loading_indicator.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  ProductModel? _currentProduct;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the product passed as arguments when the route is pushed
    if (_currentProduct == null) {
      _currentProduct =
          ModalRoute.of(context)!.settings.arguments as ProductModel?;
      if (_currentProduct != null) {
        // Pre-fill the form fields with current product data
        _nameController.text = _currentProduct!.name;
        _priceController.text = _currentProduct!.price.toString();
        _stockController.text = _currentProduct!.stock.toString();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  /// Handles the submission of the edit product form.
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _currentProduct != null) {
      final updatedProduct = _currentProduct!.copyWith(
        name: _nameController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
      );

      // Get the ProductProvider instance
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      // Call the updateProduct method
      final success = await productProvider.updateProduct(updatedProduct);

      if (success) {
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully!')),
        );
        Navigator.of(context).pop();
      } else {
        // Show error message if updating failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update product: ${productProvider.errorMessage ?? ''}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentProduct == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('No product selected for editing.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Update Products')),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      CustomTextFormField(
                        controller: _nameController,
                        labelText: 'Product Name',
                        hintText: 'Enter product name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a product name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _priceController,
                        labelText: 'Price',
                        hintText: 'Enter price (e.g., 99.99)',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a price';
                          }
                          if (double.tryParse(value) == null ||
                              double.parse(value) <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _stockController,
                        labelText: 'Stock',
                        hintText: 'Enter stock quantity (e.g., 100)',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter stock quantity';
                          }
                          if (int.tryParse(value) == null ||
                              int.parse(value) < 0) {
                            return 'Please enter a valid non-negative integer';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: productProvider.isLoading
                            ? null
                            : _submitForm,
                        icon: const Icon(Icons.update),
                        label: const Text('Update'),
                      ),
                    ],
                  ),
                ),
              ),
              // Show loading overlay if provider is loading
              if (productProvider.isLoading)
                const Opacity(
                  opacity: 0.8,
                  child: ModalBarrier(dismissible: false, color: Colors.black),
                ),
              if (productProvider.isLoading)
                const Center(child: LoadingIndicator()),
            ],
          );
        },
      ),
    );
  }
}
