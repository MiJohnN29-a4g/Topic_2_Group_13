import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/movie.dart';

class WatchScreen extends StatefulWidget {
  final Movie movie;
  final int startEpisode;

  const WatchScreen({
    super.key,
    required this.movie,
    this.startEpisode = 1,
  });

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  late int _currentEp;
  bool _isPlaying = false;
  YoutubePlayerController? _controller;
  String? _currentVideoId;

  @override
  void initState() {
    super.initState();
    _currentEp = widget.startEpisode;
    _initController();
  }

  void _initController() {
    _controller?.dispose();
    _currentVideoId = widget.movie.trailerKey;
    _controller = YoutubePlayerController(
      initialVideoId: _currentVideoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        showLiveFullscreenButton: false,
        forceHD: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _changeEpisode(int episodeNumber) {
    setState(() {
      _currentEp = episodeNumber;
      _isPlaying = false;
      _initController();
    });
  }

  Episode? get _episode {
    if (!widget.movie.isSeries) return null;
    return widget.movie.episodes.firstWhere(
      (e) => e.number == _currentEp,
      orElse: () => widget.movie.episodes.first,
    );
  }

  String get _currentTitle {
    if (_episode != null) return 'Tập ${_episode!.number}: ${_episode!.title}';
    return widget.movie.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Column(
        children: [
          // ── Top bar ────────────────────────────────────────────────
          _TopBar(
            title: widget.movie.title,
            onBack: () => Navigator.pop(context),
          ),

          // ── Main content ────────────────────────────────────────────
          Expanded(
            child: widget.movie.isSeries
                ? _SeriesLayout(
                    controller: _controller,
                    movie: widget.movie,
                    currentEp: _currentEp,
                    currentTitle: _currentTitle,
                    isPlaying: _isPlaying,
                    onPlay: () => setState(() => _isPlaying = true),
                    onEpisodeTap: _changeEpisode,
                  )
                : _MovieLayout(
                    controller: _controller,
                    movie: widget.movie,
                    isPlaying: _isPlaying,
                    onPlay: () => setState(() => _isPlaying = true),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Series layout: player (left wide) + episode list (right sidebar)
// ─────────────────────────────────────────────────────────────────────────────
class _SeriesLayout extends StatelessWidget {
  final YoutubePlayerController? controller;
  final Movie movie;
  final int currentEp;
  final String currentTitle;
  final bool isPlaying;
  final VoidCallback onPlay;
  final ValueChanged<int> onEpisodeTap;

  const _SeriesLayout({
    required this.controller,
    required this.movie,
    required this.currentEp,
    required this.currentTitle,
    required this.isPlaying,
    required this.onPlay,
    required this.onEpisodeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Left: video + info ───────────────────────────────────────
        Expanded(
          flex: 7,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Player
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _VideoPlayer(
                    controller: controller,
                    backdrop: movie.backdrop,
                    isPlaying: isPlaying,
                    onPlay: onPlay,
                  ),
                ),

                // Video title
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Text(
                    currentTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                // Meta
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    children: [
                      Text(
                        movie.year,
                        style: const TextStyle(color: Color(0xFF999999), fontSize: 13),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        movie.genre,
                        style: const TextStyle(color: Color(0xFF999999), fontSize: 13),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '⭐ ${movie.rating}',
                        style: const TextStyle(color: Color(0xFFE5B30F), fontSize: 13),
                      ),
                    ],
                  ),
                ),

                // Divider
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Divider(color: Color(0xFF333333)),
                ),

                // Description
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Text(
                    movie.description,
                    style: const TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Right: episode sidebar ───────────────────────────────────
        Container(
          width: 340,
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: Color(0xFF222222))),
          ),
          child: Column(
            children: [
              // Sidebar header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: const Color(0xFF161616),
                child: Row(
                  children: [
                    const Text(
                      'Danh sách tập',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${movie.episodes.length} tập',
                      style: const TextStyle(color: Color(0xFF999999), fontSize: 13),
                    ),
                  ],
                ),
              ),

              // Episode list
              Expanded(
                child: ListView.builder(
                  itemCount: movie.episodes.length,
                  itemBuilder: (context, i) {
                    final ep = movie.episodes[i];
                    final isActive = ep.number == currentEp;

                    return _SidebarEpisodeTile(
                      episode: ep,
                      movie: movie,
                      isActive: isActive,
                      onTap: () => onEpisodeTap(ep.number),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Movie layout: centered player + description below
// ─────────────────────────────────────────────────────────────────────────────
class _MovieLayout extends StatelessWidget {
  final YoutubePlayerController? controller;
  final Movie movie;
  final bool isPlaying;
  final VoidCallback onPlay;

  const _MovieLayout({
    required this.controller,
    required this.movie,
    required this.isPlaying,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _VideoPlayer(
              controller: controller,
              backdrop: movie.backdrop,
              isPlaying: isPlaying,
              onPlay: onPlay,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Text(
              movie.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
            child: Row(children: [
              Text(movie.year,
                  style: const TextStyle(color: Color(0xFF999999), fontSize: 13)),
              const SizedBox(width: 12),
              Text(movie.genre,
                  style: const TextStyle(color: Color(0xFF999999), fontSize: 13)),
              const SizedBox(width: 12),
              Text('⭐ ${movie.rating}',
                  style: const TextStyle(color: Color(0xFFE5B30F), fontSize: 13)),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Divider(color: Color(0xFF333333)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: Text(
              movie.description,
              style: const TextStyle(
                color: Color(0xCCFFFFFF),
                fontSize: 15,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Video Player widget (thumbnail + play button → YouTube embed)
// ─────────────────────────────────────────────────────────────────────────────
class _VideoPlayer extends StatelessWidget {
  final YoutubePlayerController? controller;
  final String backdrop;
  final bool isPlaying;
  final VoidCallback onPlay;

  const _VideoPlayer({
    required this.controller,
    required this.backdrop,
    required this.isPlaying,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    if (isPlaying && controller != null) {
      // ── Khi đã nhấn play: hiển thị YouTube player ──────────────────
      return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: controller!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,
        ),
        builder: (context, player) {
          return player;
        },
      );
    }

    // ── Chưa play: backdrop + nút play lớn ────────────────────────
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          backdrop,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Container(color: const Color(0xFF1A1A1A)),
        ),
        Container(color: Colors.black.withOpacity(0.4)),
        Center(
          child: GestureDetector(
            onTap: onPlay,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sidebar episode tile
// ─────────────────────────────────────────────────────────────────────────────
class _SidebarEpisodeTile extends StatefulWidget {
  final Episode episode;
  final Movie movie;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarEpisodeTile({
    required this.episode,
    required this.movie,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_SidebarEpisodeTile> createState() => _SidebarEpisodeTileState();
}

class _SidebarEpisodeTileState extends State<_SidebarEpisodeTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final ep = widget.episode;
    final active = widget.isActive;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: active
              ? const Color(0xFF272727)
              : _hovered
                  ? const Color(0xFF1F1F1F)
                  : Colors.transparent,
          child: Row(
            children: [
              // Active indicator bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 3,
                height: 80,
                color: active ? Colors.red : Colors.transparent,
              ),

              const SizedBox(width: 10),

              // Thumbnail placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: [
                    Image.network(
                      widget.movie.poster,
                      width: 120,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 120,
                        height: 70,
                        color: const Color(0xFF333333),
                        child: const Icon(Icons.movie, color: Colors.white38),
                      ),
                    ),
                    if (active)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                          child: const Icon(
                            Icons.pause_circle_outline,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Episode info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tập ${ep.number}',
                        style: TextStyle(
                          color: active ? Colors.white : const Color(0xFF999999),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        ep.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: active ? Colors.white : const Color(0xCCFFFFFF),
                          fontSize: 13,
                          fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top navigation bar
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _TopBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: const Color(0xFF141414),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          // Logo
          const Text(
            'FLIXFILM',
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}