import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_notifier.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
