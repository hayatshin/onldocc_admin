import 'package:flutter/material.dart';

class EventDetailScreen extends StatefulWidget {
  final String? eventId;
  const EventDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("event: detail ${widget.eventId}"),
    );
  }
}
