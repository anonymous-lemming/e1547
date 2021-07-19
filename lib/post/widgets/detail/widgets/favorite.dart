import 'package:e1547/post.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class FavoriteButton extends StatelessWidget {
  final Post post;

  const FavoriteButton({this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2),
      child: ValueListenableBuilder(
        valueListenable: post.isFavorite,
        builder: (context, value, child) => LikeButton(
          isLiked: value,
          circleColor: CircleColor(start: Colors.pink, end: Colors.red),
          bubblesColor: BubblesColor(
              dotPrimaryColor: Colors.pink, dotSecondaryColor: Colors.red),
          likeBuilder: (bool isLiked) => Icon(
            Icons.favorite,
            color:
                isLiked ? Colors.pinkAccent : Theme.of(context).iconTheme.color,
          ),
          onTap: (isLiked) async {
            if (isLiked) {
              post.tryRemoveFav(context);
              return false;
            } else {
              post.tryAddFav(
                context,
                cooldown: Duration(milliseconds: 1000),
              );
              return true;
            }
          },
        ),
      ),
    );
  }
}