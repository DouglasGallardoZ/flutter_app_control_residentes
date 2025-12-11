// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/styles/app_theme_builder.dart';
import 'core/config/brand_theme.dart';
import 'presentation/routes/app_routes.dart';
import 'injection.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/qr_repository.dart';
import 'domain/repositories/access_history_repository.dart';
import 'domain/repositories/account_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/qr/qr_bloc.dart';
import 'presentation/blocs/history/access_history_bloc.dart';
import 'presentation/blocs/account/account_bloc.dart';
import 'presentation/blocs/session/session_cubit.dart';

class App extends StatelessWidget {
  final BrandTheme brand;
  const App({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc(sl<AuthRepository>())),
        BlocProvider<QrBloc>(create: (_) => QrBloc(sl<QrRepository>())),
        BlocProvider<AccessHistoryBloc>(create: (_) => AccessHistoryBloc(sl<AccessHistoryRepository>())),
        BlocProvider<AccountBloc>(create: (_) => AccountBloc(sl<AccountRepository>())),
        BlocProvider<SessionCubit>(create: (_) => SessionCubit()),
      ],
      child: MaterialApp(
        title: brand.name,
        theme: AppThemeBuilder.build(brand),
        initialRoute: AppRoutes.login,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
