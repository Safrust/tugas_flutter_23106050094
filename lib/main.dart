import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/mahasiswa.dart';
import 'models/prodi.dart';
import 'pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if (await Hive.boxExists('mahasiswaBox')) {
    await Hive.deleteBoxFromDisk('mahasiswaBox');
  }

  Hive.registerAdapter(MahasiswaAdapter());
  Hive.registerAdapter(ProdiAdapter());

  await Hive.openBox<Mahasiswa>('mahasiswaBox');
  await Hive.openBox<Prodi>('prodiBox');

  // Tambahkan data awal prodi jika belum ada
  var prodiBox = Hive.box<Prodi>('prodiBox');
  if (prodiBox.isEmpty) {
    prodiBox.addAll([
      Prodi(namaProdi: 'Informatika'),
      Prodi(namaProdi: 'Biologi'),
      Prodi(namaProdi: 'Fisika'),
    ]);
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
    );
  }
}
