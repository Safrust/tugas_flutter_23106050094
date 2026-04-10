import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/mahasiswa.dart';
import '../models/prodi.dart';
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
  int? editingIndex;
  int? selectedProdiId;

  final TextEditingController namaController = TextEditingController();
  final TextEditingController nimController = TextEditingController();

  Future<void> simpanMahasiswa() async {
    final nama = namaController.text.trim();
    final nim = nimController.text.trim();

    if (nama.isEmpty || nim.isEmpty || selectedProdiId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua field harus diisi')));
      return;
    }

    try {
      final mahasiswa = Mahasiswa(
        nama: nama,
        nim: nim,
        prodiId: selectedProdiId!,
      );

      if (editingIndex == null) {
        await service.tambah(mahasiswa);
      } else {
        await service.update(editingIndex!, mahasiswa);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
      return;
    }

    clearForm();
  }

  void isiFormUntukEdit(int index, Mahasiswa mahasiswa) {
    setState(() {
      editingIndex = index;
      namaController.text = mahasiswa.nama;
      nimController.text = mahasiswa.nim;
      selectedProdiId = mahasiswa.prodiId;
    });
  }

  Future<void> hapusMahasiswa(int index) async {
    try {
      await service.hapus(index);
      if (editingIndex == index) {
        clearForm();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus data: $e')));
    }
  }

  void clearForm() {
    namaController.clear();
    nimController.clear();
    setState(() {
      selectedProdiId = null;
      editingIndex = null;
    });
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = service.box;
    final prodiBox = Hive.box<Prodi>('prodiBox');

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
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              key: ValueKey(selectedProdiId),
              initialValue: selectedProdiId,
              hint: const Text('Pilih Prodi'),
              items: List.generate(prodiBox.length, (index) {
                final prodi = prodiBox.getAt(index);
                return DropdownMenuItem(
                  value: index,
                  child: Text(prodi!.namaProdi),
                );
              }),
              onChanged: (value) {
                setState(() {
                  selectedProdiId = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Prodi'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: simpanMahasiswa,
                  child: Text(editingIndex == null ? 'Simpan' : 'Update'),
                ),
                const SizedBox(width: 10),
                if (editingIndex != null)
                  ElevatedButton(
                    onPressed: clearForm,
                    child: const Text('Batal'),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (context, Box<Mahasiswa> box, _) {
                  if (box.isEmpty) {
                    return const Center(
                      child: Text('Belum ada data mahasiswa'),
                    );
                  }

                  final items = box.values.toList().reversed.toList();

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final data = items[index];
                      final boxIndex = box.length - 1 - index;
                      final key = box.keyAt(boxIndex);
                      final prodi = prodiBox.getAt(data.prodiId);

                      return Card(
                        child: ListTile(
                          title: Text(data.nama),
                          subtitle: Text(
                            'NIM: ${data.nim} | ${prodi?.namaProdi ?? '-'}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                onPressed: () {
                                  isiFormUntukEdit(key as int, data);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  hapusMahasiswa(key as int);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
