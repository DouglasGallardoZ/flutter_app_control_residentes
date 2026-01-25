/// Datos del usuario extraídos del AuthBloc
class UserDataForDisplay {
  final String userId;
  final String userName;
  final String identificacion;
  final String residenceId;
  final bool isFamilyMember;
  final String homeRoute;

  UserDataForDisplay({
    required this.userId,
    required this.userName,
    required this.identificacion,
    required this.residenceId,
    required this.isFamilyMember,
    required this.homeRoute,
  });
}

abstract class QrDisplayState {}

class QrDisplayInitial extends QrDisplayState {}

class QrDisplayLoaded extends QrDisplayState {
  final UserDataForDisplay userDataForDisplay;
  QrDisplayLoaded(this.userDataForDisplay);
}

class QrDisplayError extends QrDisplayState {
  final String message;
  QrDisplayError(this.message);
}

class NavigationRequested extends QrDisplayState {
  final String route;
  final Map<String, dynamic>? arguments;
  NavigationRequested(this.route, {this.arguments});
}
