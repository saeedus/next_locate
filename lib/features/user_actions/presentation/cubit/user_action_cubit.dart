
import 'dart:async';
import 'dart:math'; // For Random

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

  final String _userId = 'test_user_123';
  Timer? _checkInCountTimer;
  CheckInPoint? _currentActiveCheckInPointForCount;

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
      (failure) {
        emit(UserActionFailure(failure.toString()));
        _cancelCheckInCountTimer();
        _currentActiveCheckInPointForCount = null;
      },
      (checkInPoint) {
        emit(UserActionStatusLoaded(checkInPoint));
        _currentActiveCheckInPointForCount = checkInPoint;
        if (checkInPoint != null) {
          _startOrUpdateCheckInCountFetching(checkInPoint.id);
        } else {
          _cancelCheckInCountTimer();
        }
      },
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
        // Optionally fetch status to reflect potential partial failure or backend state
        fetchCurrentUserStatus(); 
      },
      (message) {
        emit(UserActionSuccess(message));
        // After successful check-in, status will be refreshed, which will then trigger count fetching
        fetchCurrentUserStatus(); 
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
         // Optionally fetch status
        fetchCurrentUserStatus();
      },
      (message) {
        emit(UserActionSuccess(message));
        _cancelCheckInCountTimer(); 
        _currentActiveCheckInPointForCount = null;
        fetchCurrentUserStatus();
      },
    );
  }

  void _startOrUpdateCheckInCountFetching(String checkInPointId) {
    _cancelCheckInCountTimer(); // Cancel any existing timer
    _fetchCheckInCount(checkInPointId); // Fetch immediately
    _checkInCountTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchCheckInCount(checkInPointId);
    });
  }

  Future<void> _fetchCheckInCount(String checkInPointId) async {
    // Only proceed if this is still the active check-in point
    if (_currentActiveCheckInPointForCount?.id != checkInPointId) {
      _cancelCheckInCountTimer();
      return;
    }

    emit(UserActionCheckInCountLoading(checkInPointId));
    try {
      // Simulate network delay and response
      await Future.delayed(const Duration(milliseconds: 750));
      // Simulate fetching count from a backend for the checkInPointId
      // In a real app, this would be an actual API call to your service
      final randomCount = Random().nextInt(100) + 1; // Random count between 1 and 100
      emit(UserActionCheckInCountLoaded(checkInPointId, randomCount));
    } catch (e) {
      emit(UserActionCheckInCountError(checkInPointId, e.toString()));
    }
  }

  void _cancelCheckInCountTimer() {
    _checkInCountTimer?.cancel();
    _checkInCountTimer = null;
  }

  @override
  Future<void> close() {
    _cancelCheckInCountTimer();
    return super.close();
  }
}
