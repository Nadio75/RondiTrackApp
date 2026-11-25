import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/images/proof_image_processor.dart';
import '../../../core/network/dio_provider.dart';
import '../../session/presentation/session_provider.dart';
import '../../session/presentation/session_origin_provider.dart';
import '../data/proof_upload_service.dart';

class ProofUploadPanel extends ConsumerStatefulWidget {
  const ProofUploadPanel({
    super.key,
    required this.stokvelId,
    required this.contributionId,
    required this.isClosed,
  });

  final String stokvelId;
  final String contributionId;
  final bool isClosed;

  @override
  ConsumerState<ProofUploadPanel> createState() => _ProofUploadPanelState();
}

class _ProofUploadPanelState extends ConsumerState<ProofUploadPanel> {
  final _picker = ImagePicker();

  Uint8List? _preview;
  CancelToken? _cancelToken;

  bool _busy = false;
  bool _uploaded = false;
  bool _statusLoading = true;
  bool _statusFailed = false;
  double? _progress;
  String? _message;

  bool _current(String accountId, int generation) {
    return mounted &&
        ref.read(sessionProvider)?.id == accountId &&
        ref.read(sessionOriginProvider) == SessionOrigin.api &&
        ref.read(apiAuthClientProvider).sessionGeneration == generation;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadProofStatus();
    });
  }

  Future<void> _loadProofStatus() async {
    if (_busy) return;

    final account = ref.read(sessionProvider);
    final auth = ref.read(apiAuthClientProvider);

    if (account == null || !auth.isAuthenticated) return;

    final generation = auth.sessionGeneration;

    if (!_current(account.id, generation)) return;

    setState(() {
      _statusLoading = true;
      _statusFailed = false;
    });

    final token = CancelToken();
    _cancelToken = token;

    try {
      final response = await ref
          .read(dioProvider)
          .get<Map<String, dynamic>>(
            '/api/v1/stokvels/${widget.stokvelId}'
            '/contributions/${widget.contributionId}/proof/status',
            cancelToken: token,
            options: Options(
              extra: {'requiredAuthSessionGeneration': generation},
            ),
          );

      if (!_current(account.id, generation)) return;

      final hasReceipt = response.data?['hasReceipt'];

      if (hasReceipt is! bool) {
        throw const FormatException('Invalid receipt status.');
      }

      setState(() {
        _uploaded = hasReceipt;
      });
    } catch (_) {
      if (!_current(account.id, generation)) return;

      setState(() {
        _statusFailed = true;
      });
    } finally {
      if (_current(account.id, generation)) {
        setState(() {
          _statusLoading = false;
          _cancelToken = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    _preview = null;
    super.dispose();
  }

  Future<void> _select(ImageSource source) async {
    if (_busy || _statusLoading || _statusFailed || widget.isClosed) return;

    final account = ref.read(sessionProvider);
    final auth = ref.read(apiAuthClientProvider);

    if (account == null || !auth.isAuthenticated) return;

    final generation = auth.sessionGeneration;

    setState(() {
      _busy = true;
      _message = null;
      _preview = null;
    });

    try {
      final selected = await _picker.pickImage(
        source: source,
        requestFullMetadata: false,
      );

      if (selected == null || !_current(account.id, generation)) {
        return;
      }

      if (await selected.length() > ProofImageProcessor.maxInputBytes) {
        throw const FormatException('Image too large.');
      }

      final bytes = await selected.readAsBytes();

      if (!_current(account.id, generation)) return;

      final prepared = await ProofImageProcessor.prepare(bytes);

      if (!_current(account.id, generation)) return;

      setState(() {
        _preview = prepared;
      });
    } catch (_) {
      if (!_current(account.id, generation)) return;

      setState(() {
        _message =
            'Unable to prepare this image. '
            'Choose a supported photograph smaller than 25 MiB.';
      });
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _upload() async {
    final image = _preview;

    if (_busy || image == null || widget.isClosed) return;

    final account = ref.read(sessionProvider);
    final auth = ref.read(apiAuthClientProvider);

    if (account == null || !auth.isAuthenticated) return;

    final generation = auth.sessionGeneration;
    final cancelToken = CancelToken();

    _cancelToken = cancelToken;

    setState(() {
      _busy = true;
      _message = null;
      _progress = 0;
    });

    try {
      await ref
          .read(proofUploadServiceProvider)
          .upload(
            stokvelId: widget.stokvelId,
            contributionId: widget.contributionId,
            jpeg: image,
            sessionGeneration: generation,
            cancelToken: cancelToken,
            onProgress: (sent, total) {
              if (!_current(account.id, generation)) return;

              setState(() {
                _progress = total > 0
                    ? (sent / total).clamp(0.0, 1.0).toDouble()
                    : null;
              });
            },
          );

      if (!_current(account.id, generation)) return;

      setState(() {
        _uploaded = true;
        _preview = null;
        _message = 'Proof of payment uploaded successfully.';
      });
    } on DioException catch (error) {
      if (!_current(account.id, generation)) return;

      final status = error.response?.statusCode;

      setState(() {
        _message = switch (status) {
          401 => 'Please sign in again.',
          403 || 404 => 'This contribution is unavailable.',
          409 => 'This contribution can no longer be updated.',
          413 => 'The photograph exceeds the upload limit.',
          400 || 422 => 'The photograph was rejected.',
          429 => 'Too many requests. Please try again later.',
          _ =>
            CancelToken.isCancel(error)
                ? 'Upload cancelled.'
                : 'Upload failed. Check your connection and retry.',
        };
      });
    } catch (_) {
      if (!_current(account.id, generation)) return;

      setState(() {
        _message = 'Unable to upload proof. Please try again.';
      });
    } finally {
      _cancelToken = null;

      if (mounted) {
        setState(() {
          _busy = false;
          _progress = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider);
    final origin = ref.watch(sessionOriginProvider);

    if (user == null || origin != SessionOrigin.api) {
      return const SizedBox.shrink();
    }

    final cameraSupported =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Proof of payment',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (_statusLoading)
              const LinearProgressIndicator()
            else if (_statusFailed) ...[
              const Text('Unable to retrieve saved proof status.'),
              TextButton(
                onPressed: _busy ? null : _loadProofStatus,
                child: const Text('Retry proof status'),
              ),
            ] else if (_uploaded) ...[
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              const Text(
                'Proof of payment uploaded',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
            ] else
              const Text('No proof of payment uploaded.'),
            const SizedBox(height: 12),
            if (widget.isClosed)
              const Text('Proof cannot be changed for a closed cycle.')
            else ...[
              if (_preview != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _preview!,
                    height: 220,
                    fit: BoxFit.contain,
                    gaplessPlayback: false,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${(_preview!.length / 1024).toStringAsFixed(0)} KB'
                  ' - JPEG',
                ),
              ],
              if (cameraSupported)
                FilledButton.icon(
                  key: const Key('proof_camera'),
                  onPressed: _busy || _statusLoading || _statusFailed
                      ? null
                      : () => _select(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Take a photo'),
                ),
              OutlinedButton.icon(
                key: const Key('proof_gallery'),
                onPressed: _busy || _statusLoading || _statusFailed
                    ? null
                    : () => _select(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(
                  _uploaded
                      ? 'Replace proof from gallery'
                      : 'Choose from gallery',
                ),
              ),
              if (_preview != null)
                FilledButton.icon(
                  key: const Key('proof_upload'),
                  onPressed: _busy ? null : _upload,
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const Text('Upload proof'),
                ),
              if (_busy) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(value: _progress),
                if (_cancelToken != null)
                  TextButton(
                    onPressed: () => _cancelToken?.cancel(),
                    child: const Text('Cancel upload'),
                  ),
              ],
              const SizedBox(height: 12),
              const Text(
                'Embedded location metadata is removed '
                'before uploading.',
              ),
            ],
            if (_message != null) ...[
              const SizedBox(height: 12),
              Semantics(liveRegion: true, child: Text(_message!)),
            ],
          ],
        ),
      ),
    );
  }
}
