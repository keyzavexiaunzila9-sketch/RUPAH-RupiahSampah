import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscure = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (usernameController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Username dan password wajib diisi.',
          ),
        ),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND
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

          // LINGKARAN ATAS
          Positioned(
            top: -90,
            left: -70,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: RupahColors.green.withValues(
                  alpha: .55,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // LINGKARAN BAWAH
          Positioned(
            bottom: -100,
            right: -70,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: RupahColors.green.withValues(
                  alpha: .55,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // CONTENT
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

                      // SELAMAT DATANG
                      Text(
                        'Selamat Datang 👋',
                        style: GoogleFonts.dmSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: RupahColors.white,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // LOGIN
                      Text(
                        'Login',
                        style: GoogleFonts.poppins(
                          fontSize: 31,
                          fontWeight: FontWeight.w700,
                          color: RupahColors.white,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // USERNAME
                      _field(
                        'Username',
                        usernameController,
                      ),

                      const SizedBox(height: 14),

                      // PASSWORD
                      _field(
                        'Password',
                        passwordController,
                        password: true,
                      ),

                      const SizedBox(height: 24),

                      // BUTTON LOGIN
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: _login,
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                RupahColors.green,
                            foregroundColor:
                                RupahColors.white,
                            elevation: 0,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight:
                                  FontWeight.w700,
                              color:
                                  RupahColors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // KETERANGAN
                      Text(
                        'Aplikasi pengelolaan sampah kelas dan sekolah',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(
                            alpha: .82,
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

  // FIELD USERNAME & PASSWORD
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
        style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w400,
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

          contentPadding:
              const EdgeInsets.symmetric(
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