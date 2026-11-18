
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

import '../core/theme/app_theme.dart';
import '../user/user_navigation.dart';
import '../admin/widgets/admin_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscure = true;
  bool isLoading = false;

  // URL BACKEND RUPAH
  final String baseUrl = 'http://localhost:3000';

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // MENAMPILKAN NOTIFIKASI
  void _showMessage(
    String message, {
    bool error = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: error
            ? const Color(0xFFD93636)
            : const Color(0xFF087A4F),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // PROSES LOGIN
  Future<void> _login() async {
    final username =
        usernameController.text.trim().toLowerCase();

    final password = passwordController.text;

    // VALIDASI INPUT
    if (username.isEmpty || password.isEmpty) {
      _showMessage(
        'Username dan password wajib diisi.',
        error: true,
      );
      return;
    }

    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      // 1. MENCARI EMAIL BERDASARKAN USERNAME
      final lookupResponse = await http
          .post(
            Uri.parse('$baseUrl/api/auth/username-email'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'username': username,
            }),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      // MEMBACA RESPONSE BACKEND
      final dynamic lookupData =
          jsonDecode(lookupResponse.body);

      if (lookupResponse.statusCode != 200) {
        throw Exception(
          'Username atau password salah.',
        );
      }

      if (lookupData is! Map ||
          lookupData['email'] == null ||
          lookupData['email'].toString().isEmpty) {
        throw Exception(
          'Username atau password salah.',
        );
      }

      final String email =
          lookupData['email'].toString();

      // 2. LOGIN MENGGUNAKAN SUPABASE AUTH
      final supabase = Supabase.instance.client;

      final response =
          await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        throw Exception(
          'Username atau password salah.',
        );
      }

      // 3. MENGAMBIL DATA ROLE PENGGUNA
      final data = await supabase
          .from('users')
          .select('username, role, id_kelas')
          .eq('id_user', user.id)
          .maybeSingle();

      // JIKA DATA PENGGUNA TIDAK DITEMUKAN
      if (data == null) {
        await supabase.auth.signOut();

        throw Exception(
          'Data pengguna tidak ditemukan.',
        );
      }

      if (!mounted) return;

      // 4. NAVIGASI BERDASARKAN ROLE
      final role = data['role'];

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminNavigation(),
          ),
        );
      } else if (role == 'user') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const UserNavigation(),
          ),
        );
      } else {
        await supabase.auth.signOut();

        if (!mounted) return;

        throw Exception(
          'Role pengguna tidak valid.',
        );
      }
    }

    // ERROR AUTENTIKASI SUPABASE
    on AuthException {
      _showMessage(
        'Username atau password salah.',
        error: true,
      );
    }

    // ERROR DARI BACKEND ATAU VALIDASI
    on http.ClientException {
      _showMessage(
        'Tidak dapat terhubung ke server.',
        error: true,
      );
    } on FormatException {
      _showMessage(
        'Terjadi kesalahan saat membaca respons server.',
        error: true,
      );
    } on Exception catch (e) {
      final message = e
          .toString()
          .replaceFirst('Exception: ', '');

      _showMessage(
        message,
        error: true,
      );
    } catch (e) {
      _showMessage(
        'Terjadi kesalahan. Silakan coba lagi.',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  RupahColors.blue,
                  Color(0xFF4EA0A2),
                ],
              ),
            ),
          ),

          // LINGKARAN DEKORASI ATAS
          Positioned(
            top: -90,
            left: -70,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: RupahColors.green.withValues(
                  alpha: 0.55,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // LINGKARAN DEKORASI BAWAH
          Positioned(
            bottom: -100,
            right: -70,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: RupahColors.green.withValues(
                  alpha: 0.55,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 30,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 430,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 70),

                      // JUDUL
                      Text(
                        'Selamat Datang 👋',
                        style: GoogleFonts.dmSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: RupahColors.white,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Login',
                        style: GoogleFonts.poppins(
                          fontSize: 31,
                          fontWeight: FontWeight.w700,
                          color: RupahColors.white,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // INPUT USERNAME
                      _field(
                        'Username',
                        usernameController,
                      ),

                      const SizedBox(height: 14),

                      // INPUT PASSWORD
                      _field(
                        'Password',
                        passwordController,
                        password: true,
                      ),

                      const SizedBox(height: 24),

                      // TOMBOL LOGIN
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed:
                              isLoading ? null : _login,
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                RupahColors.green,
                            foregroundColor:
                                RupahColors.white,
                            disabledBackgroundColor:
                                RupahColors.green.withValues(
                              alpha: 0.7,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child:
                                      CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Login',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // KETERANGAN APLIKASI
                      Text(
                        'Aplikasi pengelolaan sampah kelas dan sekolah',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: Colors.white.withValues(
                            alpha: 0.82,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET INPUT
  Widget _field(
    String label,
    TextEditingController controller, {
    bool password = false,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.18,
            ),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: password && obscure,
        keyboardType: password
            ? TextInputType.visiblePassword
            : TextInputType.text,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: GoogleFonts.dmSans(
            fontSize: 12,
            color: const Color(0xFF999999),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 13,
          ),
          suffixIcon: password
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      obscure = !obscure;
                    });
                  },
                  icon: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF999999),
                    size: 18,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
