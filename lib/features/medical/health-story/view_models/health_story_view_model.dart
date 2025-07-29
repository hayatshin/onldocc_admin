import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/medical/health-story/models/health_story_model.dart';
import 'package:onldocc_admin/features/medical/health-story/repo/health_story_repo.dart';

class HealthStoryViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> insertHealthStory(HealthStoryModel model) async {
    await ref.read(healthStoryRepo).insertHealthStory(model.toJson());
  }

  Future<List<HealthStoryModel>> fetchAllHealthStories() async {
    final data = await ref.read(healthStoryRepo).fetchAllHealthStories();
    return data.map((e) => HealthStoryModel.fromJson(e)).toList();
  }
}

final healthStoryProvider = AsyncNotifierProvider<HealthStoryViewModel, void>(
    () => HealthStoryViewModel());
