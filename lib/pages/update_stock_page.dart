import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tahap1/components/styles.dart';
import 'package:tahap1/pages/home_page.dart';
import '../config/database_helper.dart';
import '../models/product_model.dart';

class UpdateStockPage extends StatefulWidget {
  final ProductModel product;

  const UpdateStockPage({required this.product, Key? key}) : super(key: key);

  @override
  _UpdateStockPageState createState() => _UpdateStockPageState();
}

class _UpdateStockPageState extends State<UpdateStockPage> {
  late ProductModel _product;
  final stockController = TextEditingController();
  String jenisTransaksi = "Masuk";
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Stok Barang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: ${_product.nama}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Harga: Rp${_product.harga}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Stok Sekarang: ${_product.stok}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Row(
              children: [
                Text('Jenis Transaksi: '),
                DropdownButton<String>(
                  value: jenisTransaksi,
                  items: ['Masuk', 'Keluar'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      jenisTransaksi = newValue!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah Stok Baru',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('Pilih Tanggal: '),
                TextButton.icon(
                  onPressed: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != selectedDate) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  icon: Icon(Icons.calendar_today),
                  label: Text(
                    DateFormat('dd-MM-yyyy').format(selectedDate),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final perubahanStok = int.tryParse(stockController.text);
                if (perubahanStok == null || perubahanStok <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Masukkan jumlah stok yang valid!')),
                  );
                  return;
                } else {
                  if (jenisTransaksi == 'keluar' &&
                      perubahanStok > _product.stok) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Stok keluar tidak bisa lebih dari stok yang ada')));
                  } else {
                    try {
                      await DatabaseHelper().updateBarangAndInsertHistory(
                          _product.id!,
                          perubahanStok,
                          jenisTransaksi,
                          selectedDate);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Stok berhasil diperbarui.')),
                      );
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => HomePage()));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$e')),
                      );
                    }
                  }
                }
              },
              style: buttonStyle,
              child: Text(
                'Update Stok',
                style: textStyle(level: 4, dark: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
