import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cynk/features/auth/auth_cubit.dart';
import 'package:cynk/features/auth/auth_gate.dart';
import 'package:cynk/features/auth/auth_service.dart';
import 'package:cynk/features/data/firestore_data_source.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class CynkApp extends StatelessWidget {
  const CynkApp({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (context) => AuthService(
            firebase: FirebaseAuth.instance,
          ),
        ),
        Provider(
          create: (context) => FirestoreDataSource(
            db: FirebaseFirestore.instance,
            storage: FirebaseStorage.instance,
          ),
        ),
        BlocProvider(
          create: (context) => AuthCubit(
            authService: context.read(),
            dataSource: context.read(),
          ),
        ),
      ],
      child: AuthGate(child: child),
    );
  }
}
