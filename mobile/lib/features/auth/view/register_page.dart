import 'package:flutter/material.dart';
import 'package:tilikjalan/core/theme/app_theme.dart';
import 'package:tilikjalan/features/auth/auth.dart';
import 'package:tilikjalan/utils/utils.dart';
import 'package:tilikjalan/widgets/text_field/custom_text_field.dart';

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
      backgroundColor: colors.neutral[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Text(
                    'Daftar',
                    textAlign: TextAlign.center,
                    style: textTheme.displaySmall.copyWith(
                      color: colors.primary[500],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Name Field
                CustomTextField(
                  label: 'Nama Lengkap',
                  controller: nameController,
                  textInputType: TextInputType.name,
                ),
                16.vertical,
                // Email Field
                CustomTextField(
                  label: 'Email',
                  controller: emailController,
                  textInputType: TextInputType.emailAddress,
                ),
                16.vertical,
                // Password Field
                CustomTextField(
                  label: 'Kata Sandi',
                  controller: passwordController,
                  isPassword: true,
                ),
                24.vertical,
                // Register Button
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement register logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary[500],
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Daftar',
                    style: textTheme.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                24.vertical,
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun?',
                      style: textTheme.bodySmall.copyWith(
                        color: colors.neutral[800],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push(const LoginPage());
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Masuk',
                        style: textTheme.bodySmall.copyWith(
                          color: colors.primary[500],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
