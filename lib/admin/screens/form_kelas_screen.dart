import 'package:flutter/material.dart';

class FormKelasScreen extends StatefulWidget {
  const FormKelasScreen({super.key});

  @override
  State<FormKelasScreen> createState() => _FormKelasScreenState();
}

class _FormKelasScreenState extends State<FormKelasScreen> {
  final formKey = GlobalKey<FormState>();

  final namaKelasController = TextEditingController();
  final waliKelasController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  static const Color green = Color(0xFF087A4F);
  static const Color background = Color(0xFFF5F7FC);
  static const Color ink = Color(0xFF26352F);
  static const Color muted = Color(0xFF78857F);
  static const Color border = Color(0xFFD8E2DC);

  @override
  void dispose() {
    namaKelasController.dispose();
    waliKelasController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void simpanKelas() {
    if (!formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Akun kelas berhasil dibuat.'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
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
              'Data & Akun Kelas',
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
          constraints: const BoxConstraints(minHeight: 420),
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
                        Icons.person_add_alt_1_rounded,
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
                            'Daftarkan Akun Kelas Baru',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: ink,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Terbitkan akun siswa',
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

                _label('Nama Kelas & Jurusan'),
                _input(
                  controller: namaKelasController,
                  hint: 'Contoh: XII RPL',
                  validatorMessage: 'Nama kelas wajib diisi.',
                ),

                const SizedBox(height: 12),

                _label('Wali Kelas'),
                _input(
                  controller: waliKelasController,
                  hint: 'Masukkan nama wali kelas',
                  validatorMessage: 'Nama wali kelas wajib diisi.',
                ),

                const SizedBox(height: 12),

                _label('Username Sistem'),
                _input(
                  controller: usernameController,
                  hint: '@',
                  validatorMessage: 'Username wajib diisi.',
                ),

                const SizedBox(height: 12),

                _label('Password'),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ink,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Password wajib diisi.';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter.';
                    }
                    return null;
                  },
                  decoration: _decoration(
                    hint: 'Masukkan password',
                  ).copyWith(
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18,
                        color: muted,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 43,
                  child: ElevatedButton.icon(
                    onPressed: simpanKelas,
                    icon: const Icon(
                      Icons.verified_rounded,
                      size: 16,
                    ),
                    label: const Text(
                      'Simpan & Terbitkan Kredensial',
                      style: TextStyle(
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
    required String validatorMessage,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        fontSize: 12,
        color: ink,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return validatorMessage;
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