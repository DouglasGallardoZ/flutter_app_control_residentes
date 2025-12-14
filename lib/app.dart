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
      ],
      child: MaterialApp(
        title: 'Control de accesos',
        initialRoute: AppRoutes.login,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
