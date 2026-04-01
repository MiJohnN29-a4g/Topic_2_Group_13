class Episode {
  final int number;
  final String title;

  Episode({required this.number, required this.title});
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
  });

  bool get isSeries => episodes.isNotEmpty;
}