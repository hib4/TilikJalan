import 'package:flutter/material.dart';
import 'package:tilikjalan/core/theme/app_theme.dart';
import 'package:tilikjalan/features/auth/auth.dart';
import 'package:tilikjalan/features/dashboard/view/dashboard_page.dart';
import 'package:tilikjalan/utils/utils.dart';
import 'package:tilikjalan/widgets/text_field/custom_text_field.dart';

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
      backgroundColor: colors.neutral[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo or Title
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Text(
                    'TilikJalan',
                    textAlign: TextAlign.center,
                    style: textTheme.displaySmall.copyWith(
                      color: colors.primary[500],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
                        color: colors.primary[500],
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary[500],
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Masuk',
                    style: textTheme.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                24.vertical,
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum memiliki akun?',
                      style: textTheme.bodySmall.copyWith(
                        color: colors.neutral[800],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push(const RegisterPage());
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Daftar',
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
