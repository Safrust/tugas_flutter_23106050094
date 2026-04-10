import 'package:hive/hive.dart';

import '../database/database_helper.dart';
import '../models/mahasiswa.dart';

class MahasiswaService {
  final _helper = DatabaseHelper.instance;

  Box<Mahasiswa> get box => _helper.box;

  Future<List<Mahasiswa>> getAll() async {
    return box.values.toList().reversed.toList();
  }

  Future<void> tambah(Mahasiswa mahasiswa) async {
    await box.add(mahasiswa);
  }

  Future<void> update(int index, Mahasiswa mahasiswa) async {
    if (index >= 0 && index < box.length) {
      await box.putAt(index, mahasiswa);
    }
  }

  Future<void> hapus(int index) async {
    if (index >= 0 && index < box.length) {
      await box.deleteAt(index);
    }
  }
}
