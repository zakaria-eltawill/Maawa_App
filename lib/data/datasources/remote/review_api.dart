import 'package:maawa_project/core/network/dio_client.dart';
import 'package:maawa_project/data/dto/review_dto.dart';

class ReviewApi {
  final DioClient _dioClient;

  ReviewApi(this._dioClient);

  Future<ReviewDto> createReview({
    required String propertyId,
    required int rating,
    String? comment,
  }) async {
    final response = await _dioClient.post(
      '/properties/$propertyId/reviews',
      data: CreateReviewRequestDto(
        rating: rating,
        comment: comment,
      ).toJson(),
    );

    return ReviewDto.fromJson(response.data as Map<String, dynamic>);
  }
}

