import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/utils/validators.dart';
import '../../models/incident_category.dart';
import '../../providers/incident_providers.dart';
import '../../widgets/category_tile.dart';
import '../auth/auth_scaffold.dart';
import '../detail/incident_detail_screen.dart';

/// "Report an Incident" form: category, title, description, location and an
/// optional photo (camera or gallery) that is uploaded to Firebase Storage.
class ReportIncidentScreen extends ConsumerStatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  ConsumerState<ReportIncidentScreen> createState() =>
      _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends ConsumerState<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _roomController = TextEditingController();
  final _picker = ImagePicker();

  IncidentCategory? _category;
  String _location = AppConstants.campusLocations.first;
  File? _photo;
  bool _categoryError = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  String get _fullLocation {
    final room = _roomController.text.trim();
    if (room.isEmpty) return _location;
    return _location == 'Other' ? room : '$_location - $room';
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 1280,
      );
      if (picked == null) return;
      final file = File(picked.path);
      final size = await file.length();
      if (size > AppConstants.maxPhotoBytes) {
        _showMessage('That photo is larger than 5 MB. Please pick a smaller one.',
            isError: true);
        return;
      }
      setState(() => _photo = file);
    } catch (e) {
      _showMessage('Could not open the photo: $e', isError: true);
    }
  }

  void _showMessage(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? AppColors.danger : AppColors.resolved,
      ),
    );
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    setState(() => _categoryError = _category == null);
    if (!formValid || _category == null) return;
    FocusScope.of(context).unfocus();

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final id = await ref.read(submitReportControllerProvider.notifier).submit(
          title: _titleController.text,
          description: _descriptionController.text,
          category: _category!,
          location: _fullLocation,
          photo: _photo,
        );
    if (!mounted) return;

    if (id == null) {
      final error = ref.read(submitReportControllerProvider).error;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not submit the report: $error'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Report submitted. Thank you for helping campus!'),
        backgroundColor: AppColors.resolved,
      ),
    );
    navigator.pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => IncidentDetailScreen(incidentId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final submitting = ref.watch(submitReportControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Report an Incident')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              const FieldLabel('Select a category'),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.35,
                children: [
                  for (final category in IncidentCategory.values)
                    CategoryTile(
                      category: category,
                      selected: _category == category,
                      onTap: () => setState(() {
                        _category = category;
                        _categoryError = false;
                      }),
                    ),
                ],
              ),
              if (_categoryError)
                const Padding(
                  padding: EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    'Please choose a category',
                    style: TextStyle(color: AppColors.danger, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),
              const FieldLabel('Title'),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                maxLength: AppConstants.titleMaxLength,
                decoration: const InputDecoration(
                  hintText: 'Briefly describe the issue...',
                  counterText: '',
                ),
                validator: (v) => Validators.lengthRange(
                  v,
                  min: AppConstants.titleMinLength,
                  max: AppConstants.titleMaxLength,
                  field: 'Title',
                ),
              ),
              const SizedBox(height: 16),
              const FieldLabel('Description'),
              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 5,
                maxLength: AppConstants.descriptionMaxLength,
                decoration: const InputDecoration(
                  hintText: 'Provide more details about the issue...\n'
                      'e.g. what happened, when, impact, etc.',
                  alignLabelWithHint: true,
                ),
                validator: (v) => Validators.lengthRange(
                  v,
                  min: AppConstants.descriptionMinLength,
                  max: AppConstants.descriptionMaxLength,
                  field: 'Description',
                ),
              ),
              const SizedBox(height: 8),
              const FieldLabel('Location'),
              DropdownButtonFormField<String>(
                value: _location,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                items: [
                  for (final loc in AppConstants.campusLocations)
                    DropdownMenuItem(value: loc, child: Text(loc)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _location = value);
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _roomController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: _location == 'Other'
                      ? 'Describe the location'
                      : 'Room / floor / landmark (optional)',
                ),
                validator: (v) {
                  if (_location == 'Other' && (v == null || v.trim().isEmpty)) {
                    return 'Please describe the location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const FieldLabel('Add a photo', optional: true),
              _PhotoPicker(
                photo: _photo,
                onPick: submitting ? null : _pickPhoto,
                onRemove: submitting ? null : () => setState(() => _photo = null),
              ),
              const SizedBox(height: 28),
              LoadingButton(
                label: 'Submit Report',
                loading: submitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.photo,
    required this.onPick,
    required this.onRemove,
  });

  final File? photo;
  final VoidCallback? onPick;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final file = photo;
    if (file == null) {
      return InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_outlined, color: AppColors.textSecondary),
              SizedBox(height: 6),
              Text(
                'Tap to add a photo',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            file,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: onRemove,
              tooltip: 'Remove photo',
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: TextButton.icon(
            onPressed: onPick,
            style: TextButton.styleFrom(
              backgroundColor: Colors.black54,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Change'),
          ),
        ),
      ],
    );
  }
}
