import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'classes/odoo_api.dart';
import 'views/login_screen.dart';
import 'classes/odoo_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = OdooApi(
      baseUrl: 'https://mo2men-store.odoo.com',
      db: 'mo2men-store',
    );

    return ChangeNotifierProvider(
      create: (_) => OdooProvider(api: api),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Odoo Sales App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const LoginScreen(),
      ),
    );
  }
}
