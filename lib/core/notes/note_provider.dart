// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../boorus/engine/providers.dart';
import '../configs/config.dart';
import '../configs/current.dart';
import '../posts/post/post.dart';
import 'notes.dart';

final notesControllerProvider = NotifierProvider.autoDispose
    .family<NotesControllerNotifier, NotesControllerState, Post>(
  NotesControllerNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
  ],
);

final emptyNoteRepoProvider = Provider<NoteRepository>(
  (_) => const EmptyNoteRepository(),
);

final noteRepoProvider = Provider.family<NoteRepository, BooruConfigAuth>(
  (ref, config) {
    final repo =
        ref.watch(booruEngineRegistryProvider).getRepository(config.booruType);

    final noteRepo = repo?.note(config);

    if (noteRepo != null) {
      return noteRepo;
    }

    return ref.watch(emptyNoteRepoProvider);
  },
);
