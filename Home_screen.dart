import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/movie_data.dart';
import '../models/movie.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % movies.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final movie = movies[currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          banner(movie),
          sectionTitle("Trending"),
          movieRow(),
        ],
      ),
    );
  }

  Widget banner(Movie movie) {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: movie.backdrop,
          height: 400,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Container(
          height: 400,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black, Colors.transparent],
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(movie.title,
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                child: const Text("▶ Play"),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget sectionTitle(String title) => Padding(
    padding: const EdgeInsets.all(12),
    child: Text(title,
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold)),
  );

  Widget movieRow() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => DetailScreen(movie: movie)),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(10),
              width: 130,
              child: Column(
                children: [
                  CachedNetworkImage(
imageUrl: movie.poster,
                    height: 170,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 5),
                  Text(movie.title),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
