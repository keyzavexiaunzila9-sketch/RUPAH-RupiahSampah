
import 'package:flutter/material.dart';
import '../../core/services/kelas_service.dart';

class FormKelasScreen extends StatefulWidget {
  const FormKelasScreen({super.key});

  @override
  State<FormKelasScreen> createState() => _FormKelasScreenState();
}

class _FormKelasScreenState extends State<FormKelasScreen> {
  final formKey = GlobalKey<FormState>();
  final KelasService service = KelasService();

  final namaKelasController = TextEditingController();
  final jurusanController = TextEditingController();
  final namaWaliKelasController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool sembunyikanPassword = true;

  static const Color green = Color(0xFF087A4F);
  static const Color background = Color(0xFFF5F7FC);
  static const Color ink = Color(0xFF26352F);
  static const Color muted = Color(0xFF78857F);
  static const Color border = Color(0xFFD8E2DC);

  @override
  void dispose() {
    namaKelasController.dispose();
    jurusanController.dispose();
    namaWaliKelasController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> simpanKelas() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await service.buatKelasDenganAkun(
        namaKelas: namaKelasController.text.trim(),
        jurusan: jurusanController.text.trim(),
        namaWaliKelas: namaWaliKelasController.text.trim(),
        username: usernameController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data kelas dan akun berhasil dibuat.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal membuat kelas: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: green,
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Kelas',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: green,
              ),
            ),
            Text(
              'SMK Negeri 8 Malang',
              style: TextStyle(
                fontSize: 12,
                color: muted,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDCE6FA)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEAF3FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        color: green,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 9),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tambah Data Kelas',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: ink,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Masukkan informasi kelas dan akun login',
                            style: TextStyle(
                              fontSize: 12,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 17),

                _label('Nama Kelas'),
                _input(
                  controller: namaKelasController,
                  hint: 'Contoh: XII RPL D',
                ),

                const SizedBox(height: 12),

                _label('Jurusan'),
                _input(
                  controller: jurusanController,
                  hint: 'Contoh: Rekayasa Perangkat Lunak',
                ),

                const SizedBox(height: 12),

                _label('Nama Wali Kelas'),
                _input(
                  controller: namaWaliKelasController,
                  hint: 'Masukkan nama wali kelas',
                ),

                const SizedBox(height: 12),

                _label('Username'),
                _input(
                  controller: usernameController,
                  hint: 'Contoh: xiirpld',
                ),

                const SizedBox(height: 12),

                _label('Password'),
                TextFormField(
                  controller: passwordController,
                  obscureText: sembunyikanPassword,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ink,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password wajib diisi.';
                    }

                    if (value.length < 8) {
                      return 'Password minimal 8 karakter.';
                    }

                    return null;
                  },
                  decoration: _decoration(
                    hint: 'Masukkan password minimal 8 karakter',
                  ).copyWith(
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          sembunyikanPassword = !sembunyikanPassword;
                        });
                      },
                      icon: Icon(
                        sembunyikanPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: muted,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 43,
                  child: ElevatedButton.icon(
                    onPressed: loading ? null : simpanKelas,
                    icon: loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.verified_rounded,
                            size: 16,
                          ),
                    label: Text(
                      loading ? 'Menyimpan...' : 'Simpan Data Kelas',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        fontSize: 12,
        color: ink,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Kolom ini wajib diisi.';
        }
        return null;
      },
      decoration: _decoration(hint: hint),
    );
  }

  InputDecoration _decoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 12,
        color: muted,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 12,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: green),
      ),
      errorStyle: const TextStyle(fontSize: 12),
    );
  }
}
