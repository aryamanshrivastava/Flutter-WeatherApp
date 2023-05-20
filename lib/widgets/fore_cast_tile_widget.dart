// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ForeCastTileWidget extends StatelessWidget {
  String? temp;
  String? imageUrl;
  String? time;
  ForeCastTileWidget({
    super.key,
    required this.temp,
    required this.imageUrl,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
    return Card(
      color: Colors.blueGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                temp ?? '',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              CachedNetworkImage(
                imageUrl: imageUrl ?? '',
                height: 50,
                width: 50,
                fit: BoxFit.fill,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(
                  Icons.image,
                  color: Colors.white,
                ),
              ),
              Text(
                time ?? '',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          )),
    );
  }
}
