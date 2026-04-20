import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/sea_profile.dart';
import '../../domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(Supabase.instance.client);
});

final currentProfileProvider = FutureProvider<SeaProfile?>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return null;
  final repo = ref.watch(profileRepositoryProvider);
  final result = await repo.getProfile(userId);
  return result.fold((_) => null, (profile) => profile);
});

// ── Setup wizard state ─────────────────────────────────────────────────────

class ProfileSetupState {
  // Step 1 — personal data
  final String fullName;
  final DateTime? birthDate;
  final String nik;
  final String address;
  final String seafarerNumber;

  // Step 2 — documents
  final String? ktpImagePath;
  final String? selfieImagePath;

  // Submission
  final bool isLoading;
  final String? error;

  const ProfileSetupState({
    this.fullName = '',
    this.birthDate,
    this.nik = '',
    this.address = '',
    this.seafarerNumber = '',
    this.ktpImagePath,
    this.selfieImagePath,
    this.isLoading = false,
    this.error,
  });

  ProfileSetupState copyWith({
    String? fullName,
    DateTime? birthDate,
    String? nik,
    String? address,
    String? seafarerNumber,
    String? ktpImagePath,
    String? selfieImagePath,
    bool? isLoading,
    String? error,
  }) =>
      ProfileSetupState(
        fullName: fullName ?? this.fullName,
        birthDate: birthDate ?? this.birthDate,
        nik: nik ?? this.nik,
        address: address ?? this.address,
        seafarerNumber: seafarerNumber ?? this.seafarerNumber,
        ktpImagePath: ktpImagePath ?? this.ktpImagePath,
        selfieImagePath: selfieImagePath ?? this.selfieImagePath,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class ProfileSetupController extends StateNotifier<ProfileSetupState> {
  final ProfileRepository _repo;

  ProfileSetupController(this._repo) : super(const ProfileSetupState());

  void updatePersonalData({
    String? fullName,
    DateTime? birthDate,
    String? nik,
    String? address,
    String? seafarerNumber,
  }) {
    state = state.copyWith(
      fullName: fullName,
      birthDate: birthDate,
      nik: nik,
      address: address,
      seafarerNumber: seafarerNumber,
    );
  }

  Future<void> pickKtpImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image != null && image.path.isNotEmpty) state = state.copyWith(ktpImagePath: image.path);
  }

  Future<void> pickKtpFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null && image.path.isNotEmpty) state = state.copyWith(ktpImagePath: image.path);
  }

  Future<void> pickSelfieImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      preferredCameraDevice: CameraDevice.front,
    );
    if (image != null && image.path.isNotEmpty) state = state.copyWith(selfieImagePath: image.path);
  }

  Future<bool> submitProfile(String userId) async {
    state = state.copyWith(isLoading: true);

    String? ktpUrl;
    String? selfieUrl;

    if (state.ktpImagePath != null) {
      final result = await _repo.uploadDocument(state.ktpImagePath!, 'ktp.jpg');
      result.fold((_) {}, (url) => ktpUrl = url);
    }

    if (state.selfieImagePath != null) {
      final result = await _repo.uploadDocument(state.selfieImagePath!, 'selfie.jpg');
      result.fold((_) {}, (url) => selfieUrl = url);
    }

    final result = await _repo.createProfile(CreateProfileParams(
      userId: userId,
      fullName: state.fullName,
      birthDate: state.birthDate!,
      nik: state.nik,
      address: state.address,
      seafarerNumber: state.seafarerNumber.isEmpty ? null : state.seafarerNumber,
      ktpDocumentUrl: ktpUrl,
      selfieDocumentUrl: selfieUrl,
    ));

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = const ProfileSetupState();
        return true;
      },
    );
  }
}

final profileSetupControllerProvider =
    StateNotifierProvider.autoDispose<ProfileSetupController, ProfileSetupState>((ref) {
  return ProfileSetupController(ref.watch(profileRepositoryProvider));
});

// ── Edit state ─────────────────────────────────────────────────────────────

class ProfileEditController extends StateNotifier<AsyncValue<SeaProfile?>> {
  final ProfileRepository _repo;

  ProfileEditController(this._repo) : super(const AsyncValue.loading());

  Future<void> load(String userId) async {
    state = const AsyncValue.loading();
    final result = await _repo.getProfile(userId);
    state = result.fold(
      (f) => AsyncValue.error(f.message, StackTrace.current),
      AsyncValue.data,
    );
  }

  Future<bool> update(UpdateProfileParams params) async {
    final result = await _repo.updateProfile(params);
    return result.fold(
      (_) => false,
      (profile) {
        state = AsyncValue.data(profile);
        return true;
      },
    );
  }
}

final profileEditControllerProvider =
    StateNotifierProvider.autoDispose<ProfileEditController, AsyncValue<SeaProfile?>>((ref) {
  return ProfileEditController(ref.watch(profileRepositoryProvider));
});
