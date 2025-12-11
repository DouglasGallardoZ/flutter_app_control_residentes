import 'package:flutter_bloc/flutter_bloc.dart';

class SessionState {
  final String? uid;
  final String? accountId;
  final String? role;
  final String? email;
  final String? name;

  const SessionState({this.uid, this.accountId, this.role, this.email, this.name});

  SessionState copyWith({
    String? uid,
    String? accountId,
    String? role,
    String? email,
    String? name,
  }) => SessionState(
        uid: uid ?? this.uid,
        accountId: accountId ?? this.accountId,
        role: role ?? this.role,
        email: email ?? this.email,
        name: name ?? this.name,
      );
}

class SessionCubit extends Cubit<SessionState> {
  SessionCubit() : super(const SessionState());

  void setUser(Map<String, dynamic> user) {
    emit(SessionState(
      uid: user['uid'],
      accountId: user['id'],
      role: user['role'],
      email: user['email'],
      name: user['name'],
    ));
  }

  void clear() => emit(const SessionState());
}
