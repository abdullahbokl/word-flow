import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:word_flow/features/word_learning/presentation/pages/workspace_page.dart';
import 'package:word_flow/features/vocabulary/presentation/pages/library_page.dart';
import 'package:word_flow/features/profile/presentation/pages/profile_page.dart';

part 'routes.g.dart';

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
