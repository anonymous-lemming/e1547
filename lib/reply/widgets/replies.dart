import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class RepliesPage extends StatelessWidget {
  const RepliesPage({required this.topic, this.orderByOldest});

  final Topic topic;
  final bool? orderByOldest;

  @override
  Widget build(BuildContext context) {
    return RepliesProvider(
      topicId: topic.id,
      orderByOldest: orderByOldest,
      child: Consumer<RepliesController>(
        builder: (context, controller, child) => SubListener(
          initialize: true,
          listenable: controller,
          listener: () async {
            HistoriesService service = context.read<HistoriesService>();
            Client client = context.read<Client>();
            try {
              await controller.waitForFirstPage();
              await service.addTopic(
                client.host,
                topic,
                replies: controller.items!,
              );
            } on ClientException {
              return;
            }
          },
          builder: (context) => RefreshableDataPage(
            appBar: DefaultAppBar(
              title: Text(topic.title),
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Info',
                  onPressed: () => topicSheet(context, topic),
                ),
                const ContextDrawerButton(),
              ],
            ),
            controller: controller,
            drawer: const RouterDrawer(),
            endDrawer: ContextDrawer(
              title: const Text('Replies'),
              children: [
                AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) => SwitchListTile(
                    secondary: const Icon(Icons.sort),
                    title: const Text('Reply order'),
                    subtitle: Text(controller.orderByOldest
                        ? 'oldest first'
                        : 'newest first'),
                    value: controller.orderByOldest,
                    onChanged: (value) {
                      controller.orderByOldest = value;
                      Navigator.of(context).maybePop();
                    },
                  ),
                ),
              ],
            ),
            child: PagedListView(
              primary: true,
              padding: defaultActionListPadding,
              pagingController: controller.paging,
              builderDelegate: defaultPagedChildBuilderDelegate<Reply>(
                pagingController: controller.paging,
                itemBuilder: (context, item, index) =>
                    ReplyTile(reply: item, topic: topic),
                onEmpty: const Text('No replies'),
                onError: const Text('Failed to load replies'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
