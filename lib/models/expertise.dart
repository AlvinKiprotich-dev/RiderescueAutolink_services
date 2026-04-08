class Expertise {
  final String? id;
  final String name;
  final String description;
  final String category;
  final List<String> serviceTypes;
  final num estimatedCost;
  final num estimatedDurationHrs;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Expertise({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.serviceTypes,
    required this.estimatedCost,
    required this.estimatedDurationHrs,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Expertise.fromJson(Map<String, dynamic> json) {
    return Expertise(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      serviceTypes: List<String>.from(json['serviceTypes'] ?? []),
      estimatedCost: json['estimatedCost'] ?? 0,
      estimatedDurationHrs: json['estimatedDurationHrs'] ?? 0,
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
      'name': name,
      'description': description,
      'category': category,
      'serviceTypes': serviceTypes,
      'estimatedCost': estimatedCost,
      'estimatedDurationHrs': estimatedDurationHrs,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class ExpertiseResponse {
  final bool success;
  final String message;
  final List<Expertise> expertise;
  final Pagination pagination;

  ExpertiseResponse({
    required this.success,
    required this.message,
    required this.expertise,
    required this.pagination,
  });

  factory ExpertiseResponse.fromJson(Map<String, dynamic> json) {
    return ExpertiseResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      expertise:
          (json['expertise'] as List<dynamic>?)
              ?.map((exp) => Expertise.fromJson(exp))
              .toList() ??
          [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'expertise': expertise.map((exp) => exp.toJson()).toList(),
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
