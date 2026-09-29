import 'package:flutter/material.dart';

import 'models/models.dart';
import 'screens/admin_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/cangur_screen.dart';
import 'screens/father_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'widgets/mc_widgets.dart';

void main() {
  runApp(CangurApp(state: AppState()));
}

class CangurApp extends StatelessWidget {
  const CangurApp({required this.state, super.key});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'Mon Cangur',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: '/login',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/signup':
              return _page(settings, const SignupScreen());
            case '/forgot':
              return _page(settings, const ForgotScreen());
            case '/admin':
              return _guard(settings, const AdminScreen(), UserRole.admin);
            case '/cangur':
              return _guard(settings, const CangurScreen(), UserRole.cangur);
            case '/father':
              return _guard(settings, const FatherScreen(), UserRole.father);
            case '/login':
            default:
              return _page(settings, const LoginScreen());
          }
        },
      ),
    );
  }

  MaterialPageRoute<void> _page(RouteSettings settings, Widget child) {
    return MaterialPageRoute(settings: settings, builder: (_) => child);
  }

  MaterialPageRoute<void> _guard(RouteSettings settings, Widget child, UserRole role) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        final state = AppScope.of(context);
        if (state.user == null || state.user!.role != role) {
          return const LoginScreen();
        }
        return child;
      },
    );
  }
}
