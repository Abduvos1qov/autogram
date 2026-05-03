import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/feedback/loading_indicator.dart';
import '../../../../core/widgets/media/cached_image.dart';

/// Listing gallery widget with video and images

class ListingGallery extends StatefulWidget {
  final String? videoUrl;
  final String? videoThumbnailUrl;
  final List<String> images;

  const ListingGallery({
    super.key,
    this.videoUrl,
    this.videoThumbnailUrl,
    required this.images,
  });

  @override
  State<ListingGallery> createState() => _ListingGalleryState();
}

class _ListingGalleryState extends State<ListingGallery> {
  late PageController _pageController;
  int _currentPage = 0;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  List<String> get _allMedia {
    final media = <String>[];
    if (widget.videoThumbnailUrl != null) {
      media.add(widget.videoThumbnailUrl!);
    }
    media.addAll(widget.images);
    return media;
  }

  bool get _hasVideo => widget.videoUrl != null;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (_hasVideo) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl!),
    );

    try {
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      // Video failed to load
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_allMedia.isEmpty) {
      return Container(
        color: AppColors.surface,
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 48,
            color: AppColors.textSecondaryOf(context),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Gallery
        PageView.builder(
          controller: _pageController,
          onPageChanged: (page) {
            setState(() {
              _currentPage = page;
            });

            // Play/pause video based on page
            if (_hasVideo && _isVideoInitialized) {
              if (page == 0) {
                _videoController?.play();
              } else {
                _videoController?.pause();
              }
            }
          },
          itemCount: _allMedia.length,
          itemBuilder: (context, index) {
            // First item is video if available
            if (index == 0 && _hasVideo) {
              return _buildVideoPlayer();
            }

            return AppCachedImage(
              imageUrl: _allMedia[index],
              fit: BoxFit.cover,
            );
          },
        ),

        // Page indicator
        if (_allMedia.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _allMedia.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? AppColors.white
                        : AppColors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    if (!_isVideoInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (widget.videoThumbnailUrl != null)
            AppCachedImage(
              imageUrl: widget.videoThumbnailUrl,
              fit: BoxFit.cover,
            ),
          const Center(child: LoadingIndicator(color: AppColors.white)),
        ],
      );
    }

    return GestureDetector(
      onTap: () {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
        } else {
          _videoController!.play();
        }
        setState(() {});
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          ),
          // Play/pause overlay
          if (!_videoController!.value.isPlaying)
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
        ],
      ),
    );
  }
}
