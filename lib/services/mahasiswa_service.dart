import '../database/database_helper.dart';
import '../models/mahasiswa.dart';

class MahasiswaService {
  Future<List<Mahasiswa>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('mahasiswa', orderBy: 'id DESC');
    return result.map((e) => Mahasiswa.fromMap(e)).toList();
  }

  Future<void> tambah(Mahasiswa mahasiswa) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('mahasiswa', mahasiswa.toMap());
  }

  Future<void> update(Mahasiswa mahasiswa) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'mahasiswa',
      mahasiswa.toMap(),
      where: 'id = ?',
      whereArgs: [mahasiswa.id],
    );
  }

  Future<void> hapus(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('mahasiswa', where: 'id = ?', whereArgs: [id]);
  }
}
