import 'package:maawa_project/domain/entities/review.dart';
import 'package:maawa_project/domain/repositories/review_repository.dart';

class PostReviewUseCase {
  final ReviewRepository _repository;

  PostReviewUseCase(this._repository);

  Future<Review> call({
    required String propertyId,
    required int rating,
    String? comment,
  }) async {
    return await _repository.createReview(
      propertyId: propertyId,
      rating: rating,
      comment: comment,
    );
  }
}

