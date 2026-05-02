import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../../core/ui/default_app_bar.dart';
import '../album_draft.dart';

class CreateAlbumStep1Screen extends StatefulWidget {
  const CreateAlbumStep1Screen({super.key});

  @override
  State<CreateAlbumStep1Screen> createState() => _CreateAlbumStep1ScreenState();
}

class _CreateAlbumStep1ScreenState extends State<CreateAlbumStep1Screen> {
  final _userIdController = TextEditingController(text: '1');
  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _userIdController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(title: 'New album · Step 1 of 2'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Fill in both fields. Step 2 will let you review before sending.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _userIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final n = int.tryParse(value ?? '');
                  if (n == null || n <= 0) return 'Enter a positive integer';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next: review'),
                onPressed: _onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final draft = AlbumDraft(
      userId: int.parse(_userIdController.text),
      title: _titleController.text.trim(),
    );

    unawaited(context.push(Routes.adminAlbumsCreateStep2, extra: draft));
  }
}
