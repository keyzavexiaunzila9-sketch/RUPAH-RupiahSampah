
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifikasiService {
  final SupabaseClient _supabase = Supabase.instance.client;


  Future<String?> _buatSignedFotoUrl(dynamic fotoPath) async {
    if (fotoPath == null || fotoPath.toString().trim().isEmpty) {
      return null;
    }

    final path = fotoPath.toString().trim();

    // Jika sudah berupa URL lengkap, gunakan langsung.
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    try {
      final signedUrl = await _supabase.storage
          .from('bukti-setoran')
          .createSignedUrl(path, 3600);

      return signedUrl;
    } catch (e) {
      debugPrint('Gagal membuat Signed URL foto: $e');
      return null;
    }
  }

  // =========================================================
  // DATA VERIFIKASI
  // =========================================================

  Future<List<Map<String, dynamic>>> getVerifikasi() async {
    final response = await _supabase
        .from('verifikasi')
        .select()
        .order('id_verifikasi', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getVerifikasiBySetoran(
    int idSetoran,
  ) async {
    final response = await _supabase
        .from('verifikasi')
        .select()
        .eq('id_setoran', idSetoran)
        .order('id_verifikasi', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // =========================================================
  // DATA SETORAN UNTUK HALAMAN VERIFIKASI
  // =========================================================

  Future<List<Map<String, dynamic>>> getDataSetoran() async {
    final setoranResponse = await _supabase
        .from('setoran')
        .select()
        .order('tanggal', ascending: false);

    final setoranList =
        List<Map<String, dynamic>>.from(setoranResponse);

    if (setoranList.isEmpty) return [];

    // Ubah path foto menjadi Signed URL.
    for (final setoran in setoranList) {
      setoran['foto_url'] = await _buatSignedFotoUrl(
        setoran['foto_url'],
      );
    }

    // Ambil ID pengguna.
    final userIds = setoranList
        .map((item) => item['id_user'])
        .where((id) => id != null)
        .toSet()
        .toList();

    List<Map<String, dynamic>> userList = [];

    if (userIds.isNotEmpty) {
      final response = await _supabase
          .from('users')
          .select('id_user, username, id_kelas')
          .inFilter('id_user', userIds);

      userList = List<Map<String, dynamic>>.from(response);
    }

    // Ambil ID kelas.
    final kelasIds = userList
        .map((item) => item['id_kelas'])
        .where((id) => id != null)
        .toSet()
        .toList();

    List<Map<String, dynamic>> kelasList = [];

    if (kelasIds.isNotEmpty) {
      final response = await _supabase
          .from('kelas')
          .select('id_kelas, nama_kelas, tingkat, jurusan')
          .inFilter('id_kelas', kelasIds);

      kelasList = List<Map<String, dynamic>>.from(response);
    }

    // Ambil detail setoran.
    final setoranIds = setoranList
        .map((item) => item['id_setoran'])
        .toList();

    final detailResponse = await _supabase
        .from('detail_setoran')
        .select('id_detail, id_setoran, id_sampah, berat_kg')
        .inFilter('id_setoran', setoranIds);

    final detailList =
        List<Map<String, dynamic>>.from(detailResponse);

    // Ambil ID sampah.
    final sampahIds = detailList
        .map((item) => item['id_sampah'])
        .where((id) => id != null)
        .toSet()
        .toList();

    List<Map<String, dynamic>> sampahList = [];

    if (sampahIds.isNotEmpty) {
      final response = await _supabase
          .from('sampah')
          .select(
            'id_sampah, nama_sampah, kategori, harga_per_kg',
          )
          .inFilter('id_sampah', sampahIds);

      sampahList = List<Map<String, dynamic>>.from(response);
    }

    // Gabungkan seluruh data.
    return setoranList.map((setoran) {
      final user = userList.firstWhere(
        (item) =>
            item['id_user']?.toString() ==
            setoran['id_user']?.toString(),
        orElse: () => {},
      );

      final kelas = kelasList.firstWhere(
        (item) =>
            item['id_kelas']?.toString() ==
            user['id_kelas']?.toString(),
        orElse: () => {},
      );

      final detail = detailList
          .where(
            (item) =>
                item['id_setoran']?.toString() ==
                setoran['id_setoran']?.toString(),
          )
          .map((item) {
        final sampah = sampahList.firstWhere(
          (s) =>
              s['id_sampah']?.toString() ==
              item['id_sampah']?.toString(),
          orElse: () => {},
        );

        return {
          ...item,
          'nama_sampah': sampah['nama_sampah'] ?? '-',
          'kategori': sampah['kategori'] ?? '-',
          'harga_per_kg': sampah['harga_per_kg'] ?? 0,
        };
      }).toList();

      return {
        ...setoran,
        'username': user['username'] ?? '-',
        'nama_kelas': kelas['nama_kelas'] ?? '-',
        'tingkat': kelas['tingkat'] ?? '',
        'jurusan': kelas['jurusan'] ?? '',
        'detail': detail,
      };
    }).toList();
  }

  // =========================================================
  // BUKTI PENOLAKAN
  // =========================================================

  Future<Map<String, dynamic>> getBuktiPenolakan(
    int idSetoran,
  ) async {
    final setoranResponse = await _supabase
        .from('setoran')
        .select()
        .eq('id_setoran', idSetoran)
        .maybeSingle();

    if (setoranResponse == null) {
      throw Exception('Data setoran tidak ditemukan.');
    }

    final setoran =
        Map<String, dynamic>.from(setoranResponse);

    // Ubah path foto menjadi Signed URL.
    setoran['foto_url'] = await _buatSignedFotoUrl(
      setoran['foto_url'],
    );

    // Ambil verifikasi terakhir.
    final verifikasiResponse = await _supabase
        .from('verifikasi')
        .select()
        .eq('id_setoran', idSetoran)
        .eq('status_verifikasi', 'ditolak')
        .order('id_verifikasi', ascending: false)
        .limit(1)
        .maybeSingle();

    if (verifikasiResponse == null) {
      throw Exception('Data penolakan tidak ditemukan.');
    }

    final verifikasi =
        Map<String, dynamic>.from(verifikasiResponse);

    // Ambil data pengguna.
    final userResponse = await _supabase
        .from('users')
        .select('id_user, username, id_kelas')
        .eq('id_user', setoran['id_user'])
        .maybeSingle();

    final user = userResponse == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(userResponse);

    // Ambil data kelas.
    Map<String, dynamic> kelas = {};

    if (user['id_kelas'] != null) {
      final kelasResponse = await _supabase
          .from('kelas')
          .select('nama_kelas, tingkat, jurusan')
          .eq('id_kelas', user['id_kelas'])
          .maybeSingle();

      kelas = kelasResponse == null
          ? {}
          : Map<String, dynamic>.from(kelasResponse);
    }

    // Ambil detail sampah.
    final detailResponse = await _supabase
        .from('detail_setoran')
        .select('id_detail, id_sampah, berat_kg')
        .eq('id_setoran', idSetoran);

    final detailList =
        List<Map<String, dynamic>>.from(detailResponse);

    final sampahIds = detailList
        .map((item) => item['id_sampah'])
        .where((id) => id != null)
        .toSet()
        .toList();

    List<Map<String, dynamic>> sampahList = [];

    if (sampahIds.isNotEmpty) {
      final sampahResponse = await _supabase
          .from('sampah')
          .select('id_sampah, nama_sampah, kategori')
          .inFilter('id_sampah', sampahIds);

      sampahList =
          List<Map<String, dynamic>>.from(sampahResponse);
    }

    final detail = detailList.map((item) {
      final sampah = sampahList.firstWhere(
        (s) =>
            s['id_sampah']?.toString() ==
            item['id_sampah']?.toString(),
        orElse: () => {},
      );

      return {
        ...item,
        'nama_sampah': sampah['nama_sampah'] ?? '-',
        'kategori': sampah['kategori'] ?? '-',
      };
    }).toList();

    // Ambil nama admin.
    Map<String, dynamic> admin = {};

    if (verifikasi['id_admin'] != null) {
      final adminResponse = await _supabase
          .from('users')
          .select('username')
          .eq('id_user', verifikasi['id_admin'])
          .maybeSingle();

      admin = adminResponse == null
          ? {}
          : Map<String, dynamic>.from(adminResponse);
    }

    return {
      ...setoran,
      'username': user['username'] ?? '-',
      'nama_kelas': kelas['nama_kelas'] ?? '-',
      'tingkat': kelas['tingkat'] ?? '',
      'jurusan': kelas['jurusan'] ?? '',
      'detail': detail,
      'kategori_penolakan':
          verifikasi['kategori_penolakan'] ?? '-',
      'catatan_penolakan': verifikasi['catatan'] ?? '-',
      'tindak_lanjut': verifikasi['tindak_lanjut'] ?? [],
      'tanggal_verifikasi': verifikasi['tanggal'],
      'nama_admin': admin['username'] ?? '-',
    };
  }

  // =========================================================
  // TAMBAH VERIFIKASI
  // =========================================================

  Future<void> tambahVerifikasi({
    required int idSetoran,
    required String idAdmin,
    required String statusVerifikasi,
    String? catatan,
  }) async {
    await _supabase.from('verifikasi').insert({
      'id_setoran': idSetoran,
      'id_admin': idAdmin,
      'status_verifikasi': statusVerifikasi,
      'tanggal': DateTime.now().toUtc().toIso8601String(),
      'catatan': catatan,
    });
  }

  // =========================================================
  // UPDATE VERIFIKASI
  // =========================================================

  Future<void> updateVerifikasi({
    required int idVerifikasi,
    required String statusVerifikasi,
    String? catatan,
  }) async {
    await _supabase.from('verifikasi').update({
      'status_verifikasi': statusVerifikasi,
      'catatan': catatan,
      'tanggal': DateTime.now().toUtc().toIso8601String(),
    }).eq('id_verifikasi', idVerifikasi);
  }

  // =========================================================
  // VERIFIKASI SETORAN
  // =========================================================

  Future<void> verifikasiSetoran({
    required int idSetoran,
    required String status,
    String? catatan,
  }) async {
    final adminId = _supabase.auth.currentUser?.id;

    if (adminId == null) {
      throw Exception('Sesi admin tidak ditemukan.');
    }

    if (status != 'disetujui') {
      throw Exception(
        'Gunakan method tolakSetoran untuk penolakan.',
      );
    }

    final setoran = await _supabase
        .from('setoran')
        .select('status')
        .eq('id_setoran', idSetoran)
        .maybeSingle();

    if (setoran == null) {
      throw Exception('Data setoran tidak ditemukan.');
    }

    if (setoran['status'] != 'menunggu') {
      throw Exception('Setoran ini sudah diverifikasi.');
    }

    await tambahVerifikasi(
      idSetoran: idSetoran,
      idAdmin: adminId,
      statusVerifikasi: status,
      catatan: catatan,
    );

    await _supabase.from('setoran').update({
      'status': status,
      'catatan': catatan,
    }).eq('id_setoran', idSetoran);
  }

  // =========================================================
  // TOLAK SETORAN
  // =========================================================

  Future<void> tolakSetoran({
    required int idSetoran,
    required String kategoriPenolakan,
    required String catatan,
    required List<String> tindakLanjut,
  }) async {
    final adminId = _supabase.auth.currentUser?.id;

    if (adminId == null) {
      throw Exception('Sesi admin tidak ditemukan.');
    }

    final setoran = await _supabase
        .from('setoran')
        .select('status')
        .eq('id_setoran', idSetoran)
        .maybeSingle();

    if (setoran == null) {
      throw Exception('Data setoran tidak ditemukan.');
    }

    if (setoran['status'] != 'menunggu') {
      throw Exception('Setoran ini sudah diverifikasi.');
    }

    // Simpan hasil penolakan.
    await _supabase.from('verifikasi').insert({
      'id_setoran': idSetoran,
      'id_admin': adminId,
      'status_verifikasi': 'ditolak',
      'tanggal': DateTime.now().toUtc().toIso8601String(),
      'kategori_penolakan': kategoriPenolakan,
      'catatan': catatan,
      'tindak_lanjut': tindakLanjut,
    });

    // Perbarui status setoran.
    await _supabase.from('setoran').update({
      'status': 'ditolak',
      'catatan': catatan,
    }).eq('id_setoran', idSetoran);
  }

  Future<void> hapusVerifikasi(int idVerifikasi) async {
    await _supabase
        .from('verifikasi')
        .delete()
        .eq('id_verifikasi', idVerifikasi);
  }
}
