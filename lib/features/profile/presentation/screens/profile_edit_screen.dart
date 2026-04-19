import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/sr_button.dart';
import '../../../../shared/widgets/sr_loading_view.dart';
import '../../../../shared/widgets/sr_text_field.dart';
import '../../domain/repositories/profile_repository.dart';
import '../providers/profile_providers.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _seafarerCtrl = TextEditingController();
  DateTime? _birthDate;
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _seafarerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: profileAsync.when(
        loading: () => const SrLoadingView(itemCount: 4),
        error: (e, _) => SrErrorView(message: e.toString()),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profil tidak ditemukan'));
          }
          if (!_initialized) {
            _nameCtrl.text = profile.fullName;
            _addressCtrl.text = profile.address;
            _seafarerCtrl.text = profile.seafarerNumber ?? '';
            _birthDate = profile.birthDate;
            _initialized = true;
          }
          return _buildForm();
        },
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SrSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SrTextField(
              label: 'Nama Lengkap',
              controller: _nameCtrl,
              validator: (v) => SrValidators.required(v, 'Nama lengkap'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: SrSpacing.md),
            _buildBirthDatePicker(),
            const SizedBox(height: SrSpacing.md),
            SrTextField(
              label: 'Alamat',
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
            const SizedBox(height: SrSpacing.xl),
            SrButton(
              label: 'Simpan Perubahan',
              onPressed: _save,
              isLoading: _isSaving,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pilih tanggal lahir')));
      return;
    }

    setState(() => _isSaving = true);

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.updateProfile(UpdateProfileParams(
      userId: userId,
      fullName: _nameCtrl.text.trim(),
      birthDate: _birthDate,
      address: _addressCtrl.text.trim(),
      seafarerNumber: _seafarerCtrl.text.trim().isEmpty ? null : _seafarerCtrl.text.trim(),
    ));

    setState(() => _isSaving = false);

    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        ref.invalidate(currentProfileProvider);
        context.pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui')));
      },
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
              initialDate: _birthDate ?? DateTime(1990),
              firstDate: DateTime(1940),
              lastDate: DateTime.now().subtract(const Duration(days: 17 * 365)),
            );
            if (date != null) setState(() => _birthDate = date);
          },
          borderRadius: BorderRadius.circular(SrRadius.sm),
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
                const Icon(Icons.calendar_month_outlined, size: 18, color: SrColors.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
