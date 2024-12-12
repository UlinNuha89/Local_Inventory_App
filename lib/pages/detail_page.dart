import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tahap1/models/product_model.dart';
import 'package:tahap1/pages/update_stock_page.dart';
import '../components/styles.dart';
import '../config/database_helper.dart';
import '../models/history_model.dart';

class DetailPage extends StatefulWidget {
  final ProductModel product;
  const DetailPage({required this.product, Key? key}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<List<HistoryModel>> _History;
  late ProductModel _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _refreshProduct();
  }

  Future<void> _refreshProduct() async {
    try {
      final updatedProduct =
          await DatabaseHelper().getProductById(_product.id!);
      if (updatedProduct != null) {
        setState(() {
          _product = updatedProduct;
          _History = DatabaseHelper()
              .getHistory(_product.id!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui produk: $e')),
      );
    }
  }

  Future<void> _deleteProduct(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Barang'),
        content: Text('Apakah Anda yakin ingin menghapus barang ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DatabaseHelper().deleteBarang(_product.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Barang berhasil dihapus.')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus barang: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Barang'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _product.imagePath != null
                  ? Image.file(
                      File(_product.imagePath),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.image, size: 200, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                _product.nama,
                style: headerStyle(level: 2),
              ),
              SizedBox(height: 8),
              Text(
                'Kategori: ${_product.kategori}',
                style: textStyle(level: 3),
              ),
              SizedBox(height: 8),
              Text(
                'Harga: Rp${_product.harga}',
                style: textStyle(level: 3),
              ),
              SizedBox(height: 8),
              Text(
                'Stok: ${_product.stok}',
                style: textStyle(level: 3),
              ),
              SizedBox(height: 8),
              Text(
                'Deskripsi:',
                style: textStyle(level: 2),
              ),
              SizedBox(height: 4),
              Text(
                _product.deskripsi,
                style: textStyle(level: 4),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _deleteProduct(context),
                    style: buttonStyle.copyWith(
                      backgroundColor: MaterialStateProperty.all(dangerColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Hapus',
                            style: headerStyle(level: 4, dark: false)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UpdateStockPage(product: _product),
                        ),
                      );
                      if (result == true) {
                        await _refreshProduct();
                      }
                    },
                    style: buttonStyle,
                    child: Row(
                      children: [
                        Icon(Icons.update, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Update Stok',
                            style: headerStyle(level: 4, dark: false)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              FutureBuilder<List<HistoryModel>>(
                future: _History,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Tidak ada data histori.'));
                  }

                  final histories = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: histories.length,
                    itemBuilder: (context, index) {
                      final history = histories[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tanggal : ' +
                                    DateFormat('dd-MM-yyyy')
                                        .format(history.tanggal),
                                style: headerStyle(level: 4),
                              ),
                              Text(
                                'Jenis Transaksi: ${history.jenisTransaksi}',
                                style: headerStyle(level: 4),
                              ),
                              Text(
                                'Stok Lama: ${history.stokLama}',
                                style: headerStyle(level: 4),
                              ),
                              Text(
                                'Stok Baru: ${history.stokBaru}',
                                style: headerStyle(level: 4),
                              ),
                              Text(
                                'Perubahan Stok: ${history.perubahanStok}',
                                style: headerStyle(level: 4),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
