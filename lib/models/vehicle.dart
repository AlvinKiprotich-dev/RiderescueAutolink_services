class Vehicle {
  final String? id;
  final String owner;
  final String? name;
  final String make;
  final String model;
  final int year;
  final String numberPlate;
  final String vin;
  final String color;
  final String type;
  final String status;
  final String? insuranceCompany;
  final DateTime? insurancePolicyExpirationDate;
  final String? photo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Vehicle({
    this.id,
    required this.owner,
    this.name,
    required this.make,
    required this.model,
    required this.year,
    required this.numberPlate,
    required this.vin,
    required this.color,
    required this.type,
    required this.status,
    this.insuranceCompany,
    this.insurancePolicyExpirationDate,
    this.photo,
    this.createdAt,
    this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['_id'] ?? json['id'],
      owner: json['owner'] ?? '',
      name: json['name'],
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      numberPlate: json['numberPlate'] ?? '',
      vin: json['vin'] ?? '',
      color: json['color'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? 'good_condition',
      insuranceCompany: json['insuranceCompany'],
      insurancePolicyExpirationDate:
          json['insurancePolicyExpirationDate'] != null
          ? DateTime.tryParse(json['insurancePolicyExpirationDate'])
          : null,
      photo: json['photo'],
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
      'owner': owner,
      'name': name,
      'make': make,
      'model': model,
      'year': year,
      'numberPlate': numberPlate,
      'vin': vin,
      'color': color,
      'type': type,
      'status': status,
      'insuranceCompany': insuranceCompany,
      'insurancePolicyExpirationDate': insurancePolicyExpirationDate
          ?.toIso8601String(),
      'photo': photo,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class VehicleResponse {
  final bool success;
  final String message;
  final List<Vehicle> vehicles;
  final Pagination pagination;

  VehicleResponse({
    required this.success,
    required this.message,
    required this.vehicles,
    required this.pagination,
  });

  factory VehicleResponse.fromJson(Map<String, dynamic> json) {
    return VehicleResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      vehicles:
          (json['vehicles'] as List<dynamic>?)
              ?.map((vehicle) => Vehicle.fromJson(vehicle))
              .toList() ??
          [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'vehicles': vehicles.map((vehicle) => vehicle.toJson()).toList(),
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
