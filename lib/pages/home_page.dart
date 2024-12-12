import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tahap1/models/product_model.dart';
import '../components/styles.dart';
import '../config/database_helper.dart';
import 'add_data_page.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<ProductModel>> _products;

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  void _refreshProducts() {
    setState(() {
      _products = DatabaseHelper().getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Barang'),
      ),
      body: FutureBuilder<List<ProductModel>>(
          future: _products,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Tidak ada data barang.'));
            }
            final products = snapshot.data!;

            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: product.imagePath != null
                        ? Image.file(
                            File(product.imagePath),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.image, size: 50, color: Colors.grey),
                    title: Text(
                      product.nama,
                      style: headerStyle(level: 3),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kategori: ${product.kategori}',
                            style: headerStyle(level: 4)),
                        Text('Harga: Rp${product.harga}',
                            style: headerStyle(level: 4)),
                        Text('Stok: ${product.stok}',
                            style: headerStyle(level: 4)),
                      ],
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(product: product),
                        ),
                      );
                      if (result == true) {
                        _refreshProducts();
                      }
                    },
                  ),
                );
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddDataPage()),
          );
          if (result == true) {
            _refreshProducts();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
