import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/certificate_repository_impl.dart';
import '../../domain/entities/certificate.dart';
import '../../domain/repositories/certificate_repository.dart';

final certificateRepositoryProvider = Provider<CertificateRepository>((ref) {
  return CertificateRepositoryImpl(Supabase.instance.client);
});

final certificatesProvider = FutureProvider<List<Certificate>>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return [];
  final repo = ref.watch(certificateRepositoryProvider);
  final result = await repo.getCertificates(userId);
  return result.fold((_) => [], (list) => list);
});

final certificateDetailProvider =
    FutureProvider.family<Certificate, String>((ref, id) async {
  final repo = ref.watch(certificateRepositoryProvider);
  final result = await repo.getCertificateById(id);
  return result.fold((f) => throw f.message, (c) => c);
});

// ── Filter ─────────────────────────────────────────────────────────────────

final certFilterProvider = StateProvider<CertStatus?>((ref) => null);

// ── Add controller ─────────────────────────────────────────────────────────

class AddCertState {
  final String name;
  final String type;
  final DateTime? issuedDate;
  final DateTime? expiryDate;
  final String issuer;
  final String? documentPath;
  final bool isLoading;
  final String? error;

  const AddCertState({
    this.name = '',
    this.type = 'STCW',
    this.issuedDate,
    this.expiryDate,
    this.issuer = '',
    this.documentPath,
    this.isLoading = false,
    this.error,
  });

  AddCertState copyWith({
    String? name, String? type, DateTime? issuedDate, DateTime? expiryDate,
    String? issuer, String? documentPath, bool? isLoading, String? error,
  }) => AddCertState(
    name: name ?? this.name,
    type: type ?? this.type,
    issuedDate: issuedDate ?? this.issuedDate,
    expiryDate: expiryDate ?? this.expiryDate,
    issuer: issuer ?? this.issuer,
    documentPath: documentPath ?? this.documentPath,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

class AddCertController extends StateNotifier<AddCertState> {
  final CertificateRepository _repo;
  AddCertController(this._repo) : super(const AddCertState());

  void update({String? name, String? type, DateTime? issuedDate,
      DateTime? expiryDate, String? issuer}) {
    state = state.copyWith(
      name: name, type: type, issuedDate: issuedDate,
      expiryDate: expiryDate, issuer: issuer,
    );
  }

  Future<void> pickDocument() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null && img.path.isNotEmpty) state = state.copyWith(documentPath: img.path);
  }

  Future<bool> submit(String userId) async {
    state = state.copyWith(isLoading: true);
    String? docUrl;

    // First insert to get id, then upload if doc selected
    final result = await _repo.addCertificate(AddCertParams(
      userId: userId,
      name: state.name,
      type: state.type,
      issuedDate: state.issuedDate!,
      expiryDate: state.expiryDate!,
      issuer: state.issuer.isEmpty ? null : state.issuer,
    ));

    return await result.fold(
      (f) async {
        state = state.copyWith(isLoading: false, error: f.message);
        return false;
      },
      (cert) async {
        if (state.documentPath != null) {
          final up = await _repo.uploadDocument(state.documentPath!, cert.id);
          docUrl = up.fold((_) => null, (url) => url);
          if (docUrl != null) {
            await _repo.updateCertificate(UpdateCertParams(id: cert.id, documentUrl: docUrl));
          }
        }
        state = const AddCertState();
        return true;
      },
    );
  }
}

final addCertControllerProvider =
    StateNotifierProvider.autoDispose<AddCertController, AddCertState>((ref) {
  return AddCertController(ref.watch(certificateRepositoryProvider));
});
