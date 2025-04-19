import 'dart:async';

import 'package:flutter/widgets.dart';

Stream<T> asStream<T>(ChangeNotifier notifier, T Function() value) {
  final controller = StreamController<T>();
  notifier.addListener(() => controller.add(value()));
  return controller.stream;
}
