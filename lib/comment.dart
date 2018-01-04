// e1547: A mobile app for browsing e926.net and friends.
// Copyright (C) 2017 perlatus <perlatus@e1547.email.vczf.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

import 'dart:async' show Future;

import 'package:flutter/material.dart';

import 'client.dart' show client;
import 'pagination.dart' show LinearPagination;
import 'post.dart' show Post;

class Comment {
  Comment.fromRaw(this.raw) {
    id = raw['id'];
    creator = raw['creator'];
    body = raw['body'];
    score = raw['score'];
  }

  Map raw;

  int id;
  String creator;
  String body;
  int score;
}

class CommentsWidget extends StatefulWidget {
  const CommentsWidget(this.post, {Key key}) : super(key: key);

  final Post post;

  @override
  State createState() => new _CommentsWidgetState();
}

class _CommentsWidgetState extends State<CommentsWidget> {
  LinearPagination<Comment> _comments;
  bool _more = true;

  @override
  void initState() {
    super.initState();
    _comments = client.comments(widget.post.id);
    _loadNextPage();
  }

  Future<Null> _loadNextPage() async {
    _more = await _comments.loadNextPage();
    setState(() {});
  }

  @override
  Widget build(BuildContext ctx) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('#${widget.post.id} comments')),
      body: new ListView.builder(
        itemBuilder: _itemBuilder,
        padding: const EdgeInsets.all(10.0),
      ),
    );
  }

  // Comments are separated by dividers.
  //   0:    comment 0
  //   1:    divider
  //   2:    comment 1
  //   3:    divider
  //   4:    comment 2
  //   ...
  //   2n:   comment n-1
  //   2n+1: <no more comments message>
  Widget _itemBuilder(BuildContext ctx, int i) {
    List<Comment> comments = _comments.elements;

    int lastComment = comments.length * 2 - 1;

    if (i < lastComment) {
      if (i.isOdd) {
        return new Divider();
      }
      Comment c = comments[i ~/ 2];
      return new Text('${c.creator}: ${c.body}');
    }

    if (i == lastComment) {
      return new Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        child: _more
            ? new RaisedButton(
                child: new Text('load more'),
                onPressed: _loadNextPage,
              )
            : new Text('No more comments',
                textAlign: TextAlign.center,
                style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                )),
      );
    }

    return null;
  }
}
