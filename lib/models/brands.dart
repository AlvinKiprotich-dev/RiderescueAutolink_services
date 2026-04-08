class Brand {
  final String? id;
  final String name;
  final String description;
  final String logo;
  final String category;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Brand({
    this.id,
    required this.name,
    required this.description,
    required this.logo,
    required this.category,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      logo: json['logo'] ?? '',
      category: json['category'] ?? '',
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
      'logo': logo,
      'category': category,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class BrandResponse {
  final bool success;
  final String message;
  final List<Brand> brands;
  final Pagination pagination;

  BrandResponse({
    required this.success,
    required this.message,
    required this.brands,
    required this.pagination,
  });

  factory BrandResponse.fromJson(Map<String, dynamic> json) {
    return BrandResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      brands:
          (json['brands'] as List<dynamic>?)
              ?.map((brand) => Brand.fromJson(brand))
              .toList() ??
          [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'brands': brands.map((brand) => brand.toJson()).toList(),
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
