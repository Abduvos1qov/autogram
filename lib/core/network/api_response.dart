import 'package:equatable/equatable.dart';

/// Generic API response wrapper

class ApiResponse<T> extends Equatable {
  final T? data;
  final String? message;
  final bool success;
  final int? statusCode;
  final Map<String, dynamic>? meta;

  const ApiResponse({
    this.data,
    this.message,
    this.success = true,
    this.statusCode,
    this.meta,
  });

  factory ApiResponse.success(T data, {String? message, Map<String, dynamic>? meta}) {
    return ApiResponse(
      data: data,
      message: message,
      success: true,
      meta: meta,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(
      message: message,
      success: false,
      statusCode: statusCode,
    );
  }

  @override
  List<Object?> get props => [data, message, success, statusCode, meta];
}

/// Paginated response wrapper
class PaginatedResponse<T> extends Equatable {
  final List<T> data;
  final int page;
  final int pageSize;
  final int total;
  final bool hasMore;

  const PaginatedResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.hasMore,
  });

  factory PaginatedResponse.fromList(
    List<T> data, {
    required int page,
    required int pageSize,
    int? total,
  }) {
    final calculatedTotal = total ?? data.length;
    return PaginatedResponse(
      data: data,
      page: page,
      pageSize: pageSize,
      total: calculatedTotal,
      hasMore: data.length >= pageSize,
    );
  }

  @override
  List<Object?> get props => [data, page, pageSize, total, hasMore];
}
