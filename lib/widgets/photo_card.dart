import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PhotoCard extends StatelessWidget {
  final Photo photo;

  const PhotoCard({Key? key, required this.photo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.network(
              photo.url,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              _formatTimestamp(photo.timestamp),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final formatter = DateFormat('MMM d, yyyy');
    return formatter.format(timestamp);
  }
}

class Photo {
  final String url;
  final DateTime timestamp;

  Photo({required this.url, required this.timestamp});
}
