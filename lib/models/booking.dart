class Booking {
  final String? id;
  final BookingUser user;
  final BookingService service;
  final BookingVehicle vehicle;
  final List<String> issues;
  final String description;
  final String status;
  final GeoLocation location;
  final DateTime scheduledDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  // Pairing fields
  final bool isPaired;
  final String pairingCode;
  final DateTime? pairedAt;

  Booking({
    this.id,
    required this.user,
    required this.service,
    required this.vehicle,
    required this.issues,
    required this.description,
    required this.status,
    required this.location,
    required this.scheduledDate,
    this.createdAt,
    this.updatedAt,
    this.isPaired = false,
    this.pairingCode = '',
    this.pairedAt,
  });

  factory Booking.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Booking(
        user: BookingUser.fromJson({}),
        service: BookingService.fromJson({}),
        vehicle: BookingVehicle.fromJson({}),
        issues: [],
        description: '',
        status: 'pending',
        location: GeoLocation.fromJson({}),
        scheduledDate: DateTime.now(),
      );
    }

    try {
      return Booking(
        id: json['_id']?.toString() ?? json['id']?.toString(),
        user: BookingUser.fromJson(json['user']),
        service: BookingService.fromJson(json['service']),
        vehicle: BookingVehicle.fromJson(json['vehicle']),
        issues: json['issues'] is List
            ? List<String>.from(
                json['issues'].map((e) => e?.toString() ?? ''),
              )
            : [],
        description: json['description']?.toString() ?? '',
        status: json['status']?.toString() ?? 'pending',
        location: GeoLocation.fromJson(json['location']),
        scheduledDate: json['scheduledDate'] != null
            ? DateTime.tryParse(json['scheduledDate'].toString()) ??
                DateTime.now()
            : DateTime.now(),
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString())
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'].toString())
            : null,
        isPaired: json['isPaired'] == true,
        pairingCode: json['pairingCode']?.toString() ?? '',
        pairedAt: json['pairedAt'] != null
            ? DateTime.tryParse(json['pairedAt'].toString())
            : null,
      );
    } catch (e) {
      // Fallback to safe defaults if parsing fails
      return Booking(
        user: BookingUser.fromJson({}),
        service: BookingService.fromJson({}),
        vehicle: BookingVehicle.fromJson({}),
        issues: [],
        description: '',
        status: 'pending',
        location: GeoLocation.fromJson({}),
        scheduledDate: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'service': service.toJson(),
      'vehicle': vehicle.toJson(),
      'issues': issues,
      'description': description,
      'status': status,
      'location': location.toJson(),
      'scheduledDate': scheduledDate.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isPaired': isPaired,
      'pairingCode': pairingCode,
      'pairedAt': pairedAt?.toIso8601String(),
    };
  }
}

class BookingUser {
  final String id;
  final String name;
  final String email;
  final String phone;

  BookingUser({
    this.id = '',
    this.name = '',
    this.email = '',
    this.phone = '',
  });

  factory BookingUser.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BookingUser();

    try {
      return BookingUser(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
      );
    } catch (e) {
      return BookingUser();
    }
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'phone': phone};
  }
}

class BookingService {
  final String id;
  final String name;
  final String type;
  final String phone;
  final String address;
  final String city;

  BookingService({
    this.id = '',
    this.name = '',
    this.type = '',
    this.phone = '',
    this.address = '',
    this.city = '',
  });

  factory BookingService.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BookingService();

    try {
      return BookingService(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
      );
    } catch (e) {
      return BookingService();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'phone': phone,
      'address': address,
      'city': city,
    };
  }
}

class BookingVehicle {
  final String id;
  final String make;
  final String model;
  final int year;
  final String numberPlate;
  final String color;
  final String type;

  BookingVehicle({
    this.id = '',
    this.make = '',
    this.model = '',
    this.year = 0,
    this.numberPlate = '',
    this.color = '',
    this.type = '',
  });

  factory BookingVehicle.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BookingVehicle();

    try {
      return BookingVehicle(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        make: json['make']?.toString() ?? '',
        model: json['model']?.toString() ?? '',
        year: json['year'] is int
            ? json['year']
            : int.tryParse(json['year']?.toString() ?? '0') ?? 0,
        numberPlate: json['numberPlate']?.toString() ?? '',
        color: json['color']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
      );
    } catch (e) {
      return BookingVehicle();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'numberPlate': numberPlate,
      'color': color,
      'type': type,
    };
  }
}

class BookingResponse {
  final bool success;
  final String message;
  final List<Booking> bookings;
  final Pagination pagination;

  BookingResponse({
    this.success = false,
    this.message = '',
    this.bookings = const [],
    required this.pagination,
  });

  factory BookingResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return BookingResponse(pagination: Pagination());
    }

    try {
      return BookingResponse(
        success: json['success'] == true,
        message: json['message']?.toString() ?? '',
        bookings: json['bookings'] is List
            ? (json['bookings'] as List)
                .map((booking) => Booking.fromJson(booking))
                .toList()
            : [],
        pagination: Pagination.fromJson(json['pagination']),
      );
    } catch (e) {
      return BookingResponse(pagination: Pagination());
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'bookings': bookings.map((booking) => booking.toJson()).toList(),
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
    this.page = 1,
    this.total = 0,
    this.limit = 10,
    this.totalPages = 1,
  });

  factory Pagination.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Pagination();

    try {
      return Pagination(
        page: json['page'] is int
            ? json['page']
            : int.tryParse(json['page']?.toString() ?? '1') ?? 1,
        total: json['total'] is int
            ? json['total']
            : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
        limit: json['limit'] is int
            ? json['limit']
            : int.tryParse(json['limit']?.toString() ?? '10') ?? 10,
        totalPages: json['totalPages'] is int
            ? json['totalPages']
            : int.tryParse(json['totalPages']?.toString() ?? '1') ?? 1,
      );
    } catch (e) {
      return Pagination();
    }
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

  GeoLocation({this.type = 'Point', this.coordinates = const []});

  factory GeoLocation.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GeoLocation();

    try {
      return GeoLocation(
        type: json['type']?.toString() ?? 'Point',
        coordinates: json['coordinates'] is List
            ? (json['coordinates'] as List)
                .map((e) => num.tryParse(e?.toString() ?? '0') ?? 0)
                .toList()
            : [],
      );
    } catch (e) {
      return GeoLocation();
    }
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'coordinates': coordinates};
  }
}
