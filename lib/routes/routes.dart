import 'package:cynk/features/auth/auth_cubit.dart';
import 'package:cynk/features/chats/chat_screen.dart';
import 'package:cynk/features/chats/chats_screen.dart';
import 'package:cynk/features/chats/cubits/messages_cubit.dart';
import 'package:cynk/features/contacts/contacts_cubit.dart';
import 'package:cynk/features/contacts/contacts_screen.dart';
import 'package:cynk/features/profile/profile_cubit.dart';
import 'package:cynk/features/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'routes.g.dart';

@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: [
    TypedGoRoute<ChatRoute>(
      path: '/chat/:chatId',
    ),
    TypedGoRoute<ContactsRoute>(
      path: '/contacts',
    ),
    TypedGoRoute<OwnProfileRoute>(
      path: '/profile',
    ),
    TypedGoRoute<ProfileRoute>(
      path: '/profile/:userId',
    ),
  ],
)
class HomeRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ChatsScreen();
  }
}

class ChatRoute extends GoRouteData {
  ChatRoute({required this.chatId});

  final String chatId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (context) => MessagesCubit(
        dataSource: context.read(),
        chatId: chatId,
        userId: (context.read<AuthCubit>().state as SignedInState).userId,
      )..loadMessages(),
      child: ChatScreen(chatId: chatId),
    );
  }
}

class ContactsRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (context) => ContactsCubit(
        dataSource: context.read(),
        userId: (context.read<AuthCubit>().state as SignedInState).userId,
      )..loadContacts(),
      child: const ContactsScreen(),
    );
  }
}

class OwnProfileRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (context) => ProfileCubit(
        dataSource: context.read(),
        userId: (context.read<AuthCubit>().state as SignedInState).userId,
        isOwner: true,
      )..loadProfile(),
      child: const ProfileScreen(),
    );
  }
}

class ProfileRoute extends GoRouteData {
  ProfileRoute({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (context) => ProfileCubit(
        dataSource: context.read(),
        userId: userId,
        isOwner: state.pathParameters.isEmpty,
      )..loadProfile(),
      child: const ProfileScreen(),
    );
  }
}
