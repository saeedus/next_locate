import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:next_locate/app.dart';
import 'package:next_locate/core/di/injection_container.dart' as di;

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  di.init();
  runApp(const MyApp());
}

