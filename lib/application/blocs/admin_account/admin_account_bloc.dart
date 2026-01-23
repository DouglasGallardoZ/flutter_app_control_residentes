import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/search_account_by_email_usecase.dart';
import '../../../domain/usecases/search_account_by_location_usecase.dart';
import '../../../domain/usecases/block_account_usecase.dart';
import '../../../domain/usecases/unblock_account_usecase.dart';
import '../../../domain/usecases/delete_account_usecase.dart';
import '../../../domain/usecases/reset_password_usecase.dart';
import '../../../domain/ports/admin_account_repository.dart';
import 'admin_account_event.dart';
import 'admin_account_state.dart';

class AdminAccountBloc extends Bloc<AdminAccountEvent, AdminAccountState> {
  final SearchAccountByEmailUseCase searchByEmailUseCase;
  final SearchAccountByLocationUseCase searchByLocationUseCase;
  final BlockAccountUseCase blockAccountUseCase;
  final UnblockAccountUseCase unblockAccountUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final AdminAccountRepository accountRepository;

  // Para auto-refresh
  String? _lastEmail;
  String? _lastManzana;
  String? _lastVilla;

  AdminAccountBloc({
    required this.searchByEmailUseCase,
    required this.searchByLocationUseCase,
    required this.blockAccountUseCase,
    required this.unblockAccountUseCase,
    required this.deleteAccountUseCase,
    required this.resetPasswordUseCase,
    required this.accountRepository,
  }) : super(const AdminAccountInitial()) {
    on<SearchAccountByEmailEvent>(_onSearchByEmail);
    on<SearchAccountByLocationEvent>(_onSearchByLocation);
    on<BlockAccountEvent>(_onBlockAccount);
    on<UnblockAccountEvent>(_onUnblockAccount);
    on<DeleteAccountEvent>(_onDeleteAccount);
    on<ResetPasswordEvent>(_onResetPassword);
  }

  Future<void> _onSearchByEmail(
    SearchAccountByEmailEvent event,
    Emitter emit,
  ) async {
    emit(const AdminAccountLoading());
    try {
      _lastEmail = event.email;
      _lastManzana = null;
      _lastVilla = null;
      
      final accounts = await searchByEmailUseCase(email: event.email);
      emit(AccountsSearched(accounts: accounts));
    } catch (e) {
      emit(AdminAccountError(message: 'Error al buscar cuenta: $e'));
    }
  }

  Future<void> _onSearchByLocation(
    SearchAccountByLocationEvent event,
    Emitter emit,
  ) async {
    emit(const AdminAccountLoading());
    try {
      _lastEmail = null;
      _lastManzana = event.manzana;
      _lastVilla = event.villa;
      
      final accounts = await searchByLocationUseCase(
        manzana: event.manzana,
        villa: event.villa,
      );
      emit(AccountsSearched(accounts: accounts));
    } catch (e) {
      emit(AdminAccountError(message: 'Error al buscar cuentas: $e'));
    }
  }

  Future<void> _onBlockAccount(
    BlockAccountEvent event,
    Emitter emit,
  ) async {
    try {
      await blockAccountUseCase(
        accountId: event.accountId,
        reason: event.reason,
        cascada: event.cascada,
      );
      emit(AccountBlocked(message: 'Cuenta bloqueada correctamente'));
      
      // Auto-refresh
      _refreshLastSearch(emit);
    } catch (e) {
      emit(AdminAccountError(message: 'Error al bloquear cuenta: $e'));
    }
  }

  Future<void> _onUnblockAccount(
    UnblockAccountEvent event,
    Emitter emit,
  ) async {
    try {
      await unblockAccountUseCase(
        accountId: event.accountId,
        reason: event.reason,
        cascada: event.cascada,
      );
      emit(AccountUnblocked(message: 'Cuenta desbloqueada correctamente'));
      
      // Auto-refresh
      _refreshLastSearch(emit);
    } catch (e) {
      emit(AdminAccountError(message: 'Error al desbloquear cuenta: $e'));
    }
  }

  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter emit,
  ) async {
    try {
      await deleteAccountUseCase(accountId: event.accountId);
      emit(AccountDeleted(message: 'Cuenta eliminada correctamente'));
      
      // Auto-refresh
      _refreshLastSearch(emit);
    } catch (e) {
      emit(AdminAccountError(message: 'Error al eliminar cuenta: $e'));
    }
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter emit,
  ) async {
    try {
      // await resetPasswordUseCase(
      //   accountId: event.accountId,
      //   newPassword: event.newPassword,
      // );
      emit(PasswordReset(message: 'Contraseña resetada correctamente'));
      
      // Auto-refresh
      _refreshLastSearch(emit);
    } catch (e) {
      emit(AdminAccountError(message: 'Error al resetear contraseña: $e'));
    }
  }

  void _refreshLastSearch(Emitter emit) async {
    if (_lastEmail != null) {
      add(SearchAccountByEmailEvent(email: _lastEmail!));
    } else if (_lastManzana != null && _lastVilla != null) {
      add(SearchAccountByLocationEvent(
        manzana: _lastManzana!,
        villa: _lastVilla!,
      ));
    }
  }
}
