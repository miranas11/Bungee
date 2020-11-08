import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget cachedNetworkImage(mediaUrl) {
  return CachedNetworkImage(
    height: 300,
    imageUrl: mediaUrl,
    fit: BoxFit.cover,
    errorWidget: (context, url, error) => Icon(Icons.error),
    placeholder: (context, url) {
      return Padding(
        padding: EdgeInsets.all(50),
        child: CircularProgressIndicator(),
      );
    },
  );
}
