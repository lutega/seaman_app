import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/sea_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _client;

  ProfileRepositoryImpl(this._client);

  @override
  Future<Either<Failure, SeaProfile?>> getProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return right(null);
      return right(ProfileModel.fromJson(data).toDomain());
    } catch (_) {
      return left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, SeaProfile>> createProfile(CreateProfileParams params) async {
    try {
      final nikLast4 = params.nik.length >= 4 ? params.nik.substring(params.nik.length - 4) : params.nik;

      final payload = {
        'id': params.userId,
        'full_name': params.fullName,
        'birth_date': params.birthDate.toIso8601String().split('T').first,
        'nik_encrypted': params.nik,
        'nik_last_4': nikLast4,
        'address': params.address,
        if (params.seafarerNumber != null && params.seafarerNumber!.isNotEmpty)
          'seafarer_number': params.seafarerNumber,
        if (params.phone != null) 'phone': params.phone,
        if (params.ktpDocumentUrl != null) 'ktp_document_url': params.ktpDocumentUrl,
        if (params.selfieDocumentUrl != null) 'selfie_document_url': params.selfieDocumentUrl,
        'verification_status': 'pending',
      };

      final data = await _client.from('profiles').insert(payload).select().single();
      return right(ProfileModel.fromJson(data).toDomain());
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return _updateExisting(params);
      }
      return left(ServerFailure(e.message));
    } catch (_) {
      return left(const NetworkFailure());
    }
  }

  Future<Either<Failure, SeaProfile>> _updateExisting(CreateProfileParams params) async {
    try {
      final nikLast4 = params.nik.length >= 4 ? params.nik.substring(params.nik.length - 4) : params.nik;
      final data = await _client
          .from('profiles')
          .update({
            'full_name': params.fullName,
            'birth_date': params.birthDate.toIso8601String().split('T').first,
            'nik_encrypted': params.nik,
            'nik_last_4': nikLast4,
            'address': params.address,
            if (params.seafarerNumber != null && params.seafarerNumber!.isNotEmpty)
              'seafarer_number': params.seafarerNumber,
            if (params.ktpDocumentUrl != null) 'ktp_document_url': params.ktpDocumentUrl,
            if (params.selfieDocumentUrl != null) 'selfie_document_url': params.selfieDocumentUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', params.userId)
          .select()
          .single();
      return right(ProfileModel.fromJson(data).toDomain());
    } catch (_) {
      return left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, SeaProfile>> updateProfile(UpdateProfileParams params) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
        if (params.fullName != null) 'full_name': params.fullName,
        if (params.birthDate != null)
          'birth_date': params.birthDate!.toIso8601String().split('T').first,
        if (params.address != null) 'address': params.address,
        if (params.seafarerNumber != null) 'seafarer_number': params.seafarerNumber,
        if (params.phone != null) 'phone': params.phone,
        if (params.avatarUrl != null) 'avatar_url': params.avatarUrl,
      };

      final data = await _client
          .from('profiles')
          .update(updates)
          .eq('id', params.userId)
          .select()
          .single();
      return right(ProfileModel.fromJson(data).toDomain());
    } on PostgrestException catch (e) {
      return left(ServerFailure(e.message));
    } catch (_) {
      return left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, String>> uploadDocument(String filePath, String fileName) async {
    try {
      final file = File(filePath);
      final userId = _client.auth.currentUser?.id ?? 'unknown';
      // Path must start with userId/ for RLS policy to match
      final storagePath = '$userId/$fileName';

      await _client.storage.from('user-documents').upload(
            storagePath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      // Bucket is private — store path, generate signed URL when displaying
      return right(storagePath);
    } catch (e) {
      return left(StorageFailure(e.toString()));
    }
  }
}
