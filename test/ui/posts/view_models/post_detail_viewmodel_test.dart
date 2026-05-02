import 'package:clean_architecture_flutter/ui/posts/view_models/post_detail_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../utils/fakes.dart';

void main() {
  group('PostDetailViewModel', () {
    test('loads the requested post AND its comments in parallel', () async {
      final postsRepo = FakePostsRepository();
      final commentsRepo = FakeCommentsRepository();

      final vm = PostDetailViewModel(
        postsRepository: postsRepo,
        commentsRepository: commentsRepo,
        postId: 1,
      );
      await Future<void>.delayed(Duration.zero);

      expect(vm.loadPost.completed, isTrue);
      expect(vm.loadComments.completed, isTrue);
      expect(vm.post, fakePost1);
      expect(vm.comments, [fakeComment1, fakeComment2]);
    });

    test('a comments failure does NOT mask the post load', () async {
      final postsRepo = FakePostsRepository();
      final commentsRepo = FakeCommentsRepository(fail: true);

      final vm = PostDetailViewModel(
        postsRepository: postsRepo,
        commentsRepository: commentsRepo,
        postId: 1,
      );
      await Future<void>.delayed(Duration.zero);

      expect(vm.loadPost.completed, isTrue);
      expect(vm.post, fakePost1);
      expect(vm.loadComments.error, isTrue);
      expect(vm.comments, isEmpty);
    });

    test('keeps post=null on post-load failure', () async {
      final postsRepo = FakePostsRepository(fail: true);
      final commentsRepo = FakeCommentsRepository();

      final vm = PostDetailViewModel(
        postsRepository: postsRepo,
        commentsRepository: commentsRepo,
        postId: 1,
      );
      await Future<void>.delayed(Duration.zero);

      expect(vm.loadPost.error, isTrue);
      expect(vm.post, isNull);
    });
  });
}
