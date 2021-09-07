import 'dart:async';

import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';

typedef StepCallback = bool Function([int? progress]);

abstract class DataUpdater<T> extends ChangeNotifier {
  final ValueNotifier<int> progress = ValueNotifier(0);
  final Mutex updateLock = Mutex();

  Duration? get stale;

  Future? get finish => completer?.future;
  Completer? completer;

  bool error = false;
  bool restart = false;

  DataUpdater() {
    getRefreshListeners().forEach((element) => element.addListener(refresh));
  }

  @override
  void dispose() {
    getRefreshListeners().forEach((element) => element.removeListener(refresh));
    super.dispose();
  }

  @mustCallSuper
  Future<void> refresh() async {
    if (completer?.isCompleted ?? true) {
      update();
    } else {
      restart = true;
    }
    return finish;
  }

  @mustCallSuper
  List<ValueNotifier> getRefreshListeners() => [];

  Future<T> read();

  Future<void> write(T? data);

  Future<T?> run(T data, StepCallback step, bool force);

  @mustCallSuper
  bool step({int? progress, bool force = false}) {
    if (restart) {
      updateLock.release();
      update(force: force);
      return false;
    } else {
      this.progress.value = progress ?? this.progress.value + 1;
      notifyListeners();
      return true;
    }
  }

  @mustCallSuper
  void fail() {
    error = true;
    complete();
  }

  @mustCallSuper
  void complete() {
    updateLock.release();
    completer!.complete();
    notifyListeners();
  }

  Future<void> update({bool force = false}) async {
    if (completer?.isCompleted ?? true) {
      completer = Completer();
    }
    if (updateLock.isLocked) {
      return finish;
    }
    await updateLock.acquire();
    progress.value = 0;
    restart = false;
    error = false;

    notifyListeners();

    bool step([int? progress]) => this.step(progress: progress, force: force);

    Future<void> _update() async {
      T data = await read();
      T? result = await run(data, step, force);
      await write(result);
      complete();
    }

    _update();

    return finish;
  }
}

mixin HostableUpdater<T> on DataUpdater<T> {
  @override
  List<ValueNotifier> getRefreshListeners() =>
      super.getRefreshListeners()..add(settings.host);
}