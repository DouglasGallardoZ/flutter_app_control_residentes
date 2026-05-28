import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'application/blocs/auth/auth_bloc.dart';
import 'application/blocs/qr/qr_bloc.dart';
import 'application/blocs/history/access_history_bloc.dart';
import 'domain/usecases/generate_qr_usecase.dart';
import 'domain/usecases/load_access_history_usecase.dart';
import 'presentation/routes/app_routes.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/theme/theme_controller.dart';
import 'application/blocs/qr_visit/qr_visit_bloc.dart';
import 'domain/usecases/generate_visit_qr_usecase.dart';
import 'application/blocs/account/account_bloc.dart';
import 'application/blocs/admin/admin_dashboard_bloc.dart';
import 'application/blocs/facial_enrollment/facial_enrollment_bloc.dart';
import 'application/blocs/resident/resident_bloc.dart';
import 'application/blocs/owner/owner_bloc.dart';
import 'application/blocs/member/member_bloc.dart';
import 'application/blocs/admin_account/admin_account_bloc.dart';
import 'application/blocs/qr_display/qr_display_bloc.dart';
import 'application/blocs/prospecto_validation/prospecto_validation_bloc.dart';
import 'application/blocs/registro_residente/registro_residente_bloc.dart';
import 'injection.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<QrBloc>(create: (_) => QrBloc(sl<GenerateQrUseCase>())),
        BlocProvider<AccessHistoryBloc>(create: (_) => AccessHistoryBloc(sl<LoadAccessHistoryUseCase>())),
        BlocProvider<QrVisitBloc>(create: (_) => QrVisitBloc(sl<GenerateVisitQrUseCase>())),
        BlocProvider<AccountBloc>(create: (_) => sl<AccountBloc>()),
        BlocProvider<AdminDashboardBloc>(create: (_) => sl<AdminDashboardBloc>()),
        BlocProvider<ResidentBloc>(create: (_) => sl<ResidentBloc>()),
        BlocProvider<MemberBloc>(create: (_) => sl<MemberBloc>()),
        BlocProvider<AdminAccountBloc>(create: (_) => sl<AdminAccountBloc>()),
        BlocProvider<FacialEnrollmentBloc>(create: (_) => sl<FacialEnrollmentBloc>()),
        BlocProvider<OwnerBloc>(create: (_) => sl<OwnerBloc>()),
        BlocProvider<QrDisplayBloc>(create: (_) => sl<QrDisplayBloc>()),
        BlocProvider<ProspectoValidationBloc>(create: (_) => sl<ProspectoValidationBloc>()),
        BlocProvider<RegistroResidenteBloc>(create: (_) => sl<RegistroResidenteBloc>()),
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
