import 'package:flutter_compositions/flutter_compositions.dart';
import 'package:tw_reporter_app/core/di/composables.dart';

/// Provides a reactive set of read article slugs from the reading repository.
///
/// Listens to the reading repository (a `ChangeNotifier`) and updates the
/// returned set whenever the reading history changes.
({ReadonlyRef<Set<String>> readSlugs}) useReadingSlugs() {
  final readingRepo = useReadingRepository();
  final readSlugs = ref<Set<String>>(<String>{});

  void syncReadSlugs() {
    readSlugs.value =
        readingRepo.getHistory().map((r) => r.slug).toSet();
  }

  onMounted(() {
    syncReadSlugs();
    readingRepo.addListener(syncReadSlugs);
  });

  onUnmounted(() {
    readingRepo.removeListener(syncReadSlugs);
  });

  return (readSlugs: readSlugs);
}
