import 'dart:async';

import 'package:clean_architecture_flutter/data/repositories/posts/posts_repository.dart';
import 'package:clean_architecture_flutter/domain/models/post.dart';
import 'package:clean_architecture_flutter/ui/posts/view_models/posts_list_viewmodel.dart';
import 'package:clean_architecture_flutter/ui/posts/widgets/posts_list_screen.dart';
import 'package:clean_architecture_flutter/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../utils/fakes.dart';

/// A repository whose getPosts() future is controlled by the test, so we can
/// observe the "running" UI state before completing the request.
class _PendingPostsRepository implements PostsRepository {
  final Completer<Result<List<Post>>> completer = Completer();

  @override
  Future<Result<List<Post>>> getPosts() => completer.future;

  @override
  Future<Result<Post>> getPost(int id) async => Result.error(Exception('n/a'));
}

/// Widget test that wires the real ViewModel to a fake Repository, exactly
/// like the architecture guide recommends: test the View end-to-end while
/// keeping the data layer under our control.
void main() {
  Future<void> pumpScreen(WidgetTester tester, FakePostsRepository repo) {
    return tester.pumpWidget(
      MaterialApp(
        home: PostsListScreen(
          viewModel: PostsListViewModel(postsRepository: repo),
        ),
      ),
    );
  }

  testWidgets('shows a spinner while the load command is running', (
    tester,
  ) async {
    final pending = _PendingPostsRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: PostsListScreen(
          viewModel: PostsListViewModel(postsRepository: pending),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let the future resolve so the test exits cleanly.
    pending.completer.complete(const Result.ok([]));
    await tester.pumpAndSettle();
  });

  testWidgets('renders the posts returned by the repository', (tester) async {
    await pumpScreen(tester, FakePostsRepository());

    await tester.pumpAndSettle();

    expect(find.text('first'), findsOneWidget);
    expect(find.text('second'), findsOneWidget);
  });

  testWidgets('shows the error indicator with a retry button on failure', (
    tester,
  ) async {
    await pumpScreen(tester, FakePostsRepository(fail: true));

    await tester.pumpAndSettle();

    expect(find.text('Could not load posts.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('retry button re-runs the load command', (tester) async {
    final repo = FakePostsRepository(fail: true);
    await pumpScreen(tester, repo);
    await tester.pumpAndSettle();

    repo.fail = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(repo.getPostsCalls, 2);
    expect(find.text('first'), findsOneWidget);
  });
}
