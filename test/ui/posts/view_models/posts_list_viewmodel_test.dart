import 'package:clean_architecture_flutter/ui/posts/view_models/posts_list_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../utils/fakes.dart';

void main() {
  group('PostsListViewModel', () {
    test('load command runs on construction and exposes posts', () async {
      final repo = FakePostsRepository();

      final vm = PostsListViewModel(postsRepository: repo);

      // Command0 was triggered in the constructor — wait one microtask round.
      await Future<void>.delayed(Duration.zero);

      expect(repo.getPostsCalls, 1);
      expect(vm.load.completed, isTrue);
      expect(vm.posts, [fakePost1, fakePost2]);
    });

    test('failure surfaces via Command.error and clears posts', () async {
      final repo = FakePostsRepository(fail: true);

      final vm = PostsListViewModel(postsRepository: repo);
      await Future<void>.delayed(Duration.zero);

      expect(vm.load.error, isTrue);
      expect(vm.posts, isEmpty);
    });

    test('load is re-runnable (e.g. for pull-to-refresh)', () async {
      final repo = FakePostsRepository();

      final vm = PostsListViewModel(postsRepository: repo);
      await Future<void>.delayed(Duration.zero);

      await vm.load.execute();

      expect(repo.getPostsCalls, 2);
    });
  });
}
