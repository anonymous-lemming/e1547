import 'package:e1547/interface.dart';
import 'package:e1547/settings.dart';
import 'package:e1547/tag.dart';
import 'package:e1547/wiki.dart';
import 'package:flutter/material.dart';

import 'input.dart';

class DenyListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DenyListPageState();
  }
}

class _DenyListPageState extends State<DenyListPage> {
  Function fabAction;
  List<String> denylist = [];
  TextEditingController textController = TextEditingController();
  PersistentBottomSheetController<String> sheetController;

  Future<void> updateDenylist() async {
    await db.denylist.value.then((value) {
      if (mounted) {
        setState(() => denylist = value);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    db.denylist.addListener(updateDenylist);
    updateDenylist();
  }

  @override
  void dispose() {
    super.dispose();
    db.denylist.removeListener(updateDenylist);
  }

  void addTags(BuildContext context, [int edit]) {
    void submit(String value, [int edit]) {
      value = value.trim();

      if (edit != null) {
        if (value.isNotEmpty) {
          denylist[edit] = value;
        } else {
          denylist.removeAt(edit);
        }
        db.denylist.value = Future.value(denylist);
        sheetController?.close();
      } else {
        if (value.isNotEmpty) {
          denylist.add(value);
          db.denylist.value = Future.value(denylist);
          sheetController?.close();
        }
      }
    }

    TextEditingController controller =
        TextEditingController(text: edit != null ? denylist[edit] : null);

    sheetController = Scaffold.of(context).showBottomSheet((context) {
      return ListTagEditor(
        controller: controller,
        onSubmit: (value) => submit(value, edit),
        prompt: 'Add to blacklist',
      );
    });

    setState(() {
      fabAction = () => submit(controller.text, edit);
    });

    sheetController.closed.then((_) {
      setState(() {
        fabAction = null;
      });
    });
  }

  Widget denyListTile(
      {@required String tag, Function() onEdit, Function() onDelete}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  direction: Axis.horizontal,
                  children: Tagset.parse(tag)
                      .map((tag) => DenyListTagCard(tag.toString()))
                      .toList(),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  PopupMenuButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onSelected: (value) => value(),
                    itemBuilder: (context) => [
                      PopupMenuTile(
                        value: onEdit,
                        title: 'Edit',
                        icon: Icons.edit,
                      ),
                      PopupMenuTile(
                        value: onDelete,
                        title: 'Delete',
                        icon: Icons.delete,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Divider()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body() {
      if (denylist.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check,
                size: 32,
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Text('Your blacklist is empty'),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.only(bottom: 30),
        itemCount: denylist.length,
        itemBuilder: (BuildContext context, int index) => denyListTile(
            tag: denylist[index],
            onEdit: () => addTags(context, index),
            onDelete: () {
              denylist.removeAt(index);
              db.denylist.value = Future.value(denylist);
            }),
        physics: BouncingScrollPhysics(),
      );
    }

    Widget floatingActionButton(BuildContext context) {
      return FloatingActionButton(
        child: fabAction != null ? Icon(Icons.check) : Icon(Icons.add),
        onPressed: () => fabAction != null ? fabAction() : addTags(context),
      );
    }

    Widget editor() {
      TextEditingController controller = TextEditingController();
      controller.text = denylist.join('\n');
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Blacklist'),
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () =>
                  wikiSheet(context: context, tag: 'e621:blacklist'),
            )
          ],
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.multiline,
          maxLines: null,
        ),
        actions: [
          TextButton(
            child: Text('CANCEL'),
            onPressed: Navigator.of(context).pop,
          ),
          TextButton(
            child: Text('OK'),
            onPressed: () {
              List<String> tags = controller.text.split('\n');
              tags = tags.map((e) => e.trim()).toList();
              tags.removeWhere((tag) => tag.isEmpty);
              db.denylist.value = Future.value(tags);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Blacklist'),
        actions: [
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) => editor(),
                );
              }),
        ],
      ),
      body: body(),
      floatingActionButton: Builder(
        builder: (context) {
          return floatingActionButton(context);
        },
      ),
    );
  }
}