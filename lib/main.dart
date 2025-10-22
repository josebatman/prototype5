
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/analysis_page.dart';
import 'package:myapp/upload_page.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const UploadPage();
      },
    ),
    GoRoute(
      path: '/analysis',
      builder: (BuildContext context, GoRouterState state) {
        final List<List<dynamic>>? excelData = state.extra as List<List<dynamic>>?;
        return AnalysisPage(excelData: excelData);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Student Analysis App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: _router,
    );
  }
}
