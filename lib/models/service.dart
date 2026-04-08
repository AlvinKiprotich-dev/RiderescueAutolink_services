class Service {
  final String? id;
  final String type;
  final bool isAvailable;
  final String status;
  final String name;
  final String about;
  final String photo;
  final String phone;
  final String? email;
  final String address;
  final String city;
  final String country;
  final GeoLocation geoLocation;
  final List<String> brandOfExpertise;
  final List<String> areaOfExpertise;
  final num rating;
  final int reviewCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Service({
    this.id,
    required this.type,
    required this.isAvailable,
    required this.status,
    required this.name,
    required this.about,
    required this.photo,
    required this.phone,
    this.email,
    required this.address,
    required this.city,
    required this.country,
    required this.geoLocation,
    required this.brandOfExpertise,
    required this.areaOfExpertise,
    required this.rating,
    required this.reviewCount,
    this.createdAt,
    this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id'] ?? json['id'],
      type: json['type'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      status: json['status'] ?? 'pending',
      name: json['name'] ?? '',
      about: json['about'] ?? '',
      photo: json['photo'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      geoLocation: GeoLocation.fromJson(json['geoLocation'] ?? {}),
      brandOfExpertise: List<String>.from(json['brandOfExpertise'] ?? []),
      areaOfExpertise: List<String>.from(json['areaOfExpertise'] ?? []),
      rating: json['rating'] ?? 0,
      reviewCount: json['reviewCount'] ?? 0,
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
      'type': type,
      'isAvailable': isAvailable,
      'status': status,
      'name': name,
      'about': about,
      'photo': photo,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'country': country,
      'geoLocation': geoLocation.toJson(),
      'brandOfExpertise': brandOfExpertise,
      'areaOfExpertise': areaOfExpertise,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}


class ServiceResponse {
  final bool success;
  final String message;
  final List<Service> services;
  final Pagination pagination;
  final Map<String, dynamic> filters;
  final Map<String, dynamic> sort;

  ServiceResponse({
    required this.success,
    required this.message,
    required this.services,
    required this.pagination,
    required this.filters,
    required this.sort,
  });

  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    return ServiceResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      services:
          (json['services'] as List<dynamic>?)
              ?.map((service) => Service.fromJson(service))
              .toList() ??
          [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
      filters: json['filters'] ?? {},
      sort: json['sort'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'services': services.map((service) => service.toJson()).toList(),
      'pagination': pagination.toJson(),
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

class GeoLocation {
  final String type;
  final List<num> coordinates;

  GeoLocation({required this.type, required this.coordinates});

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      type: json['type'] ?? 'Point',
      coordinates: List<num>.from(json['coordinates'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'coordinates': coordinates};
  }
}
