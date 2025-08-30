import 'package:dartz/dartz.dart';
import 'package:next_locate/core/errors/failure.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
