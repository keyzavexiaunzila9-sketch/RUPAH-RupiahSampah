
import 'package:supabase_flutter/supabase_flutter.dart';

class SetoranService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Menampilkan semua data setoran
  Future<List<Map<String, dynamic>>> getSetoran() async {
    final response = await _supabase
        .from('setoran')
        .select()
        .order('id_setoran', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Menampilkan setoran berdasarkan ID user
  Future<List<Map<String, dynamic>>> getSetoranByUser(
    String idUser,
  ) async {
    final response = await _supabase
        .from('setoran')
        .select()
        .eq('id_user', idUser)
        .order('id_setoran', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Menambahkan setoran baru
  Future<int> tambahSetoran({
    required String idUser,
    required DateTime tanggal,
    required String status,
    String? catatan,
  }) async {
    final response = await _supabase
        .from('setoran')
        .insert({
          'id_user': idUser,
          'tanggal': tanggal.toIso8601String(),
          'status': status,
          'catatan': catatan,
          'total_berat': 0,
          'total_nilai': 0,
        })
        .select('id_setoran')
        .single();

    return response['id_setoran'] as int;
  }

  // Mengubah status dan catatan setoran
  Future<void> updateSetoran({
    required int idSetoran,
    required String status,
    String? catatan,
  }) async {
    await _supabase.from('setoran').update({
      'status': status,
      'catatan': catatan,
    }).eq('id_setoran', idSetoran);
  }

  // Menambahkan detail sampah ke setoran
  Future<void> tambahDetailSetoran({
    required int idSetoran,
    required int idSampah,
    required double beratKg,
  }) async {
    await _supabase.from('detail_setoran').insert({
      'id_setoran': idSetoran,
      'id_sampah': idSampah,
      'berat_kg': beratKg,
    });
  }

  // Menampilkan detail setoran
  Future<List<Map<String, dynamic>>> getDetailSetoran(
    int idSetoran,
  ) async {
    final response = await _supabase
        .from('detail_setoran')
        .select()
        .eq('id_setoran', idSetoran);

    return List<Map<String, dynamic>>.from(response);
  }

  // Menghapus detail setoran
  Future<void> hapusDetailSetoran(int idDetail) async {
    await _supabase
        .from('detail_setoran')
        .delete()
        .eq('id_detail', idDetail);
  }

  // Menghapus setoran beserta detailnya
  Future<void> hapusSetoran(int idSetoran) async {
    await _supabase
        .from('detail_setoran')
        .delete()
        .eq('id_setoran', idSetoran);

    await _supabase
        .from('setoran')
        .delete()
        .eq('id_setoran', idSetoran);
  }
}
