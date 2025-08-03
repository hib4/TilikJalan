import 'package:flutter/material.dart';
import 'package:tilikjalan/core/theme/app_theme.dart';
import 'package:tilikjalan/features/auth/auth.dart';
import 'package:tilikjalan/utils/utils.dart';
import 'package:tilikjalan/widgets/text_field/custom_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    final emailController = TextEditingController();

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
                    'Reset Kata Sandi',
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
                24.vertical,
                // Login Button
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement login logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary[500],
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Kirim Email Reset',
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
                      'Kembali ke',
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
