import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DetailPage extends StatelessWidget {
  final String title;
  final String value;
  final String image;
  final String description;
  final String description2;

  const DetailPage({
    Key? key,
    required this.title,
    required this.value,
    required this.image,
    required this.description,
    required this.description2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 16),
        child: Padding(
          padding: const EdgeInsets.only(top: 16, left: 16),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarBrightness: Brightness.dark),
          ),
        ),
      ),
      backgroundColor: const Color(0xFF312E81),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Align(
                alignment: const AlignmentDirectional(3, -0.3),
                child: Container(
                  height: 300,
                  width: 300,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.deepPurple),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(-3, -0.3),
                child: Container(
                  height: 300,
                  width: 300,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFF673AB7)),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0, -1.2),
                child: Container(
                  height: 300,
                  width: 600,
                  decoration: const BoxDecoration(color: Color(0xFFFFAB40)),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
                child: Container(
                  decoration: const BoxDecoration(color: Colors.transparent),
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Image.asset(
                          image,
                          height: 150,
                          width: 150,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 48,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          description2,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                        textAlign:
                            TextAlign.justify,
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
