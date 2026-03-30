import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:word_flow/features/word_learning/presentation/pages/workspace_page.dart';
import 'package:word_flow/features/vocabulary/presentation/pages/library_page.dart';
import 'package:word_flow/features/profile/presentation/pages/profile_page.dart';
import 'package:word_flow/features/authentication/presentation/pages/auth_page.dart';
import 'package:word_flow/features/vocabulary/presentation/pages/analysis_settings_page.dart';
import 'package:word_flow/app/router/splash_page.dart';

part 'routes.g.dart';

@TypedGoRoute<SplashRoute>(path: '/splash')
class SplashRoute extends GoRouteData with _$SplashRoute {
  const SplashRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const SplashPage();
}

@TypedGoRoute<AnalysisSettingsRoute>(path: '/settings/analysis')
class AnalysisSettingsRoute extends GoRouteData with _$AnalysisSettingsRoute {
  const AnalysisSettingsRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const AnalysisSettingsPage();
}

@TypedGoRoute<AuthRoute>(path: '/auth')
class AuthRoute extends GoRouteData with _$AuthRoute {
  const AuthRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const AuthPage();
}

@TypedGoRoute<WorkspaceRoute>(path: '/workspace')
class WorkspaceRoute extends GoRouteData with _$WorkspaceRoute {
  const WorkspaceRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const WorkspacePage();
}

@TypedGoRoute<LibraryRoute>(path: '/library')
class LibraryRoute extends GoRouteData with _$LibraryRoute {
  const LibraryRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const LibraryPage();
}

@TypedGoRoute<ProfileRoute>(path: '/profile')
class ProfileRoute extends GoRouteData with _$ProfileRoute {
  const ProfileRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const ProfilePage();
}
