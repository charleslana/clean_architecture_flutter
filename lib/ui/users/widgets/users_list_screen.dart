import 'package:flutter/material.dart';

import '../../../domain/models/user.dart';
import '../../../utils/error_message.dart';
import '../../../utils/result.dart';
import '../../core/ui/error_indicator.dart';
import '../view_models/users_list_viewmodel.dart';

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({super.key, required this.viewModel});

  final UsersListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: ListenableBuilder(
        listenable: viewModel.load,
        builder: (context, _) {
          if (viewModel.load.running) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.load.error) {
            final result = viewModel.load.result;
            final exception = result is Error<List<User>> ? result.error : null;
            return ErrorIndicator(
              message: 'Could not load users.',
              detail: errorMessageFor(exception),
              onRetry: viewModel.load.execute,
            );
          }
          return ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) {
              final users = viewModel.users;
              return RefreshIndicator(
                onRefresh: viewModel.load.execute,
                child: ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(user.name.characters.first),
                      ),
                      title: Text(user.name),
                      subtitle: Text(
                        '@${user.username} · ${user.address.city}',
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
