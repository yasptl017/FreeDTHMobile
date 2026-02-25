import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FreeDTHMobileApp());
}

class FreeDTHMobileApp extends StatelessWidget {
  const FreeDTHMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreeDTH Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E7AEE)),
        useMaterial3: true,
      ),
      home: const PlayerScreen(),
    );
  }
}

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  static const List<double> _speeds = <double>[0.5, 1.0, 1.25, 1.5, 2.0];
  final TextEditingController _urlController = TextEditingController(
    text: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
  );

  VideoPlayerController? _controller;
  bool _isLoading = false;
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _openStream(autoPlay: false);
  }

  @override
  void dispose() {
    _controller?.removeListener(_onPlayerTick);
    _controller?.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _onPlayerTick() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openStream({bool autoPlay = true}) async {
    final String url = _urlController.text.trim();
    if (url.isEmpty) {
      _show('Please enter a stream URL.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final VideoPlayerController next = VideoPlayerController.networkUrl(
        Uri.parse(url),
      );
      await next.initialize();
      await next.setPlaybackSpeed(_speed);
      if (autoPlay) {
        await next.play();
      }

      final VideoPlayerController? old = _controller;
      if (old != null) {
        old.removeListener(_onPlayerTick);
        await old.dispose();
      }

      next.addListener(_onPlayerTick);
      setState(() {
        _controller = next;
      });
    } catch (e) {
      _show('Failed to open stream: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _togglePlayPause() async {
    final VideoPlayerController? c = _controller;
    if (c == null || !c.value.isInitialized) {
      return;
    }
    if (c.value.isPlaying) {
      await c.pause();
    } else {
      await c.play();
    }
  }

  Future<void> _stop() async {
    final VideoPlayerController? c = _controller;
    if (c == null || !c.value.isInitialized) {
      return;
    }
    await c.pause();
    await c.seekTo(Duration.zero);
  }

  Future<void> _seekRelative(int seconds) async {
    final VideoPlayerController? c = _controller;
    if (c == null || !c.value.isInitialized) {
      return;
    }
    final Duration duration = c.value.duration;
    if (duration.inMilliseconds <= 0) {
      _show('Seek is not available for this stream.');
      return;
    }
    final Duration current = c.value.position;
    Duration next = current + Duration(seconds: seconds);
    if (next < Duration.zero) {
      next = Duration.zero;
    }
    if (next > duration) {
      next = duration;
    }
    await c.seekTo(next);
  }

  Future<void> _setSpeed(double speed) async {
    final VideoPlayerController? c = _controller;
    if (c == null || !c.value.isInitialized) {
      return;
    }
    await c.setPlaybackSpeed(speed);
    setState(() {
      _speed = speed;
    });
  }

  void _show(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _fmt(Duration value) {
    String two(int n) => n.toString().padLeft(2, '0');
    final int h = value.inHours;
    final int m = value.inMinutes.remainder(60);
    final int s = value.inSeconds.remainder(60);
    if (h > 0) {
      return '${two(h)}:${two(m)}:${two(s)}';
    }
    return '${two(m)}:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? c = _controller;
    final bool ready = c != null && c.value.isInitialized;
    final Duration duration = ready ? c.value.duration : Duration.zero;
    final Duration position = ready ? c.value.position : Duration.zero;
    final bool canSeek = duration.inMilliseconds > 0;
    final double sliderMax = canSeek ? duration.inMilliseconds.toDouble() : 1;
    final double sliderValue = canSeek
        ? position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble()
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FreeDTH Mobile Player'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: 'Stream URL',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _isLoading ? null : () => _openStream(autoPlay: true),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Load'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width - 20,
                  constraints: const BoxConstraints(maxWidth: 900, maxHeight: 500),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ready
                          ? AspectRatio(
                              aspectRatio: c.value.aspectRatio > 0 ? c.value.aspectRatio : 16 / 9,
                              child: VideoPlayer(c),
                            )
                          : const Center(
                              child: Text(
                                'Load a stream to start playback',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
              child: Row(
                children: <Widget>[
                  Text(_fmt(position)),
                  Expanded(
                    child: Slider(
                      value: sliderValue,
                      min: 0,
                      max: sliderMax,
                      onChanged: canSeek && ready
                          ? (double value) => c.seekTo(Duration(milliseconds: value.round()))
                          : null,
                    ),
                  ),
                  Text(canSeek ? _fmt(duration) : 'LIVE'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  IconButton.filledTonal(
                    onPressed: ready ? () => _seekRelative(-10) : null,
                    icon: const Icon(Icons.replay_10),
                    tooltip: 'Back 10s',
                  ),
                  IconButton.filled(
                    onPressed: ready ? _togglePlayPause : null,
                    icon: Icon(
                      ready && c.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    tooltip: 'Play / Pause',
                  ),
                  IconButton.filledTonal(
                    onPressed: ready ? _stop : null,
                    icon: const Icon(Icons.stop),
                    tooltip: 'Stop',
                  ),
                  IconButton.filledTonal(
                    onPressed: ready ? () => _seekRelative(10) : null,
                    icon: const Icon(Icons.forward_10),
                    tooltip: 'Forward 10s',
                  ),
                  PopupMenuButton<double>(
                    enabled: ready,
                    tooltip: 'Playback speed',
                    initialValue: _speed,
                    onSelected: _setSpeed,
                    itemBuilder: (BuildContext context) {
                      return _speeds
                          .map(
                            (double s) => PopupMenuItem<double>(
                              value: s,
                              child: Text('${s.toStringAsFixed(s == 1 ? 0 : 2)}x'),
                            ),
                          )
                          .toList();
                    },
                    child: Chip(
                      avatar: const Icon(Icons.speed, size: 18),
                      label: Text('${_speed.toStringAsFixed(_speed == 1 ? 0 : 2)}x'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
