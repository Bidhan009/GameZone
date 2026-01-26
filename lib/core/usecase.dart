import 'package:dartz/dartz.dart';
import 'package:gamezone_flutter/core/error/failure.dart';

abstract interface class UsecaseWithParams<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}// return type and paramter is passed 


abstract interface class UsecaseWithoutParams<SuccessType> {
  Future<Either<Failure, SuccessType>> call();
}