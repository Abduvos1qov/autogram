import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/mixins/repository_mixin.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/saved_item.dart';
import '../../domain/repositories/saved_repository.dart';
import '../datasources/saved_remote_datasource.dart';

class SavedRepositoryImpl with RepositoryMixin implements SavedRepository {
  final SavedRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  SavedRepositoryImpl({
    required SavedRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<SavedItem>>> getSavedItems() {
    return safeRemoteCall(_networkInfo, () async {
      return await _remoteDataSource.getSavedItems();
    });
  }

  @override
  Future<Either<Failure, void>> removeFromSaved(String listingId) {
    return safeRemoteCall(_networkInfo, () async {
      await _remoteDataSource.removeFromSaved(listingId);
    });
  }

  @override
  Future<Either<Failure, void>> clearAllSaved() {
    return safeRemoteCall(_networkInfo, () async {
      await _remoteDataSource.clearAllSaved();
    });
  }
}
