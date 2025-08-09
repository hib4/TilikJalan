import 'package:flutter/material.dart';
import 'package:tilikjalan/core/theme/app_theme.dart';
import 'package:tilikjalan/utils/utils.dart';
import 'package:tilikjalan/widgets/widgets.dart';

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
                    // Logo/Icon placeholder
                    const Icon(
                      Icons.lock_reset_rounded,
                      size: 100,
                      color: Colors.white,
                    ),
                    16.vertical,
                    Text(
                      'Reset Kata Sandi',
                      style: textTheme.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    8.vertical,
                    Text(
                      'Kami akan mengirim link reset ke email Anda',
                      textAlign: TextAlign.center,
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
                    // Send Reset Button
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implement forgot password logic
                      },
                      child: Text(
                        'Kirim Email Reset',
                        style: textTheme.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    32.vertical,
                    // Back to Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Ingat kata sandi? ",
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
                            'Masuk Sekarang',
                            style: textTheme.bodyMedium.copyWith(
                              color: const Color(0xFF007AFF), // Primary blue
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    80.vertical,
                    // Additional help text
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.neutral[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: colors.grey[600],
                            size: 24,
                          ),
                          8.vertical,
                          Text(
                            'Bantuan Reset Kata Sandi',
                            style: textTheme.titleSmall.copyWith(
                              color: colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          8.vertical,
                          Text(
                            'Jika Anda tidak menerima email dalam 5 menit, periksa folder spam atau coba lagi.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall.copyWith(
                              color: colors.grey[600],
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
