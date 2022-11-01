import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_db_store/dio_cache_interceptor_db_store.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

class HostService extends ChangeNotifier {
  HostService({
    required this.appInfo,
    required this.defaultHost,
    required List<String> allowedHosts,
    String? host,
    String? customHost,
    required String cachePath,
    Credentials? credentials,
  })  : allowedHosts = {defaultHost, ...allowedHosts}.toList(),
        _host = host ?? defaultHost,
        _customHost = customHost,
        _credentials = credentials,
        cache = DbCacheStore(
          databasePath: join(
            cachePath,
            appInfo.appName,
          ),
        );

  @override
  void dispose() {
    cache.close();
    super.dispose();
  }

  final AppInfo appInfo;
  final String defaultHost;
  final List<String> allowedHosts;

  CacheStore cache;

  String _host;

  String get host => _host;

  set host(String value) {
    if (_host == value) return;
    _host = value;
    notifyListeners();
  }

  String? _customHost;

  String? get customHost => _customHost;

  set customHost(String? value) {
    if (_customHost == value) return;
    _customHost = value;
    notifyListeners();
  }

  Credentials? _credentials;

  Credentials? get credentials => _credentials;

  set credentials(Credentials? value) {
    if (_credentials == value) return;
    _credentials = value;
    notifyListeners();
  }

  bool get hasCustomHost => customHost != null;

  bool get isCustomHost => host == customHost;

  Dio _getClient() {
    return Dio(
      BaseOptions(
        baseUrl: 'https://$host/',
        headers: {
          HttpHeaders.userAgentHeader:
              '${appInfo.appName}/${appInfo.version} (${appInfo.developer})',
        },
        sendTimeout: 30000,
        connectTimeout: 30000,
      ),
    );
  }

  Future<void> setCustomHost(String value) async {
    if (host.isEmpty) {
      customHost = null;
    } else {
      try {
        await _getClient().get('https://$host');
        await Future.delayed(const Duration(seconds: 1));
        if (host == defaultHost) {
          throw CustomHostDefaultException(host: host);
        } else if (allowedHosts.contains(host)) {
          customHost = host;
        } else {
          throw CustomHostIncompatibleException(host: host);
        }
      } on DioError {
        throw CustomHostUnreachableException(host: host);
      }
    }
  }

  void useCustomHost(bool value) {
    if (value) {
      if (!hasCustomHost) return;
      host = customHost!;
    } else {
      host = defaultHost;
    }
  }

  Future<bool> tryLogin(Credentials value) async {
    return validateCall(
      () async => _getClient().get(
        'favorites.json',
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: value.basicAuth,
          },
        ),
      ),
    );
  }

  Future<bool> login(Credentials value) async {
    if (await tryLogin(value)) {
      credentials = value;
      return true;
    } else {
      return false;
    }
  }

  Future<void> logout() async => credentials = null;
}

abstract class CustomHostException implements Exception {
  CustomHostException({required this.message, required this.host});

  final String message;
  final String host;
}

class CustomHostDefaultException extends CustomHostException {
  CustomHostDefaultException({required super.host})
      : super(message: 'Custom host cannot be default host');
}

class CustomHostIncompatibleException extends CustomHostException {
  CustomHostIncompatibleException({required super.host})
      : super(message: 'Host API incompatible');
}

class CustomHostUnreachableException extends CustomHostException {
  CustomHostUnreachableException({required super.host})
      : super(message: 'Host cannot be reached');
}