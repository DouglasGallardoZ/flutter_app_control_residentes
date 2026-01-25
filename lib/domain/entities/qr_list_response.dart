import '../entities/qr_generado.dart';

class QrListResponse {
  final List<QrGenerado> qrs;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNext;

  QrListResponse({
    required this.qrs,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNext,
  });

  factory QrListResponse.fromJson(Map<String, dynamic> json) {
    return QrListResponse(
      qrs: List<QrGenerado>.from(
        (json['data'] as List).map((e) => QrGenerado.fromJson(e as Map<String, dynamic>)),
      ),
      total: json['total'] as int,
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
      totalPages: json['total_pages'] as int,
      hasNext: json['has_next'] as bool,
    );
  }
}
