import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/database/app_database.dart';
import 'package:word_flow/core/di/injection.config.dart';

final getIt = GetIt.instance;
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

@module
abstract class RegisterModule {
  @lazySingleton
  WordFlowDatabase get database => WordFlowDatabase();
}

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async => getIt.init();
