import 'package:maawa_project/core/error/error_handler.dart';
import 'package:maawa_project/data/datasources/remote/review_api.dart';
import 'package:maawa_project/domain/entities/review.dart';
import 'package:maawa_project/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewApi _reviewApi;

  ReviewRepositoryImpl(this._reviewApi);

  @override
  Future<Review> createReview({
    required String propertyId,
    required int rating,
    String? comment,
  }) async {
    try {
      final dto = await _reviewApi.createReview(
        propertyId: propertyId,
        rating: rating,
        comment: comment,
      );
      return dto.toDomain();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }
}

