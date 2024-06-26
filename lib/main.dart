import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/firebase_options.dart';
import 'package:onldocc_admin/router.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  try {
    // await dotenv.load();
    await dotenv.load(fileName: "env");

    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final supabaseUrlDebug = dotenv.env["SUPABASE_URL"];
    final supabaseAnonKeyDebug = dotenv.env["SUPABASE_ANONKEY"];

    await Supabase.initialize(
      url: supabaseUrlDebug!,
      anonKey: supabaseAnonKeyDebug!,
    );

    await SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
      ],
    );
  } catch (e) {
    // ignore: avoid_print
    print("failed to initialize: $e");
  }

  runApp(
    const ProviderScope(
      child: OnldoccAdmin(),
    ),
  );
  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is stack_trace.Trace) return stack.vmTrace;
    if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
    return stack;
  };
}

class OnldoccAdmin extends ConsumerWidget {
  const OnldoccAdmin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
      title: '인지케어 관리자페이지',
      scrollBehavior:
          ScrollConfiguration.of(context).copyWith(scrollbars: false),
      theme: ThemeData(
        fontFamily: "NanumSquare",
        primaryColor: const Color(0xFFFF2D78),
        canvasColor: Colors.blueGrey.shade500,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
        ),
        dividerColor: Colors.transparent,
      ),
    );
  }
}
