import 'package:dartz/dartz.dart';
import 'package:next_locate/core/errors/failure.dart';
import 'package:next_locate/core/usecases/usecase.dart';
import 'package:next_locate/features/check_in/domain/entities/check_in_point.dart';
import 'package:next_locate/features/check_in/domain/repositories/check_in_repository.dart';

class CreateCheckInPoint implements UseCase<void, CheckInPoint> {
  final CheckInRepository repository;

  CreateCheckInPoint(this.repository);

  @override
  Future<Either<Failure, void>> call(CheckInPoint params) async {
    return await repository.createCheckInPoint(params);
  }
}
