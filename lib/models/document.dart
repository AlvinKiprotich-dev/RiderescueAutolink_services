class Document {
  final String? id;
  final String type;
  final String name;
  final String url;
  final String service;
  final String document;
  final bool verified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Document({
    this.id,
    required this.type,
    required this.name,
    required this.url,
    required this.service,
    required this.document,
    required this.verified,
    this.createdAt,
    this.updatedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['_id'] ?? json['id'],
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      service: json['service'] ?? '',
      document: json['document'] ?? '',
      verified: json['verified'] ?? false,
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
      'name': name,
      'url': url,
      'service': service,
      'document': document,
      'verified': verified,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class RequiredDocument {
  final String? id;
  final String serviceType;
  final String documentType;
  final String name;
  final String description;
  final bool required;
  final int order;

  RequiredDocument({
    this.id,
    required this.serviceType,
    required this.documentType,
    required this.name,
    required this.description,
    required this.required,
    required this.order,
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
    };
  }
}

class DocumentResponse {
  final bool success;
  final String message;
  final List<Document> documents;
  final List<RequiredDocument> requiredDocuments;
  final Pagination pagination;
  final Map<String, dynamic> filters;
  final Map<String, dynamic> sort;

  DocumentResponse({
    required this.success,
    required this.message,
    required this.documents,
    required this.requiredDocuments,
    required this.pagination,
    required this.filters,
    required this.sort,
  });

  factory DocumentResponse.fromJson(Map<String, dynamic> json) {
    return DocumentResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      documents:
          (json['documents'] as List<dynamic>?)
              ?.map((doc) => Document.fromJson(doc))
              .toList() ??
          [],
      requiredDocuments:
          (json['requiredDocuments'] as List<dynamic>?)
              ?.map((reqDoc) => RequiredDocument.fromJson(reqDoc))
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
      'documents': documents.map((doc) => doc.toJson()).toList(),
      'requiredDocuments': requiredDocuments
          .map((reqDoc) => reqDoc.toJson())
          .toList(),
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
