
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/user_action_repository.dart';

class CheckOutUserUseCaseParams {
  final String userId;

  CheckOutUserUseCaseParams({required this.userId});
}

class CheckOutUserUseCase implements UseCase<String, CheckOutUserUseCaseParams> {
  final UserActionRepository repository;

  CheckOutUserUseCase({required this.repository});

  @override
  Future<Either<Failure, String>> call(CheckOutUserUseCaseParams params) async {
    // For now, we assume checkout is always possible if initiated.
    // Future enhancements: Check if user is actually checked-in before allowing checkout.
    return await repository.recordUserCheckOut(params.userId, DateTime.now());
  }
}
