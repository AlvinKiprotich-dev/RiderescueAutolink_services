class Review {
  final String? id;
  final String service;
  final String user;
  final int rating;
  final String comment;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Review({
    this.id,
    required this.service,
    required this.user,
    required this.rating,
    required this.comment,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? json['id'],
      service: json['service'] ?? '',
      user: json['user'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service': service,
      'user': user,
      'rating': rating,
      'comment': comment,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class ReviewResponse {
  final bool success;
  final String message;
  final List<Review> reviews;
  final Pagination pagination;

  ReviewResponse({
    required this.success,
    required this.message,
    required this.reviews,
    required this.pagination,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      reviews:
          (json['reviews'] as List<dynamic>?)
              ?.map((review) => Review.fromJson(review))
              .toList() ??
          [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'reviews': reviews.map((review) => review.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class Pagination {
  final int page;
  final int total;
  final int limit;
  final int totalPages;

  Pagination({
    required this.page,
    required this.total,
    required this.limit,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] ?? 1,
      total: json['total'] ?? 0,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'total': total,
      'limit': limit,
      'totalPages': totalPages,
    };
  }
}
