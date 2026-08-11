import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: await RustLib.init();
  runApp(const ProviderScope(child: BitchatApp()));
}
