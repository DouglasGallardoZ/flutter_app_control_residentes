import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'application/blocs/auth/auth_bloc.dart';
import 'application/blocs/qr/qr_bloc.dart';
import 'application/blocs/history/access_history_bloc.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/ports/auth_repository.dart';
import 'domain/usecases/generate_qr_usecase.dart';
import 'domain/usecases/load_access_history_usecase.dart';
import 'presentation/routes/app_routes.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/theme/theme_controller.dart'; // 👈 Importa el controlador
import 'application/blocs/visitor/visitor_bloc.dart';
import 'application/blocs/qr_visit/qr_visit_bloc.dart';
import 'domain/usecases/manage_visitor_usecase.dart';
import 'domain/usecases/generate_visit_qr_usecase.dart';
import 'injection.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc(login: sl<LoginUseCase>(), authRepo: sl<AuthRepository>())),
        BlocProvider<QrBloc>(create: (_) => QrBloc(sl<GenerateQrUseCase>())),
        BlocProvider<AccessHistoryBloc>(create: (_) => AccessHistoryBloc(sl<LoadAccessHistoryUseCase>())),
        BlocProvider<VisitorBloc>(create: (_) => VisitorBloc(sl<ManageVisitorUseCase>())),   // 👈 nuevo
        BlocProvider<QrVisitBloc>(create: (_) => QrVisitBloc(sl<GenerateVisitQrUseCase>())), // 👈 nuevo
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeController.mode,
        builder: (ctx, mode, _) {
          return MaterialApp(
            title: 'Acceso Residencial',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: mode, 
            initialRoute: AppRoutes.login,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
