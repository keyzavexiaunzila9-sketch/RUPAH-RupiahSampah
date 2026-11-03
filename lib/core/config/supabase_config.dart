import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl =
      'https://cvbvavmwfnucyvuvnewt.supabase.co/';

  static const String supabaseKey =
      'sb_publishable_wvECtvnWZEw_l3CHWlohiw_IbpxwrID';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseKey,
    );
  }
}

final supabase = Supabase.instance.client;