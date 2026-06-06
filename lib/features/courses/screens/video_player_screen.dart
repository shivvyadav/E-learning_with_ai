import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../../../state/progress_provider.dart';
import '../providers/lesson_provider.dart';
import '../../../core/config/network_config.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String courseId;
  final String lessonId;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.courseId,
    required this.lessonId,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _error;

  int _lastSavedSeconds = 0;
  bool _completedRecorded = false;
  bool _showResumeButton = false;
  int _resumePosition = 0;
  bool _isCached = false;
  String? _correctedVideoUrl;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }


  // Clean filename to avoid special characters issues

  String _cleanFileName(String fileName) {
    // Remove special characters that might cause issues
    String cleaned = fileName
        .replaceAll('ï', '')
        .replaceAll('¼', '')
        .replaceAll('½', '')
        .replaceAll('?', '')
        .replaceAll(':', '')
        .replaceAll('*', '')
        .replaceAll('"', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('|', '')
        .replaceAll(' ', '_')
        .replaceAll('\\', '_')
        .replaceAll('/', '_');
    
    // Limit filename length
    if (cleaned.length > 100) {
      cleaned = cleaned.substring(0, 100);
    }
    
    return cleaned;
  }

  Future<void> _initializeVideo() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // First, correct the video URL using NetworkConfig
      _correctedVideoUrl = NetworkConfig.getVideoUrl(widget.videoUrl);
      print("Original URL: ${widget.videoUrl}");
      print("Corrected URL: $_correctedVideoUrl");
      print("Device: ${NetworkConfig.deviceInfo}");

      final progressProvider =
          Provider.of<ProgressProvider>(context, listen: false);

      _resumePosition = progressProvider.getSavedPosition(
        widget.courseId,
        widget.lessonId,
      );

      if (_resumePosition > 0) {
        _showResumeButton = true;
      }

      // Check if video is already cached with cleaned filename
      final cleanedFileName = _cleanFileName(_getFileNameFromUrl(_correctedVideoUrl!));
      final directory = await getTemporaryDirectory();
      final cachedFile = File('${directory.path}/$cleanedFileName');
      
      if (await cachedFile.exists()) {
        final fileSize = await cachedFile.length();
        if (fileSize > 0) {
          // Use cached file for smooth playback
          _videoController = VideoPlayerController.file(
            cachedFile,
            videoPlayerOptions: VideoPlayerOptions(
              allowBackgroundPlayback: false,
            ),
          );
          _isCached = true;
          print("Playing from cache: ${cachedFile.path}");
        } else {
          // File exists but is empty, delete it
          await cachedFile.delete();
          _videoController = VideoPlayerController.networkUrl(
            Uri.parse(_correctedVideoUrl!),
            videoPlayerOptions: VideoPlayerOptions(
              allowBackgroundPlayback: false,
            ),
          );
          print("Playing from network (cache was empty): $_correctedVideoUrl");
        }
      } else {
        // Start playing from network using corrected URL
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(_correctedVideoUrl!),
          videoPlayerOptions: VideoPlayerOptions(
            allowBackgroundPlayback: false,
          ),
        );
        print("Playing from network: $_correctedVideoUrl");
        
        // Start background download for future playback
        _downloadInBackground(_correctedVideoUrl!);
      }

      // Initialize the controller with timeout
      await _videoController!.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception("Video initialization timed out. Check your internet connection.");
        },
      );

      final lessonProvider =
          Provider.of<LessonProvider>(context, listen: false);

      await lessonProvider.setLessonDuration(
        widget.lessonId,
        _videoController!.value.duration,
      );

      // Setup Chewie with optimized settings
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: !_showResumeButton,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        showControls: true,
        showControlsOnInitialize: false,
        autoInitialize: true,
        
        // Custom progress colors
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blue,
          handleColor: Colors.blue,
          bufferedColor: Colors.grey.shade400,
          backgroundColor: Colors.black26,
        ),
        
        // Playback speed options
        playbackSpeeds: const [
          0.5,
          0.75,
          1.0,
          1.25,
          1.5,
          2.0,
        ],
        
        // Custom buffering indicator
        bufferingBuilder: (context) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text(
                  "Loading video... Please wait",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },
        
        // Custom placeholder while loading
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  "Preparing video...",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        
        // Error builder
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 12),
                Text(
                  "Error playing video",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      // Add position listener
      _videoController!.addListener(() {
        if (!_videoController!.value.isInitialized) return;

        final position = _videoController!.value.position;
        final seconds = position.inSeconds;

        // Save position every 5 seconds
        if ((seconds - _lastSavedSeconds).abs() >= 5) {
          _lastSavedSeconds = seconds;
          progressProvider.savePosition(
            widget.courseId,
            widget.lessonId,
            seconds,
          );
        }

        // Mark lesson complete
        if (!_completedRecorded &&
            _videoController!.value.duration.inSeconds > 0 &&
            seconds >= _videoController!.value.duration.inSeconds - 1) {
          _completedRecorded = true;
          progressProvider.completeLesson(
            widget.courseId,
            widget.lessonId,
          );
        }
      });

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Video initialization error: $e");
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }


  // Get cached video file

  Future<File?> _getCachedVideo(String url) async {
    try {
      final directory = await getTemporaryDirectory();
      final fileName = _getFileNameFromUrl(url);
      final cleanedFileName = _cleanFileName(fileName);
      final file = File('${directory.path}/$cleanedFileName');
      if (await file.exists()) {
        final fileSize = await file.length();
        if (fileSize > 0) {
          return file;
        }
      }
      return null;
    } catch (e) {
      print("Error checking cache: $e");
      return null;
    }
  }


  // Download video in background for caching

  Future<void> _downloadInBackground(String url) async {
    try {
      final directory = await getTemporaryDirectory();
      final fileName = _getFileNameFromUrl(url);
      final cleanedFileName = _cleanFileName(fileName);
      final file = File('${directory.path}/$cleanedFileName');
      
      // Check if already downloaded
      if (await file.exists()) {
        final fileSize = await file.length();
        if (fileSize > 0) return;
      }
      
      print("Downloading video for caching: $cleanedFileName");
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        print("Video cached successfully: ${file.path}");
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Video cached for smoother playback next time"),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print("Download failed: HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("Download failed: $e");
    }
  }


  // Extract filename from URL

  String _getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        String fileName = segments.last;
        if (!fileName.contains('.')) {
          fileName = '$fileName.mp4';
        }
        return fileName;
      }
      return 'video_${url.hashCode}.mp4';
    } catch (e) {
      return 'video_${url.hashCode}.mp4';
    }
  }

  // ============================================
  // Resume video from saved position
  // ============================================
  void _resumeVideo() {
    if (_videoController != null) {
      _videoController!.seekTo(Duration(seconds: _resumePosition));
      _videoController!.play();
      setState(() {
        _showResumeButton = false;
      });
    }
  }

  // ============================================
  // Start from beginning
  // ============================================
  void _startOver() {
    if (_videoController != null) {
      _videoController!.seekTo(Duration.zero);
      _videoController!.play();
      setState(() {
        _showResumeButton = false;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _videoController?.pause();
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Loading video..."),
                  SizedBox(height: 8),
                  Text(
                    "First time loading may take a moment",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          "Error playing video",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            _initializeVideo();
                          },
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Video Player
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: Chewie(
                            controller: _chewieController!,
                          ),
                        ),
                      ),
                    ),
                    
                    // Cache status indicator
                    if (_isCached)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, size: 16, color: Colors.green),
                            SizedBox(width: 4),
                            // Text(
                            //   "Cached - Smooth Playback",
                            //   style: TextStyle(fontSize: 12, color: Colors.green),
                            // ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 10),
                    
                    // Resume / Start Over buttons
                    if (_showResumeButton)
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.black87,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.play_arrow),
                              label: Text("Resume from ${_formatDuration(_resumePosition)}"),
                              onPressed: _resumeVideo,
                            ),
                            const SizedBox(width: 16),
                            TextButton(
                              onPressed: _startOver,
                              child: const Text("Start Over"),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final secs = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$secs";
  }
}