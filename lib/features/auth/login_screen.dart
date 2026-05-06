import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/mn_button.dart';
import 'widgets/auth_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!ok && mounted) {
      _showError(context, auth.error ?? 'Login failed.');
    }
    // Navigation is handled reactively by _HomeDecider in app.dart
  }

  Future<void> _tryFirst(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.signInAnonymously();
    if (!ok && mounted) {
      _showError(context, auth.error ?? 'Could not start guest session. Make sure Anonymous sign-in is enabled in Firebase.');
    }
    // Navigation is handled reactively by _HomeDecider in app.dart
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppTypography.bodyMd),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                _Logo(),
                const SizedBox(height: 40),
                Text(
                  AppStrings.login,
                  style: AppTypography.displayMd.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 8),
                Text(
                  AppStrings.loginSub,
                  style: AppTypography.bodyMd.copyWith(
                    color:
                        isDark ? AppColors.textMutedDark : AppColors.textMuted,
                  ),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 36),
                AuthField(
                  label: AppStrings.email,
                  hint: 'you@example.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 20),
                AuthField(
                  label: AppStrings.password,
                  controller: _passCtrl,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () => _signIn(context),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 8) return 'At least 8 characters';
                    return null;
                  },
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () async {
                      if (_emailCtrl.text.trim().isEmpty) {
                        _showError(context, 'Enter your email first.');
                        return;
                      }
                      final auth = context.read<AuthProvider>();
                      await auth.sendPasswordReset(_emailCtrl.text.trim());
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Reset link sent — check your inbox.')),
                        );
                      }
                    },
                    child: Text(
                      AppStrings.forgotPassword,
                      style: AppTypography.caption.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) => MnButton(
                    label: AppStrings.signIn,
                    onPressed: () => _signIn(context),
                    isLoading: auth.isLoading,
                    width: double.infinity,
                  ),
                ).animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 16),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) => MnButton(
                    label: AppStrings.tryFirst,
                    variant: MnButtonVariant.secondary,
                    onPressed: () => _tryFirst(context),
                    isLoading: auth.isLoading,
                    icon: Icons.explore_outlined,
                    width: double.infinity,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.noAccount,
                      style: AppTypography.bodyMd.copyWith(
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMuted,
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRoutes.signup),
                      child: Text(
                        AppStrings.signUp,
                        style: AppTypography.bodyMd.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
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

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF5A65B), Color(0xFF8C7BB5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.spa_rounded, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 10),
        Text(
          'MoodNest',
          style: AppTypography.titleLg.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
