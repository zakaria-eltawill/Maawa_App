import 'package:maawa_project/domain/entities/review.dart';

abstract class ReviewRepository {
  Future<Review> createReview({
    required String propertyId,
    required int rating,
    String? comment,
  });
}

