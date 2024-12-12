class ProductModel {
  final int? id;
  final String nama;
  final String deskripsi;
  final String kategori;
  final int harga;
  final int stok;
  final String imagePath;

  ProductModel({
    this.id,
    required this.nama,
    required this.deskripsi,
    required this.kategori,
    required this.harga,
    required this.stok,
    required this.imagePath,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      nama: map['nama'],
      deskripsi: map['deskripsi'],
      kategori: map['kategori'],
      harga: map['harga'],
      stok: map['stok'],
      imagePath: map['imagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String,dynamic> {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'harga': harga,
      'stok': stok,
      'imagePath': imagePath,
    };
  }

}
