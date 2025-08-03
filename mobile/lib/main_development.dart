import 'package:flutter/widgets.dart';
import 'package:tilikjalan/app/app.dart';
import 'package:tilikjalan/bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap(() => const App());
}
