import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/register_account_usecase.dart';
import '../../../domain/usecases/update_email_usecase.dart';
import '../../../domain/usecases/load_family_members_usecase.dart';
import 'account_event.dart';
import 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final RegisterAccountUseCase registerAccount;
  final UpdateEmailUseCase updateEmail;
  final LoadFamilyMembersUseCase loadFamilyMembers;

  AccountBloc({
    required this.registerAccount,
    required this.updateEmail,
    required this.loadFamilyMembers,
  }) : super(AccountInitial()) {
    on<RegisterAccountSubmitted>((e, emit) async {
      emit(AccountLoading());
      try {
        final acc = await registerAccount.execute(e.account);
        emit(AccountRegistered(acc));
      } catch (ex) {
        emit(AccountError('Error al registrar cuenta'));
      }
    });

    on<UpdateEmailSubmitted>((e, emit) async {
      emit(AccountLoading());
      try {
        await updateEmail.execute(e.id, e.newEmail);
        emit(AccountUpdated());
      } catch (ex) {
        emit(AccountError('Error al actualizar correo'));
      }
    });

    on<LoadFamilyMembersRequested>((e, emit) async {
      emit(AccountLoading());
      try {
        final members =
            await loadFamilyMembers.execute(e.residenceId, 'family');
        emit(AccountMembersLoaded(members));
      } catch (ex) {
        emit(AccountError('Error al cargar miembros'));
      }
    });
  }
}
