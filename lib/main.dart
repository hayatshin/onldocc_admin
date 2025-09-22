import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/firebase_options.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/injicare_font.dart';
import 'package:onldocc_admin/router.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  try {
    await dotenv.load(fileName: "env");

    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (kIsWeb) {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    }

    final supabaseUrlDebug = dotenv.env["SUPABASE_URL"];
    final supabaseAnonKeyDebug = dotenv.env["SUPABASE_ANONKEY"];

    await Supabase.initialize(
        url: supabaseUrlDebug!,
        anonKey: supabaseAnonKeyDebug!,
        accessToken: () async {
          final token = await FirebaseAuth.instance.currentUser?.getIdToken();
          return token;
        });

    GoRouter.optionURLReflectsImperativeAPIs = true;
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
      ],
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
      title: '인지케어 관리자페이지',
      scrollBehavior:
          ScrollConfiguration.of(context).copyWith(scrollbars: false),
      theme: ThemeData(
        fontFamily: "Pretendard",
        colorScheme: ColorScheme.light(
          primary: InjicareColor().secondary50,
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: InjicareColor().gray100,
        ),
        datePickerTheme: DatePickerThemeData(
          headerBackgroundColor: InjicareColor().secondary20,
          cancelButtonStyle: ButtonStyle(
            elevation: const WidgetStatePropertyAll(0),
            textStyle: WidgetStatePropertyAll(InjicareFont().body03),
          ),
          confirmButtonStyle: ButtonStyle(
            elevation: const WidgetStatePropertyAll(0),
            textStyle: WidgetStatePropertyAll(InjicareFont().body03),
          ),
        ),
        primaryColor: InjicareColor().primary50,
        // canvasColor: Colors.blueGrey.shade500,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
        ),
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        scrollbarTheme: ScrollbarThemeData(
          thumbColor:
              WidgetStateProperty.all<Color>(InjicareColor().secondary20),
          thickness: WidgetStateProperty.all<double>(8.0),
          radius: const Radius.circular(10),
        ),
      ),
    );
  }
}
