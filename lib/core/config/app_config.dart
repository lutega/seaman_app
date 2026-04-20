class AppConfig {
  AppConfig._();

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://dzbpkwaeinemmxumikeq.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_uv0_7Yt3ZGM7rBlBJjZ_aw_Yf6wSyRX',
  );

  static const sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  static const appScheme = 'seaready';
  static const appDeepLinkHost = 'auth';
}
