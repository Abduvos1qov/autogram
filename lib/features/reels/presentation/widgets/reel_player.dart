import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/feedback/loading_indicator.dart';
import '../../../../core/widgets/media/cached_image.dart';
import '../../domain/entities/reel.dart';
import 'reel_actions.dart';
import 'reel_overlay.dart';

/// Full-screen reel video player

class ReelPlayer extends StatefulWidget {
  final Reel reel;
  final bool isActive;
  final VoidCallback? onLike;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final VoidCallback? onComment;
  final VoidCallback? onSellerTap;
  final ValueChanged<int>? onViewDuration;

  const ReelPlayer({
    super.key,
    required this.reel,
    required this.isActive,
    this.onLike,
    this.onSave,
    this.onShare,
    this.onComment,
    this.onSellerTap,
    this.onViewDuration,
  });

  @override
  State<ReelPlayer> createState() => _ReelPlayerState();
}

class _ReelPlayerState extends State<ReelPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _hasError = false;
  int _watchedDuration = 0;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.reel.playbackUrl),
    );

    try {
      await _controller.initialize();
      _controller.setLooping(true);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        if (widget.isActive) {
          _play();
        }

        // Track watch duration
        _controller.addListener(_onVideoProgress);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _onVideoProgress() {
    if (_controller.value.isPlaying) {
      final position = _controller.value.position.inSeconds;
      if (position > _watchedDuration) {
        _watchedDuration = position;
      }
    }
  }

  void _play() {
    _controller.play();
    setState(() {
      _isPlaying = true;
    });
  }

  void _pause() {
    _controller.pause();
    setState(() {
      _isPlaying = false;
    });
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _pause();
    } else {
      _play();
    }
  }

  @override
  void didUpdateWidget(ReelPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _play();
      } else {
        _pause();
        // Report watched duration when leaving
        widget.onViewDuration?.call(_watchedDuration);
        _watchedDuration = 0;
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoProgress);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      onDoubleTap: widget.onLike,
      child: Container(
        color: AppColors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video or thumbnail
            if (_isInitialized && !_hasError)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            else if (_hasError)
              _buildErrorState()
            else
              _buildLoadingState(),

            // Paused indicator
            if (_isInitialized && !_isPlaying)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: AppColors.white,
                    size: 48,
                  ),
                ),
              ),

            // Overlay info
            ReelOverlay(
              reel: widget.reel,
              onSellerTap: widget.onSellerTap,
            ),

            // Action buttons (right side)
            ReelActions(
              reel: widget.reel,
              onLike: widget.onLike,
              onComment: widget.onComment,
              onSave: widget.onSave,
              onShare: widget.onShare,
            ),

            // Progress indicator
            if (_isInitialized)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: AppColors.white,
                    bufferedColor: Colors.white30,
                    backgroundColor: Colors.white10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Thumbnail as placeholder
        if (widget.reel.videoThumbnailUrl != null)
          AppCachedImage(
            imageUrl: widget.reel.videoThumbnailUrl,
            fit: BoxFit.cover,
          ),
        // Loading indicator
        const Center(
          child: LoadingIndicator(color: AppColors.white),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Thumbnail as fallback
        if (widget.reel.videoThumbnailUrl != null)
          AppCachedImage(
            imageUrl: widget.reel.videoThumbnailUrl,
            fit: BoxFit.cover,
          ),
        // Error message
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.white,
                  size: 32,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Video yuklanmadi',
                  style: TextStyle(color: AppColors.white),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _isInitialized = false;
                    });
                    _initializeVideo();
                  },
                  child: const Text('Qaytadan'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
