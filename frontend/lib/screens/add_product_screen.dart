import 'package:flutter/material.dart';
import 'package:frontend/models/product_model.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/loading_indicator.dart';

/// AddProductScreen allows users to add a new product to the inventory.
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newProduct = ProductModel(
        name: _nameController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
      );

      // Get the ProductProvider instance
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      // Call the addProduct method
      final success = await productProvider.addProduct(newProduct);

      if (success) {
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );
        Navigator.of(context).pop();
      } else {
        // Show error message if adding failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to add product: ${productProvider.errorMessage ?? ''}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Product')),
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
                        icon: const Icon(Icons.save),
                        label: const Text('Add Product'),
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
