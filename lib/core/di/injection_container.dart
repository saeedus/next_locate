
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';

import 'package:next_locate/features/check_in/data/datasources/check_in_remote_data_source.dart';
import 'package:next_locate/features/check_in/data/datasources/check_in_remote_data_source_impl.dart';
import 'package:next_locate/features/check_in/data/repositories/check_in_repository_impl.dart';
import 'package:next_locate/features/check_in/domain/repositories/check_in_repository.dart';
import 'package:next_locate/features/check_in/domain/usecases/create_check_in_point.dart';
import 'package:next_locate/features/check_in/domain/usecases/get_check_in_points_use_case.dart';
import 'package:next_locate/features/check_in/presentation/cubit/create_check_in_point_cubit.dart';
import 'package:next_locate/features/check_in/presentation/cubit/check_in_points_list_cubit.dart';

import 'package:next_locate/features/user_actions/domain/repositories/user_action_repository.dart';
import 'package:next_locate/features/user_actions/domain/usecases/check_in_user_use_case.dart';
import 'package:next_locate/features/user_actions/domain/usecases/check_out_user_use_case.dart';
import 'package:next_locate/features/user_actions/domain/usecases/get_current_user_check_in_status_use_case.dart';
import 'package:next_locate/features/user_actions/presentation/cubit/user_action_cubit.dart';
// TODO: Import UserActionRepositoryImpl and UserActionRemoteDataSourceImpl once created

final sl = GetIt.instance;

void init() {
  // Cubits
  sl.registerFactory(() => CreateCheckInPointCubit(createCheckInPointUseCase: sl(), geolocatorPlatform: sl()));
  sl.registerFactory(() => CheckInPointsListCubit(getCheckInPointsUseCase: sl()));
  sl.registerFactory(() => UserActionCubit(
        checkInUserUseCase: sl(),
        checkOutUserUseCase: sl(),
        getCurrentUserCheckInStatusUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => CreateCheckInPointUseCase(sl()));
  sl.registerLazySingleton(() => GetCheckInPointsUseCase(sl()));
  sl.registerLazySingleton(() => CheckInUserUseCase(repository: sl(), getCheckInPointsUseCase: sl(), geolocatorPlatform: sl()));
  sl.registerLazySingleton(() => CheckOutUserUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetCurrentUserCheckInStatusUseCase(repository: sl()));

  // Repositories
  sl.registerLazySingleton<CheckInRepository>(
      () => CheckInRepositoryImpl(remoteDataSource: sl()));
  // TODO: Register UserActionRepository once its implementation exists
  // For now, let's register a placeholder if needed for the app to compile,
  // but this will need to be replaced by a real implementation.
  // sl.registerLazySingleton<UserActionRepository>(() => UserActionRepositoryImpl(remoteDataSource: sl()));

  // Data sources
  sl.registerLazySingleton<CheckInRemoteDataSource>(
      () => CheckInRemoteDataSourceImpl(firestore: sl()));
  // TODO: Register UserActionRemoteDataSource once its implementation exists
  // sl.registerLazySingleton<UserActionRemoteDataSource>(() => UserActionRemoteDataSourceImpl(firestore: sl()));

  // External
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<GeolocatorPlatform>(() => GeolocatorPlatform.instance);
}
