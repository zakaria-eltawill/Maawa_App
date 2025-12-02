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
    this.timeout = const Duration(seconds: 15),
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<NetworkImageWithTimeout> createState() => _NetworkImageWithTimeoutState();
}

class _NetworkImageWithTimeoutState extends State<NetworkImageWithTimeout> {
  bool _hasTimedOut = false;
  bool _hasLoaded = false;
  Timer? _timeoutTimer;
  bool _callbackScheduled = false;

  @override
  void initState() {
    super.initState();
    // Start timeout with longer duration to avoid false timeouts
    // The timeout will be cancelled as soon as the image loads
    _startTimeout();
  }

  @override
  void didUpdateWidget(NetworkImageWithTimeout oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If URL changed, reset state and restart timeout
    if (oldWidget.imageUrl != widget.imageUrl) {
      _timeoutTimer?.cancel();
      _hasTimedOut = false;
      _hasLoaded = false;
      _callbackScheduled = false;
      _startTimeout();
    }
  }

  void _startTimeout() {
    _timeoutTimer?.cancel();
    // Only start timeout if image hasn't loaded yet
    if (!_hasLoaded) {
      _timeoutTimer = Timer(widget.timeout, () {
        if (mounted && !_hasTimedOut && !_hasLoaded) {
          setState(() {
            _hasTimedOut = true;
          });
        }
      });
    }
  }

  void _onImageLoaded() {
    _timeoutTimer?.cancel();
    if (mounted && !_hasLoaded) {
      setState(() {
        _hasLoaded = true;
        _hasTimedOut = false; // Reset timeout if image loads
      });
    }
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

    // If timed out and not loaded, show error widget
    if (_hasTimedOut && !_hasLoaded) {
      return _buildErrorWidget();
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: CachedNetworkImage(
        imageUrl: widget.imageUrl,
        fit: widget.fit,
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 100),
        placeholder: (context, url) {
          // Image is loading, but don't timeout if it's from cache
          return _buildPlaceholder();
        },
        errorWidget: (context, url, error) {
          // Cancel timeout timer on error - defer to avoid setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _timeoutTimer?.cancel();
          });
          if (kDebugMode) {
            debugPrint('❌ Failed to load image: $url');
            debugPrint('   Error: $error');
          }
          return _buildErrorWidget();
        },
        // Use imageBuilder to detect when image successfully loads
        imageBuilder: (context, imageProvider) {
          // Image loaded successfully (from cache or network) - cancel timeout
          // Defer state update to after build phase to avoid setState during build
          if (!_callbackScheduled && !_hasLoaded) {
            _callbackScheduled = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _onImageLoaded();
              _callbackScheduled = false;
            });
          }
          return Image(
            image: imageProvider,
            fit: widget.fit,
          );
        },
        httpHeaders: const {
          'Cache-Control': 'max-age=3600',
        },
        // Increase cache duration to prevent re-fetching
        memCacheWidth: widget.width != null ? widget.width!.toInt() : null,
        memCacheHeight: widget.height != null ? widget.height!.toInt() : null,
      ),
    );
  }
}

