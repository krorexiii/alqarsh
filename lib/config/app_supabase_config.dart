class AppSupabaseConfig {
  static const String projectRef = 'mmuzcznpbvzbfvxpsiex';
  static const String url = 'https://mmuzcznpbvzbfvxpsiex.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1tdXpjem5wYnZ6YmZ2eHBzaWV4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYyNzIyMjksImV4cCI6MjA5MTg0ODIyOX0.aCVSE5nhDIiMfp6KEcJi_ZlznsjEPQi-sktG50NKK5c';
  static const String shopId = '550e8400-e29b-41d4-a716-446655440001';
  static const String recoveryRedirectUrl = 'http://localhost:52157/';

  static String publicStorageUrl({
    required String bucket,
    required String path,
  }) {
    final String normalizedPath = path.startsWith('/')
        ? path.substring(1)
        : path;
    return '$url/storage/v1/object/public/$bucket/$normalizedPath';
  }
}
