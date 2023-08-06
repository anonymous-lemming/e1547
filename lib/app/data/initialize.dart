import 'dart:io';

import 'package:dio_cache_interceptor_db_store/dio_cache_interceptor_db_store.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:notified_preferences/notified_preferences.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

export 'package:e1547/logs/logs.dart' show Logs;
export 'package:e1547/settings/settings.dart' show AppInfo;
export 'package:window_manager/window_manager.dart' show WindowManager;

/// Initializes an AppInfo with default production values.
Future<AppInfo> initializeAppInfo() async => AppInfo.fromPlatform(
      developer: 'binaryfloof',
      github: 'clragon/e1547',
      discord: 'MRwKGqfmUz',
      website: 'e1547.clynamic.net',
      kofi: 'binaryfloof',
      allowedHosts: ['e926.net', 'e621.net'],
    );

/// Initializes the databases used by the app with default production values.
Future<AppDatabases> initializeAppdatabases({required AppInfo info}) async {
  final String temporaryFiles = await getTemporaryDirectory()
      .then((value) => join(value.path, info.appName));
  return AppDatabases(
    preferences: await SharedPreferences.getInstance(),
    temporaryFiles: temporaryFiles,
    httpCache: DbCacheStore(databasePath: temporaryFiles),
    httpMemoryCache: MemCacheStore(),
    cookies: await initializeCookiesService(info.allowedHosts),
    followDb: connectDatabase('follows.sqlite'),
    historyDb: connectDatabase('history.sqlite'),
  );
}

/// Initializes the logger used by the app with default production values.
Future<Logs> initializeLogger({
  required AppDatabases databases,
  String? postfix,
  List<LoggyPrinter>? printers,
}) async {
  MemoryLogs logs = MemoryLogs();
  File logFile = File(join(databases.temporaryFiles,
      '${logFileDateFormat.format(DateTime.now())}${postfix != null ? '.$postfix' : ''}.log'));
  Loggy.initLoggy(
    logPrinter: MultiLoggyPrinter([
      logs,
      const ConsoleLoggyPrinter(),
      FilePrinter(logFile),
      if (printers != null) ...printers,
    ]),
  );
  registerFlutterErrorHandler(
    (error, trace) => Loggy('Flutter').log(logLevelCritical, error, trace),
  );
  return logs;
}

/// Returns an initialized WindowManager or null the current Platform is unsupported.
Future<WindowManager?> initializeWindowManager() async {
  if ([Platform.isWindows, Platform.isLinux, Platform.isMacOS].any((e) => e)) {
    WindowManager manager = WindowManager.instance;
    await manager.ensureInitialized();
    return manager;
  }
  return null;
}