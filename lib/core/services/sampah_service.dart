
import 'package:flutter_application_1/core/config/supabase_config.dart';

class SampahService {
  // ==========================================
  // 1. MENGAMBIL SEMUA DATA SAMPAH
  // ==========================================
  Future<List<Map<String, dynamic>>> getAllSampah() async {
    final response = await supabase
        .from('sampah')
        .select()
        .order('id_sampah', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // ==========================================
  // 2. MENGAMBIL DATA SAMPAH AKTIF
  // ==========================================
  Future<List<Map<String, dynamic>>> getSampahAktif() async {
    final response = await supabase
        .from('sampah')
        .select()
        .eq('status', true)
        .order('nama_sampah', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  // ==========================================
  // 3. MENAMBAHKAN DATA SAMPAH
  // ==========================================
  Future<void> tambahSampah({
    required String nama,
    required String kategori,
    required double harga,
    required String deskripsi,
  }) async {
    await supabase.from('sampah').insert({
      'nama_sampah': nama,
      'kategori': kategori,
      'harga_per_kg': harga,
      'satuan': 'kg',
      'deskripsi': deskripsi,
      'status': true,
    });
  }

  // ==========================================
  // 4. MENGUBAH DATA SAMPAH
  // ==========================================
  Future<void> editSampah({
    required int id,
    required String nama,
    required String kategori,
    required double harga,
    required String deskripsi,
    required bool status,
  }) async {
    await supabase
        .from('sampah')
        .update({
          'nama_sampah': nama,
          'kategori': kategori,
          'harga_per_kg': harga,
          'deskripsi': deskripsi,
          'status': status,
        })
        .eq('id_sampah', id);
  }

  // ==========================================
  // 5. MENGHAPUS DATA SAMPAH
  // ==========================================
  Future<void> hapusSampah(int id) async {
    await supabase
        .from('sampah')
        .delete()
        .eq('id_sampah', id);
  }

  // ==========================================
  // 6. MENONAKTIFKAN DATA SAMPAH
  // ==========================================
  Future<void> nonaktifkanSampah(int id) async {
    await supabase
        .from('sampah')
        .update({'status': false})
        .eq('id_sampah', id);
  }

  // ==========================================
  // 7. MENGAKTIFKAN KEMBALI DATA SAMPAH
  // ==========================================
  Future<void> aktifkanSampah(int id) async {
    await supabase
        .from('sampah')
        .update({'status': true})
        .eq('id_sampah', id);
  }
}
