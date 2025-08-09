import 'package:flutter/material.dart';
import 'package:tilikjalan/core/theme/app_theme.dart';
import 'package:tilikjalan/features/auth/auth.dart';
import 'package:tilikjalan/features/dashboard/view/dashboard_page.dart';
import 'package:tilikjalan/gen/assets.gen.dart';
import 'package:tilikjalan/utils/utils.dart';
import 'package:tilikjalan/widgets/widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: colors.primary[500],
      body: Column(
        children: [
          // Top gradient section with logo
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.primary[500],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Icon placeholder - you can replace with actual logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Assets.images.tilikJalan.image(
                        width: 80,
                        height: 80,
                      ),
                    ),
                    24.vertical,
                    Text(
                      'Selamat Datang di TilikJalan',
                      style: textTheme.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    8.vertical,
                    Text(
                      'Aplikasi Inspeksi Jalan Terdepan Anda',
                      style: textTheme.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom white section with form
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Email Label
                    Text(
                      'Email',
                      style: textTheme.bodyMedium.copyWith(
                        color: colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    8.vertical,
                    // Email Field
                    CustomTextField(
                      controller: emailController,
                      label: 'contoh@email.com',
                      textInputType: TextInputType.emailAddress,
                    ),
                    24.vertical,
                    // Password Label
                    Text(
                      'Kata Sandi',
                      style: textTheme.bodyMedium.copyWith(
                        color: colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    8.vertical,
                    // Password Field
                    CustomTextField(
                      controller: passwordController,
                      label: 'Masukkan kata sandi',
                      isPassword: true,
                    ),
                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          context.push(const ForgotPasswordPage());
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Lupa Kata Sandi?',
                          style: textTheme.bodySmall.copyWith(
                            color: colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    24.vertical,
                    // Login Button
                    ElevatedButton(
                      onPressed: () {
                        context.pushAndRemoveUntil(
                          const DashboardPage(),
                          (route) => false,
                        );
                      },
                      child: Text(
                        'Masuk',
                        style: textTheme.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    32.vertical,
                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Belum Punya Akun? ",
                          style: textTheme.bodyMedium.copyWith(
                            color: colors.grey[600],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.push(const RegisterPage());
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Daftar Sekarang!',
                            style: textTheme.bodyMedium.copyWith(
                              color: const Color(0xFF007AFF), // Primary blue
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    84.vertical,
                    // Terms and Privacy
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Dengan menggunakan TilikJalan, Anda menyetujui ',
                        style: textTheme.bodySmall.copyWith(
                          color: colors.grey[500],
                        ),
                        children: [
                          TextSpan(
                            text: 'Syarat Layanan',
                            style: textTheme.bodySmall.copyWith(
                              color: const Color(0xFF007AFF), // Primary blue
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(
                            text: ' dan ',
                            style: textTheme.bodySmall.copyWith(
                              color: colors.grey[500],
                            ),
                          ),
                          TextSpan(
                            text: 'Kebijakan Privasi',
                            style: textTheme.bodySmall.copyWith(
                              color: const Color(0xFF007AFF), // Primary blue
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
