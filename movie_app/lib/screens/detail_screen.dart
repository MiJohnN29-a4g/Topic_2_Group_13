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
                      if (movie.contentRating != null) ...[
                        const SizedBox(width: 8),
                        _MetaChip(
                          text: movie.contentRating!,
                          color: const Color(0xFF46D369),
                        ),
                      ],
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
                  const SizedBox(height: 16),

                  // ── Thông tin mở rộng (Director, Cast, Country...) ──────
                  if (movie.hasExtendedInfo || movie.duration != null || movie.studio != null || movie.views != null) ...[
                    _InfoRow(
                      icon: Icons.person_outline,
                      label: 'Đạo diễn',
                      value: movie.director,
                    ),
                    if (movie.cast != null && movie.cast!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.groups_outlined,
                        label: 'Diễn viên',
                        value: movie.cast!.take(4).join(', '),
                      ),
                    ],
                    if (movie.country != null) ...[
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.flag_outlined,
                        label: 'Quốc gia',
                        value: movie.country,
                      ),
                    ],
                    if (movie.duration != null) ...[
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.schedule_outlined,
                        label: 'Thời lượng',
                        value: movie.duration,
                      ),
                    ],
                    if (movie.studio != null) ...[
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.business_outlined,
                        label: 'Hãng sản xuất',
                        value: movie.studio,
                      ),
                    ],
                    if (movie.views != null) ...[
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.visibility_outlined,
                        label: 'Lượt xem',
                        value: _formatViews(movie.views!),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFF333333), thickness: 1),
                    const SizedBox(height: 16),
                  ],

                  // Description
                  const Text(
                    'Nội dung',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.description,
                    style: const TextStyle(
                      color: Color(0xDDFFFFFF),
                      fontSize: 14,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    episode.title,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (episode.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      episode.description!,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (episode.duration != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      episode.duration!,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.play_arrow_rounded, color: Colors.white54, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Widget hiển thị thông tin dạng row ───────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF999999), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white, fontSize: 14),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: Color(0xDDFFFFFF),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Helper format lượt xem ───────────────────────────────────────────────────
String _formatViews(int views) {
  if (views >= 1000000) {
    return '${(views / 1000000).toStringAsFixed(1)}M';
  } else if (views >= 1000) {
    return '${(views / 1000).toStringAsFixed(0)}K';
  }
  return views.toString();
}
