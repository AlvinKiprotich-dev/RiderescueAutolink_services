class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Pagination? pagination;
  final Map<String, dynamic>? filters;
  final Map<String, dynamic>? sort;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.pagination,
    this.filters,
    this.sort,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
      filters: json['filters'] as Map<String, dynamic>?,
      sort: json['sort'] as Map<String, dynamic>?,
    );
  }

  static ApiResponse<List<T>> listFromJson<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponse<List<T>>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
      filters: json['filters'] as Map<String, dynamic>?,
      sort: json['sort'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'pagination': pagination?.toJson(),
      'filters': filters,
      'sort': sort,
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

class ApiError {
  final bool success;
  final String message;
  final List<ApiErrorDetail> errors;

  ApiError({
    required this.success,
    required this.message,
    required this.errors,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      errors:
          (json['errors'] as List<dynamic>?)
              ?.map((error) => ApiErrorDetail.fromJson(error))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'errors': errors.map((error) => error.toJson()).toList(),
    };
  }
}

class ApiErrorDetail {
  final String field;
  final String message;

  ApiErrorDetail({required this.field, required this.message});

  factory ApiErrorDetail.fromJson(Map<String, dynamic> json) {
    return ApiErrorDetail(
      field: json['field'] ?? '',
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'field': field, 'message': message};
  }
}
