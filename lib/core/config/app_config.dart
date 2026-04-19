class AppConfig {
  AppConfig._();

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );

  static const sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  static const appScheme = 'seaready';
  static const appDeepLinkHost = 'auth';
}
