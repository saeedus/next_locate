import 'package:dartz/dartz.dart';
import 'package:next_locate/core/errors/failure.dart';
import 'package:next_locate/core/usecases/usecase.dart';
import 'package:next_locate/features/check_in/domain/entities/check_in_point.dart';
import 'package:next_locate/features/check_in/domain/repositories/check_in_repository.dart';

class GetCheckInPointsUseCase implements UseCase<List<CheckInPoint>, NoParams> {
  final CheckInRepository repository;

  GetCheckInPointsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CheckInPoint>>> call(NoParams params) async {
    return await repository.getAllCheckInPoints();
  }
}
