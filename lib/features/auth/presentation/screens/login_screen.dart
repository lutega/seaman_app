import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/sr_button.dart';
import '../../../../shared/widgets/sr_text_field.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authControllerProvider.notifier).clearError();
    final ok = await ref
        .read(authControllerProvider.notifier)
        .signIn(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (ok && mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: SrColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SrSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: SrSpacing.xxxl),
                _buildLogo(),
                const SizedBox(height: SrSpacing.xl),
                if (authState.error != null) ...[
                  _buildErrorBanner(authState.error!),
                  const SizedBox(height: SrSpacing.md),
                ],
                SrTextField(
                  label: 'Email',
                  hint: 'contoh@email.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: SrValidators.email,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: SrSpacing.md),
                SrTextField(
                  label: 'Password',
                  controller: _passwordCtrl,
                  obscureText: true,
                  showTogglePassword: true,
                  validator: SrValidators.password,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: SrSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text('Lupa password?', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(height: SrSpacing.md),
                SrButton(
                  label: 'Masuk',
                  onPressed: _submit,
                  isLoading: authState.isLoading,
                ),
                const SizedBox(height: SrSpacing.md),
                _buildDivider(),
                const SizedBox(height: SrSpacing.md),
                SrButton(
                  label: 'Masuk dengan Google',
                  variant: SrButtonVariant.secondary,
                  leadingIcon: Icons.g_mobiledata,
                  onPressed: () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
                ),
                const SizedBox(height: SrSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Belum punya akun?', style: TextStyle(color: SrColors.textMuted, fontSize: 14)),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text('Daftar', style: TextStyle(fontWeight: FontWeight.w600)),
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

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: SrColors.primary,
            borderRadius: BorderRadius.circular(SrRadius.md),
          ),
          child: const Icon(Icons.anchor, size: 40, color: SrColors.white),
        ),
        const SizedBox(height: SrSpacing.md),
        const Text('SeaReady', style: SrTypography.h1),
        const SizedBox(height: SrSpacing.xs),
        const Text(
          'Certificate wallet & training platform\nuntuk pelaut Indonesia',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: SrColors.textMuted, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(SrSpacing.sm),
      decoration: BoxDecoration(
        color: SrColors.dangerBg,
        borderRadius: BorderRadius.circular(SrRadius.sm),
        border: Border.all(color: SrColors.danger.withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 16, color: SrColors.danger),
          const SizedBox(width: SrSpacing.sm),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 13, color: SrColors.dangerText))),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SrSpacing.sm),
          child: Text('atau', style: TextStyle(fontSize: 13, color: SrColors.textMuted)),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
