import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/certificate.dart';
import '../../domain/repositories/certificate_repository.dart';
import '../models/certificate_model.dart';

class CertificateRepositoryImpl implements CertificateRepository {
  final SupabaseClient _client;
  CertificateRepositoryImpl(this._client);

  @override
  Future<Either<Failure, List<Certificate>>> getCertificates(String userId) async {
    try {
      final data = await _client
          .from('certificates')
          .select()
          .eq('user_id', userId)
          .order('expiry_date');
      return right((data as List).map((e) => CertificateModel.fromJson(e).toDomain()).toList());
    } catch (_) {
      return left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Certificate>> getCertificateById(String id) async {
    try {
      final data = await _client.from('certificates').select().eq('id', id).single();
      return right(CertificateModel.fromJson(data).toDomain());
    } catch (_) {
      return left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Certificate>> addCertificate(AddCertParams params) async {
    try {
      final data = await _client.from('certificates').insert({
        'user_id': params.userId,
        'name': params.name,
        'type': params.type,
        'issued_date': params.issuedDate.toIso8601String().split('T').first,
        'expiry_date': params.expiryDate.toIso8601String().split('T').first,
        if (params.issuer != null) 'issuer': params.issuer,
        if (params.documentUrl != null) 'document_url': params.documentUrl,
      }).select().single();
      return right(CertificateModel.fromJson(data).toDomain());
    } on PostgrestException catch (e) {
      return left(ServerFailure(e.message));
    } catch (_) {
      return left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Certificate>> updateCertificate(UpdateCertParams params) async {
    try {
      final updates = <String, dynamic>{
        if (params.name != null) 'name': params.name,
        if (params.type != null) 'type': params.type,
        if (params.issuedDate != null)
          'issued_date': params.issuedDate!.toIso8601String().split('T').first,
        if (params.expiryDate != null)
          'expiry_date': params.expiryDate!.toIso8601String().split('T').first,
        if (params.issuer != null) 'issuer': params.issuer,
        if (params.documentUrl != null) 'document_url': params.documentUrl,
      };
      final data = await _client
          .from('certificates')
          .update(updates)
          .eq('id', params.id)
          .select()
          .single();
      return right(CertificateModel.fromJson(data).toDomain());
    } catch (_) {
      return left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCertificate(String id) async {
    try {
      await _client.from('certificates').delete().eq('id', id);
      return right(unit);
    } catch (_) {
      return left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, String>> uploadDocument(String filePath, String certId) async {
    try {
      final userId = _client.auth.currentUser?.id ?? 'unknown';
      final path = 'certificates/$userId/$certId.jpg';
      await _client.storage
          .from('user-documents')
          .upload(path, File(filePath), fileOptions: const FileOptions(upsert: true));
      return right(_client.storage.from('user-documents').getPublicUrl(path));
    } catch (_) {
      return left(const StorageFailure());
    }
  }
}
