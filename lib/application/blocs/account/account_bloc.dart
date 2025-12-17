import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/ports/account_repository.dart';
import 'account_event.dart';
import 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountRepository repo;
  AccountBloc(this.repo) : super(AccountInitial()) {
    on<RegisterAccountSubmitted>((e, emit) async {
      emit(AccountLoading());
      try {
        final acc = await repo.register(e.account);
        emit(AccountRegistered(acc));
      } catch (ex) {
        emit(AccountError('Error al registrar cuenta'));
      }
    });

    on<UpdateEmailSubmitted>((e, emit) async {
      emit(AccountLoading());
      try {
        await repo.updateEmail(e.id, e.newEmail);
        emit(AccountUpdated());
      } catch (ex) {
        emit(AccountError('Error al actualizar correo'));
      }
    });

    on<LoadFamilyMembersRequested>((e, emit) async {
      emit(AccountLoading());
      try {
        final members = await repo.listByResidenceAndRole(e.residenceId, 'family');
        emit(AccountMembersLoaded(members));
      } catch (ex) {
        emit(AccountError('Error al cargar miembros'));
      }
    });
  }
}
