import 'package:hive/hive.dart';
import '../models/mahasiswa.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static late Box<Mahasiswa> _box;

  DatabaseHelper._init();

  Box<Mahasiswa> get box {
    if (!Hive.isBoxOpen('mahasiswaBox')) {
      throw Exception(
        'Hive box tidak terbuka. Pastikan Hive sudah diinisialisasi di main().',
      );
    }
    _box = Hive.box<Mahasiswa>('mahasiswaBox');
    return _box;
  }
}
