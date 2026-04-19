import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/sr_button.dart';
import '../../../../shared/widgets/sr_text_field.dart';
import '../providers/certificate_providers.dart';

class CertificateAddScreen extends ConsumerStatefulWidget {
  const CertificateAddScreen({super.key});

  @override
  ConsumerState<CertificateAddScreen> createState() => _CertificateAddScreenState();
}

class _CertificateAddScreenState extends ConsumerState<CertificateAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _issuerCtrl = TextEditingController();
  DateTime? _issuedDate;
  DateTime? _expiryDate;
  String _selectedType = 'STCW';

  final _types = ['STCW', 'Medis', 'Keselamatan', 'Teknis', 'Lainnya'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _issuerCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_issuedDate == null || _expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal terbit dan kedaluwarsa')),
      );
      return;
    }
    if (_expiryDate!.isBefore(_issuedDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal kedaluwarsa harus setelah tanggal terbit')),
      );
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    ref.read(addCertControllerProvider.notifier).update(
          name: _nameCtrl.text.trim(),
          type: _selectedType,
          issuedDate: _issuedDate,
          expiryDate: _expiryDate,
          issuer: _issuerCtrl.text.trim(),
        );

    final ok = await ref.read(addCertControllerProvider.notifier).submit(userId);
    if (ok && mounted) {
      ref.invalidate(certificatesProvider);
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sertifikat berhasil ditambahkan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addCertControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Sertifikat')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SrSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(SrSpacing.sm),
                  decoration: BoxDecoration(
                    color: SrColors.dangerBg,
                    borderRadius: BorderRadius.circular(SrRadius.sm),
                  ),
                  child: Text(state.error!,
                      style: const TextStyle(color: SrColors.dangerText, fontSize: 13)),
                ),
                const SizedBox(height: SrSpacing.md),
              ],
              SrTextField(
                label: 'Nama Sertifikat',
                hint: 'Contoh: Basic Safety Training',
                controller: _nameCtrl,
                validator: (v) => SrValidators.required(v, 'Nama sertifikat'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: SrSpacing.md),
              _buildTypeDropdown(),
              const SizedBox(height: SrSpacing.md),
              SrTextField(
                label: 'Penerbit (Opsional)',
                hint: 'Contoh: PMTC, BKI',
                controller: _issuerCtrl,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: SrSpacing.md),
              Row(
                children: [
                  Expanded(child: _buildDatePicker('Tgl Terbit', _issuedDate,
                      (d) => setState(() => _issuedDate = d))),
                  const SizedBox(width: SrSpacing.sm),
                  Expanded(child: _buildDatePicker('Tgl Kedaluwarsa', _expiryDate,
                      (d) => setState(() => _expiryDate = d))),
                ],
              ),
              const SizedBox(height: SrSpacing.md),
              _buildDocumentPicker(state.documentPath),
              const SizedBox(height: SrSpacing.xl),
              SrButton(
                label: 'Simpan Sertifikat',
                onPressed: _submit,
                isLoading: state.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Jenis Sertifikat',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SrColors.textPrimary)),
        const SizedBox(height: SrSpacing.xs),
        DropdownButtonFormField<String>(
          value: _selectedType,
          items: _types
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => _selectedType = v ?? _selectedType),
          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? value, void Function(DateTime) onPick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SrColors.textPrimary)),
        const SizedBox(height: SrSpacing.xs),
        InkWell(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2050),
            );
            if (d != null) onPick(d);
          },
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: value != null ? SrColors.primary : SrColors.border,
                width: value != null ? 1.5 : 0.5,
              ),
              borderRadius: BorderRadius.circular(SrRadius.sm),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null
                        ? '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}'
                        : 'DD/MM/YYYY',
                    style: TextStyle(
                      fontSize: 13,
                      color: value != null ? SrColors.textPrimary : SrColors.textMuted,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_month_outlined, size: 16, color: SrColors.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentPicker(String? path) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Scan Dokumen (Opsional)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SrColors.textPrimary)),
        const SizedBox(height: SrSpacing.xs),
        if (path != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(SrRadius.sm),
                child: Image.file(File(path), height: 100, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => ref.read(addCertControllerProvider.notifier).pickDocument(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: const Icon(Icons.edit, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          )
        else
          GestureDetector(
            onTap: () => ref.read(addCertControllerProvider.notifier).pickDocument(),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: SrColors.cardBg,
                borderRadius: BorderRadius.circular(SrRadius.sm),
                border: Border.all(color: SrColors.border, width: 0.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_file_outlined, size: 24, color: SrColors.textMuted),
                  SizedBox(width: SrSpacing.sm),
                  Text('Upload foto sertifikat',
                      style: TextStyle(fontSize: 13, color: SrColors.textMuted)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
