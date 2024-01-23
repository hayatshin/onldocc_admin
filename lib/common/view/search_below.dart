import 'package:flutter/material.dart';

class SearchBelow extends StatefulWidget {
  final Size size;
  final Widget child;
  const SearchBelow({
    super.key,
    required this.size,
    required this.child,
  });

  @override
  State<SearchBelow> createState() => _SearchBelowState();
}

class _SearchBelowState extends State<SearchBelow> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: widget.child,
    );
  }
}
