import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/sr_button.dart';
import '../../../../shared/widgets/sr_step_indicator.dart';
import '../../../../shared/widgets/sr_text_field.dart';
import '../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  int _currentStep = 1;
  final _formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>()];

  // Step 1 fields
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // Step 2 fields
  final _nameCtrl = TextEditingController();
  final _nikCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _seafarerCtrl = TextEditingController();
  DateTime? _birthDate;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    _nikCtrl.dispose();
    _addressCtrl.dispose();
    _seafarerCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (!_formKeys[_currentStep - 1].currentState!.validate()) return;
    if (_currentStep == 2 && _birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal lahir terlebih dahulu')),
      );
      return;
    }
    setState(() => _currentStep++);
  }

  Future<void> _submitStep1() async {
    if (!_formKeys[0].currentState!.validate()) return;
    final ok = await ref
        .read(authControllerProvider.notifier)
        .signUp(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (ok && mounted) setState(() => _currentStep = 2);
  }

  Future<void> _submitFinal() async {
    if (mounted) context.go('/email-verification');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Akun'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SrSpacing.lg, vertical: SrSpacing.md),
              child: SrStepIndicator(
                currentStep: _currentStep,
                totalSteps: 3,
                labels: const ['Akun', 'Data diri', 'Dokumen'],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(SrSpacing.lg),
                child: [
                  _buildStep1(authState),
                  _buildStep2(),
                  _buildStep3(authState),
                ][_currentStep - 1],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(AuthState authState) {
    return Form(
      key: _formKeys[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: SrSpacing.md),
          SrTextField(
            label: 'Konfirmasi Password',
            controller: _confirmPasswordCtrl,
            obscureText: true,
            showTogglePassword: true,
            validator: (v) => SrValidators.confirmPassword(v, _passwordCtrl.text),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: SrSpacing.md),
          SrTextField(
            label: 'Nomor HP',
            hint: '8xx xxxx xxxx',
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            prefixText: '+62 ',
            validator: SrValidators.phone,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: SrSpacing.xl),
          SrButton(
            label: 'Lanjut',
            onPressed: _submitStep1,
            isLoading: authState.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _formKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SrTextField(
            label: 'Nama Lengkap',
            hint: 'Sesuai KTP',
            controller: _nameCtrl,
            validator: (v) => SrValidators.required(v, 'Nama lengkap'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: SrSpacing.md),
          _buildBirthDatePicker(),
          const SizedBox(height: SrSpacing.md),
          SrNikField(controller: _nikCtrl, validator: SrValidators.nik),
          const SizedBox(height: SrSpacing.md),
          SrTextField(
            label: 'Alamat',
            hint: 'Alamat lengkap sesuai KTP',
            controller: _addressCtrl,
            maxLines: 3,
            validator: (v) => SrValidators.required(v, 'Alamat'),
          ),
          const SizedBox(height: SrSpacing.md),
          SrTextField(
            label: 'No. Pelaut (Opsional)',
            hint: 'Isi jika sudah punya',
            controller: _seafarerCtrl,
            validator: SrValidators.seafarerNumber,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: SrSpacing.xs),
          const Text('Isi jika sudah punya nomor pelaut (buku pelaut)',
              style: TextStyle(fontSize: 12, color: SrColors.textMuted)),
          const SizedBox(height: SrSpacing.xl),
          SrButton(label: 'Lanjut → Upload dokumen', onPressed: _nextStep),
        ],
      ),
    );
  }

  Widget _buildStep3(AuthState authState) {
    return Form(
      key: _formKeys[2],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upload Dokumen',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: SrColors.textPrimary)),
          const SizedBox(height: SrSpacing.xs),
          const Text('Diperlukan untuk verifikasi akun (1-2 hari kerja)',
              style: TextStyle(fontSize: 13, color: SrColors.textMuted)),
          const SizedBox(height: SrSpacing.lg),
          _buildUploadArea('Foto KTP', Icons.badge_outlined),
          const SizedBox(height: SrSpacing.md),
          _buildUploadArea('Selfie Verifikasi', Icons.camera_alt_outlined),
          const SizedBox(height: SrSpacing.xl),
          SrButton(
            label: 'Selesai',
            onPressed: _submitFinal,
            isLoading: authState.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildBirthDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tanggal Lahir',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SrColors.textPrimary)),
        const SizedBox(height: SrSpacing.xs),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime(1990),
              firstDate: DateTime(1940),
              lastDate: DateTime.now().subtract(const Duration(days: 17 * 365)),
            );
            if (date != null) setState(() => _birthDate = date);
          },
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: SrColors.border, width: 0.5),
              borderRadius: BorderRadius.circular(SrRadius.sm),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _birthDate != null
                        ? '${_birthDate!.day.toString().padLeft(2, '0')} / ${_birthDate!.month.toString().padLeft(2, '0')} / ${_birthDate!.year}'
                        : 'DD / MM / YYYY',
                    style: TextStyle(
                      fontSize: 14,
                      color: _birthDate != null ? SrColors.textPrimary : SrColors.textMuted,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today_outlined, size: 18, color: SrColors.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadArea(String label, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: SrSpacing.xs),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: SrColors.cardBg,
            borderRadius: BorderRadius.circular(SrRadius.md),
            border: Border.all(color: SrColors.border, style: BorderStyle.solid, width: 1),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 32, color: SrColors.textMuted),
                const SizedBox(height: SrSpacing.xs),
                const Text('Tap untuk ambil foto', style: TextStyle(fontSize: 12, color: SrColors.textMuted)),
              ],
            ),
          ),
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
}
