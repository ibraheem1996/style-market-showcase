// Package imports:
import 'package:dartz/dartz.dart';

// Project imports:
import 'failure.dart';

typedef ApiResult<T> = Either<Failure, T>;
