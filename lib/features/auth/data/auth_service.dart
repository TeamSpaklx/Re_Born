import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/backend_api_client.dart';

class AuthService {
  AuthService({required this.supabase, required this.api});

  final SupabaseClient supabase;
  final BackendApiClient api;

  Future<bool> signUp({
    required String email,
    required String password,
    required bool consentPrivacy,
    required bool consentAiAnalysis,
  }) async {
    final result = await supabase.auth.signUp(
      email: email.trim(),
      password: password,
    );
    if (result.session == null) return false;

    await api.get('/api/profile');
    await api.put('/api/profile', {
      'consentPrivacy': consentPrivacy,
      'consentAiAnalysis': consentAiAnalysis,
      'consentAnalytics': false,
    });
    return true;
  }

  Future<void> signIn({required String email, required String password}) async {
    await supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    await api.get('/api/profile');
  }

  Future<void> signOut() => supabase.auth.signOut();
}
