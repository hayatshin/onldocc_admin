class AppConfig {
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANONKEY');
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const chatgptApiKey = String.fromEnvironment('CHATGPT_API_KEY');
  static const chatgptOrgId = String.fromEnvironment('CHATGPT_ORG_ID');
}
