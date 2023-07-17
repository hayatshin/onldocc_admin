import 'package:flutter/material.dart';
import 'package:onldocc_admin/constants/sizes.dart';

class SearchBelow extends StatefulWidget {
  final Widget child;
  const SearchBelow({super.key, required this.child});

  @override
  State<SearchBelow> createState() => _SearchBelowState();
}

class _SearchBelowState extends State<SearchBelow> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) => Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
          ),
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.size32,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
