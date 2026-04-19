import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/sr_button.dart';
import '../../../../shared/widgets/sr_text_field.dart';
import '../providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_emailCtrl.text.trim());
    if (ok && mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SrSpacing.lg),
          child: _sent ? _buildSuccess() : _buildForm(authState),
        ),
      ),
    );
  }

  Widget _buildForm(AuthState authState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Masukkan email yang terdaftar. Kami akan mengirim link untuk reset password.',
            style: TextStyle(fontSize: 14, color: SrColors.textMuted, height: 1.5),
          ),
          const SizedBox(height: SrSpacing.lg),
          if (authState.error != null) ...[
            Container(
              padding: const EdgeInsets.all(SrSpacing.sm),
              decoration: BoxDecoration(
                color: SrColors.dangerBg,
                borderRadius: BorderRadius.circular(SrRadius.sm),
              ),
              child: Text(authState.error!, style: const TextStyle(color: SrColors.dangerText, fontSize: 13)),
            ),
            const SizedBox(height: SrSpacing.md),
          ],
          SrTextField(
            label: 'Email',
            hint: 'contoh@email.com',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            validator: SrValidators.email,
          ),
          const SizedBox(height: SrSpacing.xl),
          SrButton(
            label: 'Kirim Link Reset',
            onPressed: _submit,
            isLoading: authState.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.mark_email_read_outlined, size: 64, color: SrColors.success),
        const SizedBox(height: SrSpacing.lg),
        const Text('Email Terkirim!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SrColors.textPrimary)),
        const SizedBox(height: SrSpacing.sm),
        Text(
          'Link reset password telah dikirim ke ${_emailCtrl.text}. Cek inbox atau folder spam.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: SrColors.textMuted, height: 1.5),
        ),
        const SizedBox(height: SrSpacing.xl),
        SrButton(
          label: 'Kembali ke Login',
          onPressed: () => context.go('/login'),
        ),
      ],
    );
  }
}
