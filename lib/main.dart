import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view_models/contract_config_vm.dart';
import 'package:onldocc_admin/firebase_options.dart';
import 'package:onldocc_admin/router.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
      ],
    );
  } catch (e) {
    print("filed to initialize: $e");
  }

  runApp(
    ProviderScope(
      overrides: [
        contractConfigProvider.overrideWith(
          () => ContractConfigViewModel(),
        )
      ],
      child: const OnldoccAdmin(),
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
      title: '오늘도청춘 관리자페이지',
      theme: ThemeData(
        fontFamily: "Spoqa",
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
