import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/saved_item.dart';

/// Saved repository interface

abstract class SavedRepository {
  Future<Either<Failure, List<SavedItem>>> getSavedItems();
  Future<Either<Failure, void>> removeFromSaved(String listingId);
  Future<Either<Failure, void>> clearAllSaved();
}
