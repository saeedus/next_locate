import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:next_locate/features/check_in/data/datasources/check_in_remote_data_source.dart';
import 'package:next_locate/features/check_in/data/datasources/check_in_remote_data_source_impl.dart';
import 'package:next_locate/features/check_in/data/repositories/check_in_repository_impl.dart';
import 'package:next_locate/features/check_in/domain/repositories/check_in_repository.dart';
import 'package:next_locate/features/check_in/domain/usecases/create_check_in_point.dart';
import 'package:next_locate/features/check_in/presentation/cubit/create_check_in_point_cubit.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';

final sl = GetIt.instance;

void init() {
  // Cubits
  sl.registerFactory(() => CreateCheckInPointCubit(createCheckInPointUseCase: sl(), geolocatorPlatform: sl()));

  // Use cases
  sl.registerLazySingleton(() => CreateCheckInPointUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<CheckInRepository>(
      () => CheckInRepositoryImpl(remoteDataSource: sl()));

  // Data sources
  sl.registerLazySingleton<CheckInRemoteDataSource>(
      () => CheckInRemoteDataSourceImpl(firestore: sl()));

  // External
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<GeolocatorPlatform>(() => GeolocatorPlatform.instance);
}
