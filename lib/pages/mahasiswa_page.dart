import 'package:flutter/material.dart';

import '../models/mahasiswa.dart';
import '../services/auth_service.dart';
import '../services/mahasiswa_service.dart';
import 'login_page.dart';

class MahasiswaPage extends StatefulWidget {
  const MahasiswaPage({super.key});

  @override
  State<MahasiswaPage> createState() => _MahasiswaPageState();
}

class _MahasiswaPageState extends State<MahasiswaPage> {
  final MahasiswaService service = MahasiswaService();
  final AuthService _authService = AuthService();
  List<Mahasiswa> data = [];
  int? editingId;

  final TextEditingController namaController = TextEditingController();
  final TextEditingController nimController = TextEditingController();
  final TextEditingController jurusanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final result = await service.getAll();
      if (!mounted) return;
      setState(() {
        data = result;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
    }
  }

  Future<void> simpanMahasiswa() async {
    final nama = namaController.text.trim();
    final nim = nimController.text.trim();
    final jurusan = jurusanController.text.trim();

    if (nama.isEmpty || nim.isEmpty || jurusan.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua field harus diisi')));
      return;
    }

    try {
      if (editingId == null) {
        final mahasiswa = Mahasiswa(nama: nama, nim: nim, jurusan: jurusan);
        await service.tambah(mahasiswa);
      } else {
        final mahasiswa = Mahasiswa(
          id: editingId,
          nama: nama,
          nim: nim,
          jurusan: jurusan,
        );
        await service.update(mahasiswa);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
      return;
    }

    namaController.clear();
    nimController.clear();
    jurusanController.clear();

    setState(() {
      editingId = null;
    });

    await loadData();
  }

  void isiFormUntukEdit(Mahasiswa mahasiswa) {
    setState(() {
      editingId = mahasiswa.id;
      namaController.text = mahasiswa.nama;
      nimController.text = mahasiswa.nim;
      jurusanController.text = mahasiswa.jurusan;
    });
  }

  Future<void> hapusMahasiswa(int id) async {
    try {
      await service.hapus(id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus data: $e')));
      return;
    }

    if (editingId == id) {
      namaController.clear();
      nimController.clear();
      jurusanController.clear();
      setState(() {
        editingId = null;
      });
    }

    await loadData();
  }

  Future<void> logout() async {
    await _authService.logout();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    namaController.dispose();
    nimController.dispose();
    jurusanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Mahasiswa'),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: nimController,
              decoration: const InputDecoration(labelText: 'NIM'),
            ),
            TextField(
              controller: jurusanController,
              decoration: const InputDecoration(labelText: 'Jurusan'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: simpanMahasiswa,
              child: const Text('Simpan'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: data.isEmpty
                  ? const Center(child: Text('Belum ada data mahasiswa'))
                  : ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final mhs = data[index];
                        return ListTile(
                          title: Text(mhs.nama),
                          subtitle: Text('${mhs.nim} - ${mhs.jurusan}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  isiFormUntukEdit(mhs);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  if (mhs.id != null) {
                                    hapusMahasiswa(mhs.id!);
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
