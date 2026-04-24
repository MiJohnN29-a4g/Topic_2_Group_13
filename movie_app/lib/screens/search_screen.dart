import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../models/user.dart';
import '../repositories/movie_repository.dart';
import '../repositories/user_repository.dart';
import 'detail_screen.dart';
import 'watch_screen.dart';
import 'membership_screen.dart';

class SearchScreen extends StatefulWidget {
  final User? user;

  const SearchScreen({super.key, this.user});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final _movieRepository = MovieRepository();
  final _userRepository = UserRepository();
  List<Movie> _searchResults = [];
  bool _isSearching = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadUser() async {
    if (widget.user != null) {
      final user = await _userRepository.getUserById(widget.user!.id!);
      setState(() => _currentUser = user);
    }
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await _movieRepository.searchMovies(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      debugPrint('Lỗi khi tìm kiếm: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _openDetail(Movie movie) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (_) => DetailScreen(movie: movie),
    );
  }

  void _openMembership() {
    if (_currentUser == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MembershipScreen(user: _currentUser!)),
    ).then((_) => _loadUser());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          _SearchBar(
            user: _currentUser,
            searchController: _searchController,
            focusNode: _focusNode,
            onSearch: _performSearch,
            onBack: () => Navigator.pop(context),
            onMembership: _openMembership,
            onLogout: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? _EmptyState(query: _searchController.text)
                    : _SearchResults(
                        results: _searchResults,
                        onInfoTap: _openDetail,
                        onPlayTap: (movie) => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WatchScreen(movie: movie),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Bar
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final User? user;
  final TextEditingController searchController;
  final FocusNode focusNode;
  final ValueChanged<String> onSearch;
  final VoidCallback onBack;
  final VoidCallback onMembership;
  final VoidCallback onLogout;

  const _SearchBar({
    required this.user,
    required this.searchController,
    required this.focusNode,
    required this.onSearch,
    required this.onBack,
    required this.onMembership,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: const Color(0xFF141414),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          // Back button
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
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 24),
          // Search field
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextField(
                controller: searchController,
                focusNode: focusNode,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm phim, diễn viên, thể loại...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            searchController.clear();
                            onSearch('');
                          },
                          icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.5)),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: onSearch,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // User actions
          if (user != null) ...[
            if (user!.hasActiveMembership)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.green, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${user!.remainingDays} ngày',
                      style: const TextStyle(color: Colors.green, fontSize: 11),
                    ),
                  ],
                ),
              ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: onMembership,
              style: ElevatedButton.styleFrom(
                backgroundColor: user!.hasActiveMembership ? Colors.green : Colors.amber,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: Text(
                user!.hasActiveMembership ? 'Gia hạn' : 'Nâng cấp',
                style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onLogout,
              icon: const Icon(Icons.logout, color: Colors.white60, size: 20),
              tooltip: 'Đăng xuất',
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Results Grid
// ─────────────────────────────────────────────────────────────────────────────
class _SearchResults extends StatelessWidget {
  final List<Movie> results;
  final ValueChanged<Movie> onInfoTap;
  final ValueChanged<Movie> onPlayTap;

  const _SearchResults({
    required this.results,
    required this.onInfoTap,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tìm thấy ${results.length} kết quả',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.68,
              ),
              itemCount: results.length,
              itemBuilder: (context, index) {
                return _ResultCard(
                  movie: results[index],
                  onInfoTap: () => onInfoTap(results[index]),
                  onPlayTap: () => onPlayTap(results[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatefulWidget {
  final Movie movie;
  final VoidCallback onInfoTap;
  final VoidCallback onPlayTap;

  const _ResultCard({
    required this.movie,
    required this.onInfoTap,
    required this.onPlayTap,
  });

  @override
  State<_ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<_ResultCard> {
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
                // Hover overlay
                if (_hovered)
                  Container(
                    color: Colors.black.withOpacity(0.8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Title
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            widget.movie.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // Rating & Year
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, color: Color(0xFFE5B30F), size: 10),
                            const SizedBox(width: 2),
                            Text(
                              widget.movie.rating,
                              style: const TextStyle(color: Color(0xFFE5B30F), fontSize: 10),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.movie.year,
                              style: const TextStyle(color: Colors.white54, fontSize: 10),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: widget.onPlayTap,
                              icon: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            IconButton(
                              onPressed: widget.onInfoTap,
                              icon: const Icon(Icons.info_outline, color: Colors.white, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
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

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String query;

  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            query.isEmpty ? Icons.search : Icons.search_off,
            size: 80,
            color: Colors.white24,
          ),
          const SizedBox(height: 24),
          Text(
            query.isEmpty
                ? 'Nhập tên phim để tìm kiếm'
                : 'Không tìm thấy kết quả nào cho "$query"',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (query.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Thử lại với từ khóa khác',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}
