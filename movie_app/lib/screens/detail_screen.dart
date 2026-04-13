detail_scree.dart
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/movie.dart';
import 'watch_screen.dart';

class DetailScreen extends StatelessWidget {
  final Movie movie;

  const DetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _DetailContent(movie: movie),
      ),
    );
  }
}

class _DetailContent extends StatefulWidget {
  final Movie movie;
  const _DetailContent({required this.movie});

  @override
  State<_DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends State<_DetailContent> {
  bool _trailerPlaying = false;

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return Container(
      color: const Color(0xFF181818),
      constraints: const BoxConstraints(maxWidth: 850),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top: Backdrop + play overlay ────────────────────────────
            Stack(
              children: [
                // Backdrop thumbnail (khi chưa play)
                if (!_trailerPlaying)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      movie.backdrop,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: const Color(0xFF333333)),
                    ),
                  ),

                // YouTube iframe embed (khi đã nhấn play trailer)
                if (_trailerPlaying)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _YoutubeEmbed(videoKey: movie.trailerKey),
                  ),

                // Gradient bottom fade
                if (!_trailerPlaying)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xFF181818)],
                          stops: [0.6, 1.0],
                        ),
                      ),
                    ),
                  ),

                // Close button
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFF181818),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ),

                // Bottom-left: title + buttons
                if (!_trailerPlaying)
                  Positioned(
                    left: 24,
                    bottom: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            // Phát — mở WatchScreen
                            _ActionButton(
                              icon: Icons.play_arrow_rounded,
                              label: 'Phát',
                              primary: true,
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => WatchScreen(movie: movie),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 10),
                            // Xem trailer
                            _ActionButton(
                              icon: Icons.play_circle_outline_rounded,
                              label: 'Xem Trailer',
                              primary: false,
                              onPressed: () =>
                                  setState(() => _trailerPlaying = true),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // ── Body: Info + description ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta row
                  Row(
                    children: [
                      _MetaChip(text: movie.year),
                      const SizedBox(width: 8),
                      _MetaChip(
                        text: '⭐ ${movie.rating}',
                        color: const Color(0xFFE5B30F),
                      ),
                      if (movie.isSeries) ...[
                        const SizedBox(width: 8),
                        _MetaChip(
                          text: '${movie.episodes.length} tập',
                          color: const Color(0xFF46D369),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Genre
                  Text(
                    movie.genre,
                    style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Description
                  Text(
                    movie.description,
                    style: const TextStyle(
                      color: Color(0xDDFFFFFF),
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),

                  // Episode list (nếu là series)
                  if (movie.isSeries) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Các tập',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...movie.episodes.map((ep) => _EpisodeTile(
                          episode: ep,
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WatchScreen(
                                  movie: movie,
                                  startEpisode: ep.number,
                                ),
                              ),
                            );
                          },
                        )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── YouTube player embed trực tiếp ────────────────────────────────────────
class _YoutubeEmbed extends StatefulWidget {
  final String videoKey;
  const _YoutubeEmbed({required this.videoKey});

  @override
  State<_YoutubeEmbed> createState() => _YoutubeEmbedState();
}

class _YoutubeEmbedState extends State<_YoutubeEmbed> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoKey,
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        onReady: () {
          _controller.addListener(() {});
        },
      ),
      builder: (context, player) {
        return player;
      },
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.primary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 22, color: primary ? Colors.black : Colors.white),
      label: Text(
        label,
        style: TextStyle(
          color: primary ? Colors.black : Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: primary ? Colors.white : const Color(0x88808080),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 0,
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String text;
  final Color color;

  const _MetaChip({required this.text, this.color = const Color(0xFF777777)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  final Episode episode;
  final VoidCallback onTap;

  const _EpisodeTile({required this.episode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF404040),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${episode.number}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                episode.title,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const Icon(Icons.play_arrow_rounded, color: Colors.white54, size: 22),
          ],
        ),
      ),
    );
  }
}
Bảo
watching screen.dart
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
member_ship.dart
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/user.dart';

class MembershipScreen extends StatefulWidget {
  final User user;

  const MembershipScreen({super.key, required this.user});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  final dbHelper = DatabaseHelper.instance;
  bool _isLoading = false;

  void _buyPackage(String packageType) async {
    setState(() => _isLoading = true);

    // Tính ngày hết hạn
    final now = DateTime.now();
    final expiryDate = packageType == 'monthly'
        ? now.add(const Duration(days: 30))
        : now.add(const Duration(days: 365));

    // Kích hoạt membership
    await dbHelper.activateMembership(
      userId: widget.user.id!,
      packageType: packageType,
      expiryDate: expiryDate,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF181818),
          title: const Text('Thành công!', style: TextStyle(color: Colors.white)),
          content: Text(
            'Bạn đã mua gói ${packageType == 'monthly' ? 'Tháng' : 'Năm'} thành công.\n'
            'Hạn sử dụng: ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Return to previous screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final hasMembership = user.hasActiveMembership;
    final remainingDays = user.remainingDays;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        title: const Text(
          'Gói Membership',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current membership status
              _buildStatusCard(user, hasMembership, remainingDays),

              const SizedBox(height: 32),

              // Package options
              const Text(
                'Chọn gói của bạn',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              if (!hasMembership) ...[
                _buildPackageCard(
                  title: 'Gói Tháng',
                  price: '74.000 đ',
                  period: '/tháng',
                  features: [
                    'Truy cập không giới hạn',
                    'Chất lượng HD',
                    'Xem trên 1 thiết bị',
                    'Hủy bất cứ lúc nào',
                  ],
                  onTap: () => _buyPackage('monthly'),
                  accentColor: Colors.red,
                ),
                const SizedBox(height: 16),
                _buildPackageCard(
                  title: 'Gói Năm',
                  price: '740.000 đ',
                  period: '/năm',
                  features: [
                    'Truy cập không giới hạn',
                    'Chất lượng 4K HDR',
                    'Xem trên 4 thiết bị',
                    'Tải về xem offline',
                    'Hủy bất cứ lúc nào',
                  ],
                  onTap: () => _buyPackage('yearly'),
                  accentColor: Colors.amber,
                  isPopular: true,
                ),
              ] else ...[
                _buildCurrentPackageInfo(user),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(User user, bool hasMembership, int? remainingDays) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasMembership
              ? [const Color(0xFF1DB954), const Color(0xFF1ED760)]
              : [const Color(0xFF333333), const Color(0xFF444444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasMembership ? Icons.check_circle : Icons.info_outline,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                hasMembership ? 'Thành viên Premium' : 'Chưa có gói Premium',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hasMembership
                ? 'Thời gian còn lại: $remainingDays ngày'
                : 'Nâng cấp để xem phim không giới hạn',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
            ),
          ),
          if (hasMembership && user.membershipType != null) ...[
            const SizedBox(height: 4),
            Text(
              'Gói: ${user.membershipType == 'yearly' ? 'Năm' : 'Tháng'}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPackageCard({
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required VoidCallback onTap,
    required Color accentColor,
    bool isPopular = false,
  }) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPopular ? accentColor : const Color(0xFF333333),
            width: isPopular ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isPopular) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Phổ biến',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$price$period',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: accentColor,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.check, color: accentColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    feature,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPackageInfo(User user) {
    final expiryDate = user.membershipExpiry != null
        ? DateTime.parse(user.membershipExpiry!)
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.star,
            color: user.membershipType == 'yearly' ? Colors.amber : Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            user.membershipType == 'yearly' ? 'Gói Năm' : 'Gói Tháng',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hết hạn: ${expiryDate?.day}/${expiryDate?.month}/${expiryDate?.year}',
            style: const TextStyle(color: Colors.white60, fontSize: 15),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.hourglass_empty, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Còn lại: ${user.remainingDays ?? 0} ngày',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
