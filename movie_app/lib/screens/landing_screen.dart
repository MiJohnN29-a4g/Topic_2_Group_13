import 'package:flutter/material.dart';
import '../data/movie_data.dart';
import '../models/movie.dart';
import 'detail_screen.dart';
import 'watch_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int _featuredIndex = 0;

  void _openDetail(Movie movie) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (_) => DetailScreen(movie: movie),
    );
  }

  @override
  Widget build(BuildContext context) {
    final featured = movies[_featuredIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroBanner(
              movie: featured,
              onPlay: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WatchScreen(movie: featured),
                ),
              ),
              onInfo: () => _openDetail(featured),
            ),
            const SizedBox(height: 24),
            _MovieRow(
              title: 'Trending',
              movies: movies,
              onTap: (index) => setState(() => _featuredIndex = index),
              onInfoTap: (movie) => _openDetail(movie),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Banner
// ─────────────────────────────────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  final Movie movie;
  final VoidCallback onPlay;
  final VoidCallback onInfo;

  const _HeroBanner({
    required this.movie,
    required this.onPlay,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final bannerH = screenH * 0.65;

    return SizedBox(
      height: bannerH,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with slight brightness
          Image.network(
            movie.backdrop,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(color: const Color(0xFF141414));
            },
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xFF141414)),
          ),
          // Dark overlay to make text readable
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          // Gradient from left (transparent to dark)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                  stops: const [0.0, 0.15, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Gradient from bottom
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black,
                  ],
                  stops: const [0.4, 0.6, 0.85, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            left: 40,
            bottom: 48,
            right: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    letterSpacing: -1,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  movie.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xDDFFFFFF),
                    fontSize: 15,
                    height: 1.5,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _BannerButton(
                      icon: Icons.play_arrow_rounded,
                      label: 'Phát',
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      onPressed: onPlay,
                    ),
                    const SizedBox(width: 12),
                    _BannerButton(
                      icon: Icons.info_outline_rounded,
                      label: 'Thông tin',
                      backgroundColor: const Color(0x88808080),
                      foregroundColor: Colors.white,
                      onPressed: onInfo,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  const _BannerButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 22, color: foregroundColor),
      label: Text(
        label,
        style: TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        elevation: 0,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Movie Row
// ─────────────────────────────────────────────────────────────────────────────
class _MovieRow extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final ValueChanged<int> onTap;
  final ValueChanged<Movie> onInfoTap;

  const _MovieRow({
    required this.title,
    required this.movies,
    required this.onTap,
    required this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            itemCount: movies.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              return _PosterCard(
                movie: movies[i],
                onTap: () => onTap(i),
                onInfoTap: () => onInfoTap(movies[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PosterCard extends StatefulWidget {
  final Movie movie;
  final VoidCallback onTap;
  final VoidCallback onInfoTap;

  const _PosterCard({
    required this.movie,
    required this.onTap,
    required this.onInfoTap,
  });

  @override
  State<_PosterCard> createState() => _PosterCardState();
}

class _PosterCardState extends State<_PosterCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onInfoTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: _hovered ? 145 : 133,
          height: _hovered ? 215 : 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            boxShadow: _hovered
                ? [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 16, offset: const Offset(0, 8))]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  widget.movie.poster,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF333333),
                    child: const Icon(Icons.movie, color: Colors.white38),
                  ),
                ),
                if (_hovered)
                  Container(
                    alignment: Alignment.bottomLeft,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xEE000000)],
                        stops: [0.4, 1.0],
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.movie.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFE5B30F), size: 10),
                            const SizedBox(width: 3),
                            Text(
                              widget.movie.rating,
                              style: const TextStyle(
                                color: Color(0xFFE5B30F),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.movie.year,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}