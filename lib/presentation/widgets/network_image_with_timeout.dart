import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:maawa_project/core/theme/app_theme.dart';

/// A network image widget with timeout handling and better error management
class NetworkImageWithTimeout extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Duration timeout;
  final Widget? placeholder;
  final Widget? errorWidget;

  const NetworkImageWithTimeout({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.timeout = const Duration(seconds: 10),
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<NetworkImageWithTimeout> createState() => _NetworkImageWithTimeoutState();
}

class _NetworkImageWithTimeoutState extends State<NetworkImageWithTimeout> {
  bool _hasTimedOut = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    // Start timeout timer
    _timeoutTimer = Timer(widget.timeout, () {
      if (mounted && !_hasTimedOut) {
        setState(() {
          _hasTimedOut = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }
    return Container(
      width: widget.width,
      height: widget.height,
      color: AppTheme.gray200,
      child: _hasTimedOut
          ? const Icon(
              Icons.image_not_supported,
              size: 48,
              color: AppTheme.gray400,
            )
          : const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
    );
  }

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }
    return Container(
      width: widget.width,
      height: widget.height,
      color: AppTheme.gray200,
      child: const Icon(
        Icons.image_not_supported,
        size: 48,
        color: AppTheme.gray400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Validate URL first
    if (!_isValidUrl(widget.imageUrl)) {
      if (kDebugMode) {
        debugPrint('⚠️ Invalid image URL: ${widget.imageUrl}');
      }
      return _buildErrorWidget();
    }

    // If timed out, show error widget
    if (_hasTimedOut) {
      return _buildErrorWidget();
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _hasTimedOut
          ? _buildErrorWidget()
          : CachedNetworkImage(
              imageUrl: widget.imageUrl,
              fit: widget.fit,
              fadeInDuration: const Duration(milliseconds: 200),
              fadeOutDuration: const Duration(milliseconds: 100),
              placeholder: (context, url) => _buildPlaceholder(),
              errorWidget: (context, url, error) {
                // Cancel timeout timer on error
                _timeoutTimer?.cancel();
                if (kDebugMode) {
                  debugPrint('❌ Failed to load image: $url');
                  debugPrint('   Error: $error');
                }
                return _buildErrorWidget();
              },
              httpHeaders: const {
                'Cache-Control': 'max-age=3600',
              },
            ),
    );
  }
}

