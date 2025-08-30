
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../check_in/domain/entities/check_in_point.dart';
import '../../domain/usecases/check_in_user_use_case.dart';
import '../../domain/usecases/check_out_user_use_case.dart';
import '../../domain/usecases/get_current_user_check_in_status_use_case.dart';
import 'user_action_state.dart';

class UserActionCubit extends Cubit<UserActionState> {
  final CheckInUserUseCase _checkInUserUseCase;
  final CheckOutUserUseCase _checkOutUserUseCase;
  final GetCurrentUserCheckInStatusUseCase _getCurrentUserCheckInStatusUseCase;

  // Assume a fixed userId for now. In a real app, this would come from an auth service.
  final String _userId = 'test_user_123';

  UserActionCubit({
    required CheckInUserUseCase checkInUserUseCase,
    required CheckOutUserUseCase checkOutUserUseCase,
    required GetCurrentUserCheckInStatusUseCase getCurrentUserCheckInStatusUseCase,
  })  : _checkInUserUseCase = checkInUserUseCase,
        _checkOutUserUseCase = checkOutUserUseCase,
        _getCurrentUserCheckInStatusUseCase = getCurrentUserCheckInStatusUseCase,
        super(UserActionInitial());

  Future<void> fetchCurrentUserStatus() async {
    emit(UserActionStatusLoading());
    final result = await _getCurrentUserCheckInStatusUseCase(
      GetCurrentUserCheckInStatusUseCaseParams(userId: _userId),
    );
    result.fold(
      (failure) => emit(UserActionFailure(failure.toString())),
      (checkInPoint) => emit(UserActionStatusLoaded(checkInPoint)),
    );
  }

  Future<void> userCheckIn() async {
    emit(UserActionInProgress());
    final result = await _checkInUserUseCase(
      CheckInUserUseCaseParams(userId: _userId),
    );
    result.fold(
      (failure) {
        emit(UserActionFailure(failure.toString()));
        fetchCurrentUserStatus(); // Refresh status even on failure
      },
      (message) {
        emit(UserActionSuccess(message));
        fetchCurrentUserStatus(); // Refresh status on success
      },
    );
  }

  Future<void> userCheckOut() async {
    emit(UserActionInProgress());
    final result = await _checkOutUserUseCase(
      CheckOutUserUseCaseParams(userId: _userId),
    );
    result.fold(
      (failure) {
        emit(UserActionFailure(failure.toString()));
        fetchCurrentUserStatus(); // Refresh status even on failure
      },
      (message) {
        emit(UserActionSuccess(message));
        fetchCurrentUserStatus(); // Refresh status on success
      },
    );
  }
}
