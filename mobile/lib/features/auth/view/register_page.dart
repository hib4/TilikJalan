import 'package:flutter/material.dart';
import 'package:tilikjalan/core/theme/app_theme.dart';
import 'package:tilikjalan/features/dashboard/dashboard.dart';
import 'package:tilikjalan/gen/assets.gen.dart';
import 'package:tilikjalan/utils/utils.dart';
import 'package:tilikjalan/widgets/widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

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
                      'Bergabung dengan TilikJalan',
                      style: textTheme.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    8.vertical,
                    Text(
                      'Mulai inspeksi jalan dengan mudah',
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
                    // Name Label
                    Text(
                      'Nama Lengkap',
                      style: textTheme.bodyMedium.copyWith(
                        color: colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    8.vertical,
                    // Name Field
                    CustomTextField(
                      controller: nameController,
                      label: 'Masukkan nama lengkap',
                      textInputType: TextInputType.name,
                    ),
                    24.vertical,
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
                    24.vertical,
                    // Register Button
                    ElevatedButton(
                      onPressed: () {
                        context.pushAndRemoveUntil(
                          const DashboardPage(),
                          (route) => false,
                        );
                      },
                      child: Text(
                        'Daftar',
                        style: textTheme.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    32.vertical,
                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah Punya Akun? ',
                          style: textTheme.bodyMedium.copyWith(
                            color: colors.grey[600],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.pop();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Masuk Sekarang!',
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
                        text: 'Dengan mendaftar, Anda menyetujui ',
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
