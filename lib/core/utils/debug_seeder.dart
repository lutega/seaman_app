import 'package:supabase_flutter/supabase_flutter.dart';

class DebugSeeder {
  static final _db = Supabase.instance.client;

  static Future<Map<String, dynamic>> seedAll() async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return {'error': 'User tidak login'};

    final results = <String, dynamic>{};

    // 1. Profile
    try {
      await _db.from('profiles').upsert({
        'id': userId,
        'full_name': 'Test Pelaut Dummy',
        'birth_date': '1990-05-15',
        'nik_encrypted': 'dummy_encrypted_nik',
        'nik_last_4': '1234',
        'address': 'Jl. Test No. 99, Jakarta Utara',
        'seafarer_number': 'AB123456',
        'phone': '08123456789',
        'verification_status': 'pending',
      }, onConflict: 'id');
      results['profiles'] = 'OK';
    } catch (e) {
      results['profiles'] = 'ERROR: $e';
    }

    // 2. Certificate
    try {
      await _db.from('certificates').insert({
        'user_id': userId,
        'name': 'Basic Safety Training (BST)',
        'type': 'STCW',
        'issued_date': '2022-01-10',
        'expiry_date': '2027-01-10',
        'issuer': 'PMTC Jakarta',
      });
      results['certificates'] = 'OK';
    } catch (e) {
      results['certificates'] = 'ERROR: $e';
    }

    // 3. Enrollment (pakai course pertama yang ada)
    try {
      final courses = await _db.from('courses').select('id').limit(1);
      if (courses.isNotEmpty) {
        final courseId = courses[0]['id'];
        final enrollment = await _db.from('enrollments').insert({
          'user_id': userId,
          'course_id': courseId,
        }).select('id').single();
        results['enrollments'] = 'OK (id: ${enrollment['id'].toString().substring(0, 8)}...)';
      } else {
        results['enrollments'] = 'SKIP: tidak ada kursus';
      }
    } catch (e) {
      results['enrollments'] = 'ERROR: $e';
    }

    // 4. User points
    try {
      await _db.from('user_points').upsert({
        'user_id': userId,
        'total_points': 75,
        'streak_count': 3,
      }, onConflict: 'user_id');
      results['user_points'] = 'OK (75 poin)';
    } catch (e) {
      results['user_points'] = 'ERROR: $e';
    }

    // 5. Point transaction
    try {
      await _db.from('point_transactions').insert({
        'user_id': userId,
        'points': 75,
        'reason': 'Dummy seed — test API connection',
      });
      results['point_transactions'] = 'OK';
    } catch (e) {
      results['point_transactions'] = 'ERROR: $e';
    }

    return results;
  }
}
