class Mahasiswa {
  final int? id;
  final String nama;
  final String nim;
  final String jurusan;

  Mahasiswa({
    this.id,
    required this.nama,
    required this.nim,
    required this.jurusan,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'nama': nama, 'nim': nim, 'jurusan': jurusan};
  }

  factory Mahasiswa.fromMap(Map<String, dynamic> map) {
    return Mahasiswa(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      nim: map['nim'] as String,
      jurusan: map['jurusan'] as String,
    );
  }
}
