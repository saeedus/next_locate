import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:next_locate/features/check_in/domain/entities/check_in_point.dart';
import 'package:next_locate/features/check_in/domain/usecases/get_check_in_points_use_case.dart';
import 'package:next_locate/core/errors/failure.dart';
import 'package:next_locate/core/usecases/usecase.dart';

part 'check_in_points_list_state.dart';

class CheckInPointsListCubit extends Cubit<CheckInPointsListState> {
  final GetCheckInPointsUseCase _getCheckInPointsUseCase;

  CheckInPointsListCubit({required GetCheckInPointsUseCase getCheckInPointsUseCase})
      : _getCheckInPointsUseCase = getCheckInPointsUseCase,
        super(CheckInPointsListInitial());

  Future<void> loadCheckInPoints() async {
    emit(CheckInPointsListLoading());
    final failureOrCheckInPoints = await _getCheckInPointsUseCase(NoParams()); 
    failureOrCheckInPoints.fold(
      (failure) => emit(CheckInPointsListFailure(_mapFailureToMessage(failure))),
      (checkInPoints) => emit(CheckInPointsListLoaded(checkInPoints)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return failure.toString();
  }
}
