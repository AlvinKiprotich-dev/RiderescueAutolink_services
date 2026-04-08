class RequiredDocument {
  final String? id;
  final String serviceType;
  final String documentType;
  final String name;
  final String description;
  final bool required;
  final int order;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RequiredDocument({
    this.id,
    required this.serviceType,
    required this.documentType,
    required this.name,
    required this.description,
    required this.required,
    required this.order,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory RequiredDocument.fromJson(Map<String, dynamic> json) {
    return RequiredDocument(
      id: json['_id'] ?? json['id'],
      serviceType: json['serviceType'] ?? '',
      documentType: json['documentType'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      required: json['required'] ?? false,
      order: json['order'] ?? 0,
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
      'serviceType': serviceType,
      'documentType': documentType,
      'name': name,
      'description': description,
      'required': required,
      'order': order,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class RequiredDocumentResponse {
  final bool success;
  final String message;
  final List<RequiredDocument> documents;
  final Pagination pagination;

  RequiredDocumentResponse({
    required this.success,
    required this.message,
    required this.documents,
    required this.pagination,
  });

  factory RequiredDocumentResponse.fromJson(Map<String, dynamic> json) {
    return RequiredDocumentResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      documents:
          (json['documents'] as List<dynamic>?)
              ?.map((doc) => RequiredDocument.fromJson(doc))
              .toList() ??
          [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'documents': documents.map((doc) => doc.toJson()).toList(),
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
