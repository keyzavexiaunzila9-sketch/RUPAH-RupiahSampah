
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class KelasService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String baseUrl = 'http://localhost:3000';

  // Mengambil data kelas beserta username akun kelas.
  Future<List<Map<String, dynamic>>> getKelas() async {
    final response = await _supabase
        .from('kelas')
        .select()
        .order('id_kelas', ascending: false);

    final kelasList = List<Map<String, dynamic>>.from(response);

    if (kelasList.isEmpty) return kelasList;

    final idKelasList = kelasList
        .map((kelas) => kelas['id_kelas'])
        .toList();

    final usersResponse = await _supabase
        .from('users')
        .select('id_kelas, username')
        .inFilter('id_kelas', idKelasList);

    final usersList = List<Map<String, dynamic>>.from(usersResponse);

    for (final kelas in kelasList) {
      final akun = usersList.where(
        (user) => user['id_kelas'] == kelas['id_kelas'],
      );

      kelas['username'] = akun.isNotEmpty
          ? akun.first['username']
          : null;
    }

    return kelasList;
  }

  // Membuat kelas sekaligus akun login melalui backend.
  Future<void> buatKelasDenganAkun({
    required String namaKelas,
    required String jurusan,
    required String namaWaliKelas,
    required String username,
    required String password,
  }) async {
    final session = _supabase.auth.currentSession;

    if (session == null) {
      throw Exception('Sesi admin tidak ditemukan. Silakan login kembali.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/kelas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${session.accessToken}',
      },
      body: jsonEncode({
        'namaKelas': namaKelas,
        'jurusan': jurusan,
        'namaWaliKelas': namaWaliKelas,
        'username': username,
        'password': password,
      }),
    );

    dynamic hasil;

    try {
      hasil = jsonDecode(response.body);
    } catch (_) {
      throw Exception('Respons backend tidak valid.');
    }

    if (response.statusCode != 201) {
      final pesan = hasil is Map
          ? hasil['message']?.toString()
          : null;

      throw Exception(pesan ?? 'Gagal membuat kelas dan akun.');
    }
  }

  // Mengubah informasi kelas.
  Future<void> updateKelas({
    required int idKelas,
    required String namaKelas,
    required String jurusan,
    required String namaWaliKelas,
  }) async {
    await _supabase.from('kelas').update({
      'nama_kelas': namaKelas,
      'jurusan': jurusan,
      'nama_wali_kelas': namaWaliKelas,
    }).eq('id_kelas', idKelas);
  }

  // Menghapus data kelas.
  Future<void> hapusKelas(int idKelas) async {
    await _supabase
        .from('kelas')
        .delete()
        .eq('id_kelas', idKelas);
  }
}
