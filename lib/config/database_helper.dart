import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/history_model.dart';
import '../models/product_model.dart';

class DatabaseHelper {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(
      dbPath,
      'Product.db',
    );
    /*await deleteDatabase(path); // Menghapus database lama*/
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS barang (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT,
        deskripsi TEXT,
        kategori TEXT,
        harga INTEGER,
        stok INTEGER,
        imagePath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_barang INTEGER,
        tanggal DATETIME,
        stok_lama INTEGER,
        stok_baru INTEGER,
        perubahan_stok INTEGER,
        jenis_transaksi TEXT
      )
    ''');
  }

  Future<int?> insertProduct(ProductModel product) async {
    try {
      final db = await database;
      return await db.insert('barang', product.toMap());
    } catch (e) {
      throw Exception('Error inserting product: $e');
    }
  }

  Future<List<ProductModel>> getProducts() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> results = await db.query(
        'barang',
        orderBy: 'id DESC',
      );
      return results.map((res) => ProductModel.fromMap(res)).toList();
    } catch (e) {
      throw Exception('Gagal mendapatkan data: $e');
    }
  }

  Future<void> deleteBarang(int id) async {
    final db = await database;
    try {
      await db.transaction((txn) async {
        await txn.delete(
          'history',
          where: 'id_barang = ?',
          whereArgs: [id],
        );
        await txn.delete(
          'barang',
          where: 'id = ?',
          whereArgs: [id],
        );
      });
    } catch (e) {
      throw Exception('Gagal menghapus barang dan riwayat: $e');
    }
  }

  Future<ProductModel?> getProductById(int id) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> results =
          await db.query('barang', where: 'id = ?', whereArgs: [id]);
      if (results.isNotEmpty) {
        return ProductModel.fromMap(results.first);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mendapatkan data produk: $e');
    }
  }

  Future<void> updateBarang(
      int id, int perubahanStok, String jenisTransaksi) async {
    final db = await database;

    try {
      final product = await db.query(
        'barang',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (product.isNotEmpty) {
        int newStock;
        final oldStok = product.first['stok'] as int;

        if (jenisTransaksi == "Masuk") {
          newStock = oldStok + perubahanStok;
        } else {
          if (perubahanStok > oldStok) {
            throw Exception('Stok keluar tidak bisa lebih dari stok yang ada');
          }
          newStock = oldStok - perubahanStok;
        }

        await db.update(
          'barang',
          {'stok': newStock},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    } catch (e) {
      throw Exception('Gagal mengupdate barang: $e');
    }
  }

  Future<void> updateBarangAndInsertHistory(int id, int perubahanStok,
      String jenisTransaksi, DateTime tanggal) async {
    final db = await database;

    try {
      final product = await db.query(
        'barang',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (product.isNotEmpty) {
        final oldStok = product.first['stok'] as int;
        int newStock;

        if (jenisTransaksi == "Masuk") {
          newStock = oldStok + perubahanStok;
        } else {
          if (perubahanStok > oldStok) {
            throw Exception('Stok keluar tidak bisa lebih dari stok yang ada');
          }
          newStock = oldStok - perubahanStok;
        }

        await updateBarang(id, perubahanStok, jenisTransaksi);

        await insertHistory(
            id, oldStok, newStock, perubahanStok, jenisTransaksi, tanggal);
      }
    } catch (e) {
      throw Exception('Gagal memperbarui barang dan memasukkan riwayat: $e');
    }
  }

  Future<void> insertHistory(int id, int stokLama, int stokBaru,
      int perubahanStok, String jenisTransaksi, DateTime tanggal) async {
    final db = await database;

    try {
      await db.insert('history', {
        'id_barang': id,
        'tanggal': tanggal.toIso8601String(),
        'stok_lama': stokLama,
        'stok_baru': stokBaru,
        'perubahan_stok': perubahanStok,
        'jenis_transaksi': jenisTransaksi,
      });
    } catch (e) {
      throw Exception('Gagal memasukkan riwayat transaksi: $e');
    }
  }

  Future<List<HistoryModel>> getHistory(int idBarang) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> results = await db.query(
        'history',
        where: 'id_barang = ?',
        whereArgs: [idBarang],
        orderBy: 'tanggal DESC',
      );
      return results.map((res) => HistoryModel.fromMap(res)).toList();
    } catch (e) {
      throw Exception('Gagal mendapatkan data history: $e');
    }
  }
}
