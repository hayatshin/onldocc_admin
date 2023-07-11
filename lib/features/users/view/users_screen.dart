import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view_models/contract_config_vm.dart';

class UsersScreen extends ConsumerWidget {
  static const routeURL = "/users";
  static const routeName = "users";
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(contractConfigProvider).when(
          data: (data) => Text("${data.contractType} ${data.contractName}"),
          error: (error, stackTrace) => Text(error.toString()),
          loading: () => const Text("loading"),
        );
  }
}
