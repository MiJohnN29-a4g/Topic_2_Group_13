class Episode {
  final int number;
  final String title;
  final String? description; // Mô tả tập
  final String? duration;    // Thời lượng tập (phút)

  Episode({
    required this.number,
    required this.title,
    this.description,
    this.duration,
  });
}

class Movie {
  final int id;
  final String title;
  final String poster;
  final String backdrop;
  final String description;
  final String year;
  final String genre;
  final String rating;
  final String trailerKey; // YouTube video key
  final List<Episode> episodes; // empty = movie, filled = series

  // Thông tin mở rộng (optional - có giá trị default)
  final String? director;      // Đạo diễn
  final List<String>? cast;    // Diễn viên chính
  final String? country;       // Quốc gia sản xuất
  final String? duration;      // Thời lượng (phút) - cho movie
  final String? studio;        // Hãng sản xuất
  final int? views;            // Lượt xem
  final String? contentRating; // Phân loại độ tuổi (P, C13, C18)

  Movie({
    required this.id,
    required this.title,
    required this.poster,
    required this.backdrop,
    required this.description,
    required this.year,
    required this.genre,
    required this.rating,
    required this.trailerKey,
    required this.episodes,
    this.director,
    this.cast,
    this.country,
    this.duration,
    this.studio,
    this.views,
    this.contentRating,
  });

  bool get isSeries => episodes.isNotEmpty;

  // Helper để kiểm tra có thông tin mở rộng không
  bool get hasExtendedInfo => director != null || cast != null || country != null;
}
