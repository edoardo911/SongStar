import 'package:flutter/material.dart';

class SongSearch extends StatelessWidget {
  final Map<String, dynamic>? data;

  const SongSearch({
    super.key,
    this.data
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () => Navigator.pushNamed(
            context,
            "/song",
            arguments: {
              "song": data?["external_urls"]["spotify"]
            }
        ),
        style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.zero,
            )
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.network(
                  data?["album"]["images"][0]["url"],
                  width: 100,
                  height: 100,
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data?["name"],
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20
                        ),
                      ),
                      Text(
                        data?["artists"][0]["name"],
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Text(
              data?["album"]["release_date"],
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            )
          ],
        )
    );
  }
}


class AlbumSearch extends StatelessWidget {
  final Map<String, dynamic>? data;

  const AlbumSearch({
    super.key,
    this.data
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () => Navigator.pushNamed(
            context,
            "/album",
            arguments: {
              "album": data?["external_urls"]["spotify"]
            }
        ),
        style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.zero,
            )
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.network(
                  data?["images"][0]["url"],
                  width: 100,
                  height: 100,
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data?["name"],
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20
                        ),
                      ),
                      Text(
                        data?["artists"][0]["name"],
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Text(
              data?["release_date"],
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            )
          ],
        )
    );
  }
}

class ArtistSearch extends StatelessWidget {
  final Map<String, dynamic>? data;

  const ArtistSearch({
    super.key,
    this.data
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () => Navigator.pushNamed(
            context,
            "/artist",
            arguments: {
              "artist": data?["external_urls"]["spotify"]
            }
        ),
        style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.zero,
            )
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Builder(builder: (context) {
                  if(data?["images"].isNotEmpty) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        data?["images"][0]["url"],
                        width: 30,
                        height: 30,
                      ),
                    );
                  } else {
                    return Icon(
                      Icons.account_circle,
                      color: Colors.white,
                      size: 32,
                    );
                  }
                }),
                SizedBox(width: 10),
                Text(
                  data?["name"],
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20
                  ),
                ),
              ],
            ),
            Text(
              (data?["followers"]["total"] as int).toString(),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16
              ),
            ),
          ],
        )
    );
  }
}


class NoMatches extends StatelessWidget {
  const NoMatches({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 64),
        Icon(
          Icons.not_interested,
          color: Colors.white24,
          size: 32,
        ),
        Text(
          "No matches",
          style: TextStyle(
            color: Colors.white24,
            fontSize: 32,
          ),
        )
      ],
    );
  }
}