import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/models.dart';
import 'screens/admin_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/cangur_screen.dart';
import 'screens/father_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'services/account_gateway.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'widgets/mc_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(CangurApp(state: AppState(accounts: FirebaseAccountGateway())));
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
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child ?? const SizedBox.shrink(),
          );
        },
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
        final user = state.user;
        if (user == null || user.role != role) {
          return const LoginScreen();
        }
        if (role == UserRole.father && !user.perfilCompleto) {
          return const ProfileSetupScreen();
        }
        return child;
      },
    );
  }
}
