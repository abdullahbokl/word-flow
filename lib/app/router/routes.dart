import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../features/words/presentation/pages/workspace_page.dart';
import '../../../features/words/presentation/pages/library_page.dart';

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
