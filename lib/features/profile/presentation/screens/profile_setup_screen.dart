import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/sr_button.dart';
import '../../../../shared/widgets/sr_step_indicator.dart';
import '../../../../shared/widgets/sr_text_field.dart';
import '../providers/profile_providers.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  int _step = 1;
  final _formKey1 = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _nikCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _seafarerCtrl = TextEditingController();
  DateTime? _birthDate;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nikCtrl.dispose();
    _addressCtrl.dispose();
    _seafarerCtrl.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_step == 1) {
      if (!_formKey1.currentState!.validate()) return;
      if (_birthDate == null) {
        _showSnack('Pilih tanggal lahir terlebih dahulu');
        return;
      }
      ref.read(profileSetupControllerProvider.notifier).updatePersonalData(
            fullName: _nameCtrl.text.trim(),
            birthDate: _birthDate,
            nik: _nikCtrl.text.replaceAll(RegExp(r'\D'), ''),
            address: _addressCtrl.text.trim(),
            seafarerNumber: _seafarerCtrl.text.trim(),
          );
      setState(() => _step = 2);
    }
  }

  Future<void> _submit() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final ok = await ref.read(profileSetupControllerProvider.notifier).submitProfile(userId);
    if (ok && mounted) {
      ref.invalidate(currentProfileProvider);
      context.go('/profile');
    }
  }

  Future<void> _submitWithoutDocs() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final ok = await ref.read(profileSetupControllerProvider.notifier).submitProfile(userId);
    if (mounted) {
      ref.invalidate(currentProfileProvider);
      context.go('/profile');
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil disimpan tanpa dokumen')),
        );
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = ref.watch(profileSetupControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku Pelaut'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_step > 1) {
              setState(() => _step--);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SrSpacing.lg, vertical: SrSpacing.md),
            child: SrStepIndicator(
              currentStep: _step,
              totalSteps: 2,
              labels: const ['Data Diri', 'Dokumen'],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(SrSpacing.lg),
              child: _step == 1 ? _buildStep1(ctrl) : _buildStep2(ctrl),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(ProfileSetupState ctrl) {
    return Form(
      key: _formKey1,
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
          _buildNikField(),
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
          const Text(
            'Isi jika sudah punya nomor pelaut (buku pelaut)',
            style: TextStyle(fontSize: 12, color: SrColors.textMuted),
          ),
          const SizedBox(height: SrSpacing.xl),
          SrButton(label: 'Lanjut → Upload Dokumen', onPressed: _goNext),
        ],
      ),
    );
  }

  Widget _buildStep2(ProfileSetupState ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ctrl.error != null) ...[
          Container(
            padding: const EdgeInsets.all(SrSpacing.sm),
            decoration: BoxDecoration(
              color: SrColors.dangerBg,
              borderRadius: BorderRadius.circular(SrRadius.sm),
            ),
            child: Text(ctrl.error!, style: const TextStyle(color: SrColors.dangerText, fontSize: 13)),
          ),
          const SizedBox(height: SrSpacing.md),
        ],
        const Text(
          'Upload Dokumen Verifikasi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: SrSpacing.xs),
        const Text(
          'Diperlukan untuk verifikasi akun. Tim akan memproses dalam 1-2 hari kerja.',
          style: TextStyle(fontSize: 13, color: SrColors.textMuted, height: 1.5),
        ),
        const SizedBox(height: SrSpacing.lg),

        // KTP upload
        const Text('Foto KTP',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: SrSpacing.xs),
        _buildDocUploadArea(
          imagePath: ctrl.ktpImagePath,
          icon: Icons.badge_outlined,
          hint: 'Tap untuk ambil foto KTP',
          onCamera: () => ref.read(profileSetupControllerProvider.notifier).pickKtpImage(),
          onGallery: () => ref.read(profileSetupControllerProvider.notifier).pickKtpFromGallery(),
        ),
        const SizedBox(height: SrSpacing.md),

        // Selfie upload
        const Text('Selfie Verifikasi',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: SrSpacing.xs),
        _buildSelfieUploadArea(ctrl.selfieImagePath),
        const SizedBox(height: SrSpacing.xl),

        SrButton(
          label: 'Simpan & Kirim Verifikasi',
          onPressed: _submit,
          isLoading: ctrl.isLoading,
        ),
        const SizedBox(height: SrSpacing.sm),
        SrButton(
          label: 'Lewati untuk sekarang',
          variant: SrButtonVariant.ghost,
          onPressed: ctrl.isLoading ? null : _submitWithoutDocs,
        ),
      ],
    );
  }

  Widget _buildDocUploadArea({
    required String? imagePath,
    required IconData icon,
    required String hint,
    required VoidCallback onCamera,
    required VoidCallback onGallery,
  }) {
    if (imagePath != null && imagePath.isNotEmpty) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(SrRadius.md),
            child: Image.file(
              File(imagePath),
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onCamera,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.edit, size: 16, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: SrColors.successBg, borderRadius: BorderRadius.circular(4)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, size: 12, color: SrColors.success),
                  SizedBox(width: 4),
                  Text('Terpilih', style: TextStyle(fontSize: 11, color: SrColors.successText)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _uploadButton(Icons.camera_alt_outlined, 'Kamera', onCamera),
        ),
        const SizedBox(width: SrSpacing.sm),
        Expanded(
          child: _uploadButton(Icons.photo_library_outlined, 'Galeri', onGallery),
        ),
      ],
    );
  }

  Widget _buildSelfieUploadArea(String? imagePath) {
    if (imagePath != null && imagePath.isNotEmpty) {
      return Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 64,
              backgroundImage: FileImage(File(imagePath)),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => ref.read(profileSetupControllerProvider.notifier).pickSelfieImage(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: SrColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: GestureDetector(
        onTap: () => ref.read(profileSetupControllerProvider.notifier).pickSelfieImage(),
        child: Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            color: SrColors.cardBg,
            shape: BoxShape.circle,
            border: Border.all(color: SrColors.border, width: 2),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_outlined, size: 32, color: SrColors.textMuted),
              SizedBox(height: 4),
              Text('Selfie', style: TextStyle(fontSize: 12, color: SrColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _uploadButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: SrColors.cardBg,
          borderRadius: BorderRadius.circular(SrRadius.sm),
          border: Border.all(color: SrColors.border, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: SrColors.primary),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: SrColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildNikField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('No. KTP (NIK)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SrColors.textPrimary)),
        const SizedBox(height: SrSpacing.xs),
        TextFormField(
          controller: _nikCtrl,
          keyboardType: TextInputType.number,
          maxLength: 16,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: SrValidators.nik,
          style: const TextStyle(fontSize: 14, letterSpacing: 2),
          decoration: const InputDecoration(
            hintText: '16 digit angka',
            counterText: '',
            suffixIcon: Icon(Icons.lock_outline, size: 18, color: SrColors.textMuted),
          ),
        ),
        const SizedBox(height: SrSpacing.xs),
        const Row(
          children: [
            Icon(Icons.security, size: 12, color: SrColors.textMuted),
            SizedBox(width: 4),
            Text(
              'NIK dienkripsi end-to-end, tidak pernah ditampilkan penuh',
              style: TextStyle(fontSize: 11, color: SrColors.textMuted),
            ),
          ],
        ),
      ],
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
              initialDate: _birthDate ?? DateTime(1990, 1, 1),
              firstDate: DateTime(1940),
              lastDate: DateTime.now().subtract(const Duration(days: 17 * 365)),
              helpText: 'Pilih tanggal lahir',
            );
            if (date != null) setState(() => _birthDate = date);
          },
          borderRadius: BorderRadius.circular(SrRadius.sm),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: _birthDate != null ? SrColors.primary : SrColors.border,
                width: _birthDate != null ? 1.5 : 0.5,
              ),
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
                Icon(
                  Icons.calendar_month_outlined,
                  size: 18,
                  color: _birthDate != null ? SrColors.primary : SrColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
