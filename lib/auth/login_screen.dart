
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

  // URL backend RUPAH
  final String baseUrl = 'http://localhost:3000';

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = usernameController.text.trim().toLowerCase();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username dan password wajib diisi.'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // 1. Mencari email berdasarkan username melalui backend
      final lookupResponse = await http.post(
        Uri.parse('$baseUrl/api/auth/username-email'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
        }),
      );

      final lookupData = jsonDecode(lookupResponse.body);

      if (lookupResponse.statusCode != 200) {
        throw Exception(
          lookupData['message'] ?? 'Username tidak ditemukan.',
        );
      }

      final email = lookupData['email'];

      if (email == null || email.toString().isEmpty) {
        throw Exception('Email akun tidak ditemukan.');
      }

      // 2. Login ke Supabase Auth
      final supabase = Supabase.instance.client;

      final response = await supabase.auth.signInWithPassword(
        email: email.toString(),
        password: password,
      );

      final user = response.user;

      if (user == null) {
        throw Exception('Akun tidak ditemukan.');
      }

      // 3. Mengambil data role pengguna
      final data = await supabase
          .from('users')
          .select('username, role, id_kelas')
          .eq('id_user', user.id)
          .maybeSingle();

      if (data == null) {
        await supabase.auth.signOut();
        throw Exception('Data pengguna tidak ditemukan.');
      }

      if (!mounted) return;

      // 4. Mengarahkan pengguna berdasarkan role
      final role = data['role'];

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminNavigation(),
          ),
        );
      } else if (role == 'user') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const UserNavigation(),
          ),
        );
      } else {
        await supabase.auth.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Role pengguna tidak valid.'),
          ),
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login gagal: ${e.message}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login gagal: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
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
          // Background gradient
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

          // Lingkaran dekorasi atas
          Positioned(
            top: -90,
            left: -70,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: RupahColors.green.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Lingkaran dekorasi bawah
          Positioned(
            bottom: -100,
            right: -70,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: RupahColors.green.withValues(alpha: 0.55),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 70),

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

                      // Username
                      _field(
                        'Username',
                        usernameController,
                      ),

                      const SizedBox(height: 14),

                      // Password
                      _field(
                        'Password',
                        passwordController,
                        password: true,
                      ),

                      const SizedBox(height: 24),

                      // Tombol login
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: isLoading ? null : _login,
                          style: FilledButton.styleFrom(
                            backgroundColor: RupahColors.green,
                            foregroundColor: RupahColors.white,
                            disabledBackgroundColor:
                                RupahColors.green.withValues(alpha: 0.7),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Login',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        'Aplikasi pengelolaan sampah kelas dan sekolah',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.82),
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
            color: Colors.black.withValues(alpha: 0.18),
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
