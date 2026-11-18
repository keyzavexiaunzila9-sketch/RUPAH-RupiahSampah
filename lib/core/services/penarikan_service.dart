
import 'package:supabase_flutter/supabase_flutter.dart';

class PenarikanService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Mengambil total penghasilan, penarikan, dan saldo kelas.
  Future<Map<String, dynamic>> getSaldoKelas(int idKelas) async {
    final penghasilan = await _supabase
        .from('setoran')
        .select('total_nilai, users!inner(id_kelas)')
        .eq('status', 'disetujui')
        .eq('users.id_kelas', idKelas);

    final penarikan = await _supabase
        .from('penarikan_kas')
        .select('nominal')
        .eq('id_kelas', idKelas);

    final totalPenghasilan = penghasilan.fold<double>(
      0,
      (total, item) =>
          total + (item['total_nilai'] as num? ?? 0).toDouble(),
    );

    final totalPenarikan = penarikan.fold<double>(
      0,
      (total, item) =>
          total + (item['nominal'] as num? ?? 0).toDouble(),
    );

    return {
      'total_penghasilan': totalPenghasilan,
      'total_penarikan': totalPenarikan,
      'saldo_tersedia': totalPenghasilan - totalPenarikan,
    };
  }

  // Melakukan penarikan tunai melalui SQL function.
  Future<void> tarikTunai({
    required int idKelas,
    required int nominal,
    String? keterangan,
  }) async {
    await _supabase.rpc(
      'tarik_tunai_kelas',
      params: {
        'p_id_kelas': idKelas,
        'p_nominal': nominal,
        'p_keterangan':
            keterangan ?? 'Penarikan tunai kas kelas',
      },
    );
  }

  // Mengambil riwayat penarikan kelas.
  Future<List<Map<String, dynamic>>> getRiwayatPenarikan(
    int idKelas,
  ) async {
    final response = await _supabase
        .from('penarikan_kas')
        .select()
        .eq('id_kelas', idKelas)
        .order('tanggal', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
