import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../commute/providers/arrival_provider.dart';
import 'home_widget_service.dart';

final homeWidgetServiceProvider = Provider<HomeWidgetService>(
  (ref) => HomeWidgetService(ref.watch(arrivalRepositoryProvider)),
);
