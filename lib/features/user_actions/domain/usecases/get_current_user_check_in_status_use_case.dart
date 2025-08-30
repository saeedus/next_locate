
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../check_in/domain/entities/check_in_point.dart';
import '../repositories/user_action_repository.dart';

class GetCurrentUserCheckInStatusUseCaseParams {
  final String userId;

  GetCurrentUserCheckInStatusUseCaseParams({required this.userId});
}

class GetCurrentUserCheckInStatusUseCase
    implements UseCase<CheckInPoint?, GetCurrentUserCheckInStatusUseCaseParams> {
  final UserActionRepository repository;

  GetCurrentUserCheckInStatusUseCase({required this.repository});

  @override
  Future<Either<Failure, CheckInPoint?>> call(GetCurrentUserCheckInStatusUseCaseParams params) async {
    return await repository.getCurrentUserCheckInStatus(params.userId);
  }
}
