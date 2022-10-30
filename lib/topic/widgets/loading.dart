import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';

class TopicLoadingPage extends StatefulWidget {
  const TopicLoadingPage(this.id, {this.orderByOldest = true});

  final int id;
  final bool orderByOldest;

  @override
  State<TopicLoadingPage> createState() => _TopicLoadingPageState();
}

class _TopicLoadingPageState extends State<TopicLoadingPage> {
  late Future<Topic> topic = context.read<Client>().topic(widget.id);

  @override
  Widget build(BuildContext context) {
    return FutureLoadingPage<Topic>(
      future: topic,
      builder: (context, value) => RepliesPage(
        topic: value,
        orderByOldest: widget.orderByOldest,
      ),
      title: Text('Topic #${widget.id}'),
      onError: const Text('Failed to load topic'),
      onEmpty: const Text('Topic not found'),
    );
  }
}

class ReplyLoadingPage extends StatefulWidget {
  const ReplyLoadingPage(this.id);

  final int id;

  @override
  State<ReplyLoadingPage> createState() => _ReplyLoadingPageState();
}

class _ReplyLoadingPageState extends State<ReplyLoadingPage> {
  late Future<Reply> reply = context.read<Client>().reply(widget.id);

  @override
  Widget build(BuildContext context) {
    return FutureLoadingPage<Reply>(
      future: reply,
      builder: (context, value) => TopicLoadingPage(value.topicId),
      title: Text('Reply #${widget.id}'),
      onError: const Text('Failed to load reply'),
      onEmpty: const Text('Reply not found'),
    );
  }
}
