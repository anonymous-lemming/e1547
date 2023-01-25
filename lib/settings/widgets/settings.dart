import 'package:async_builder/async_builder.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/user/user.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:talker/talker.dart';

import 'grid.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage();

  @override
  State createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(
      builder: (context, settings, child) => Scaffold(
        appBar: const DefaultAppBar(
          title: Text('Settings'),
        ),
        body: LimitedWidthLayout.builder(
          builder: (context) => ListView(
            primary: true,
            padding: defaultActionListPadding
                .add(LimitedWidthLayout.of(context).padding),
            children: [
              const SettingsHeader(title: 'Server'),
              Consumer<ClientService>(
                builder: (context, service, child) => MouseCursorRegion(
                  behavior: HitTestBehavior.translucent,
                  onLongPress: () => setCustomHost(context),
                  child: SwitchListTile(
                    title: const Text('Host'),
                    subtitle: Text(service.host),
                    secondary: const Icon(Icons.storage),
                    value: service.isCustomHost,
                    onChanged: (value) async {
                      if (!service.hasCustomHost) {
                        await setCustomHost(context);
                      }
                      service.useCustomHost(value);
                    },
                  ),
                ),
              ),
              Consumer<Client>(
                builder: (context, client, child) =>
                    SubValueBuilder<Future<CurrentUser?>>(
                  create: (context) => client.currentUser(),
                  selector: (context) => [client],
                  builder: (context, future) => FutureBuilder<CurrentUser?>(
                    future: future,
                    builder: (context, snapshot) => CrossFade.builder(
                      duration: const Duration(milliseconds: 200),
                      showChild: client.credentials != null,
                      builder: (context) => DividerListTile(
                        title: Text(client.credentials!.username),
                        subtitle: snapshot.data?.levelString != null
                            ? Text(snapshot.data!.levelString.toLowerCase())
                            : null,
                        leading: const IgnorePointer(
                          child: CurrentUserAvatar(),
                        ),
                        separated: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: IgnorePointer(
                            child: IconButton(
                              icon: const Icon(Icons.exit_to_app),
                              onPressed: () => logout(context),
                            ),
                          ),
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                UserLoadingPage(client.credentials!.username),
                          ),
                        ),
                        onTapSeparated: () => logout(context),
                      ),
                      secondChild: ListTile(
                        title: const Text('Login'),
                        leading: const Icon(Icons.person_add),
                        onTap: () => Navigator.pushNamed(context, '/login'),
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(),
              const SettingsHeader(title: 'Display'),
              ValueListenableBuilder<AppTheme>(
                valueListenable: settings.theme,
                builder: (context, value, child) => ListTile(
                  title: const Text('Theme'),
                  subtitle: Text(value.name),
                  leading: const Icon(Icons.brightness_6),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: const Text('Theme'),
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: AppTheme.values
                                .map(
                                  (theme) => ListTile(
                                    title: Text(theme.name),
                                    trailing: Container(
                                      height: 28,
                                      width: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: theme.data.cardColor,
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .iconTheme
                                              .color!,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      settings.theme.value = theme;
                                      Navigator.of(context).maybePop();
                                    },
                                  ),
                                )
                                .toList(),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              ExpandableNotifier(
                initialExpanded: false,
                child: ExpandableTheme(
                  data: ExpandableThemeData(
                    headerAlignment: ExpandablePanelHeaderAlignment.center,
                    iconColor: Theme.of(context).iconTheme.color,
                  ),
                  child: ExpandablePanel(
                    header: const ListTile(
                      leading: Icon(Icons.grid_view),
                      title: Text('Grid'),
                      subtitle: Text('post grid settings'),
                    ),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ValueListenableBuilder<int>(
                          valueListenable: settings.tileSize,
                          builder: (context, value, child) => ListTile(
                            title: const Text('Tile size'),
                            subtitle: Text(value.toString()),
                            leading: const Icon(Icons.crop),
                            onTap: () => showDialog(
                              context: context,
                              builder: (context) => RangeDialog(
                                title: const Text('Tile size'),
                                value: value,
                                division: (300 / 50).round(),
                                min: 100,
                                max: 400,
                                onSubmit: (value) {
                                  if (value == null || value <= 0) return;
                                  settings.tileSize.value = value;
                                },
                              ),
                            ),
                          ),
                        ),
                        ValueListenableBuilder<GridQuilt>(
                          valueListenable: settings.quilt,
                          builder: (context, value, child) => GridSettingsTile(
                            state: value,
                            onChange: (state) => setState(() {
                              settings.quilt.value = state;
                            }),
                          ),
                        ),
                      ],
                    ),
                    collapsed: const SizedBox.shrink(),
                  ),
                ),
              ),
              const Divider(),
              const SettingsHeader(title: 'Listing'),
              Consumer2<HistoriesService, Client>(
                builder: (context, service, client, child) =>
                    SubValueBuilder<Stream<int>>(
                  create: (context) => service.watchLength(host: client.host),
                  selector: (context) => [service, client.host],
                  builder: (context, stream) => AsyncBuilder<int>(
                    retain: true,
                    stream: stream,
                    builder: (context, value) => DividerListTile(
                      title: const Text('History'),
                      subtitle: service.enabled && value != null
                          ? Text('$value pages visited')
                          : null,
                      leading: const Icon(Icons.history),
                      onTap: () => Navigator.pushNamed(context, '/history'),
                      onTapSeparated: () => service.enabled = !service.enabled,
                      separated: Switch(
                        value: service.enabled,
                        onChanged: (value) => service.enabled = value,
                      ),
                    ),
                  ),
                ),
              ),
              Consumer<DenylistService>(
                builder: (context, denylist, child) => ListTile(
                  title: const Text('Blacklist'),
                  leading: const Icon(Icons.block),
                  subtitle: denylist.items.isNotEmpty
                      ? Text(
                          '${denylist.items.join(' ').split(' ').trim().where((e) => e[0] != '-').length} tags blocked')
                      : null,
                  onTap: () => Navigator.pushNamed(context, '/blacklist'),
                ),
              ),
              Consumer2<FollowsService, Client>(
                builder: (context, service, client, child) =>
                    SubValueBuilder<Stream<int>>(
                  create: (context) => service.watchLength(host: client.host),
                  selector: (context) => [service, client.host],
                  builder: (context, stream) => AsyncBuilder<int>(
                    retain: true,
                    stream: stream,
                    builder: (context, value) => ListTile(
                      title: const Text('Following'),
                      subtitle: value != null && value != 0
                          ? Text('$value searches followed')
                          : null,
                      leading: const Icon(Icons.turned_in),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FollowsFolderPage(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(),
              const SettingsHeader(title: 'Other'),
              ListTile(
                leading: const Icon(Icons.tune),
                title: const Text('Advanced settings'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AdvancedSettingsPage(),
                  ),
                ),
              ),
              if (context.read<Talker?>() != null)
                Consumer<Talker>(
                  builder: (context, talker, child) =>
                      StreamBuilder<TalkerDataInterface>(
                    stream: talker.stream,
                    builder: (context, snapshot) {
                      return ListTile(
                        leading: const Icon(Icons.format_list_numbered),
                        title: const Text('Logs'),
                        subtitle: talker.history.isNotEmpty
                            ? Text('${talker.history.length} events logged')
                            : null,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => LoggerPage(
                              talker: talker,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
