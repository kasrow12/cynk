// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $authGateRoute,
    ];

RouteBase get $authGateRoute => GoRouteData.$route(
      path: '/',
      factory: $AuthGateRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: '/chat/:chatId',
          factory: $ChatRouteExtension._fromState,
        ),
      ],
    );

extension $AuthGateRouteExtension on AuthGateRoute {
  static AuthGateRoute _fromState(GoRouterState state) => AuthGateRoute();

  String get location => GoRouteData.$location(
        '/',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ChatRouteExtension on ChatRoute {
  static ChatRoute _fromState(GoRouterState state) => ChatRoute(
        chatId: state.pathParameters['chatId']!,
        $extra: state.extra as User,
      );

  String get location => GoRouteData.$location(
        '/chat/${Uri.encodeComponent(chatId)}',
      );

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}
