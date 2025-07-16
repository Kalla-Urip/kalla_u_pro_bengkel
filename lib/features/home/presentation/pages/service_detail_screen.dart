import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
import 'package:kalla_u_pro_bengkel/common/app_text_styles.dart';
import 'package:kalla_u_pro_bengkel/common/image_resources.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/service_detail_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_service_detail_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/empty_state_widget.dart';

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;
  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    _fetchServiceDetail();
  }

  /// Triggers the cubit to fetch service detail data.
  Future<void> _fetchServiceDetail() async {
    context.read<GetServiceDetailCubit>().fetchServiceDetail(widget.serviceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: AppColors.primary,
      //   title: const Text('Detail Riwayat Service', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: Colors.white),
      //     onPressed: () => context.pop(),
      //   ),
      //   elevation: 0,
      // ),
      appBar: AppBar(
          backgroundColor: AppColors.primary,
          leadingWidth: 21,
          title: const Text('Detail Riwayat Service', style: AppTextStyles.subtitle2),
          leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
        ),
      body: BlocBuilder<GetServiceDetailCubit, GetServiceDetailState>(
        builder: (context, state) {
          // Loading State
          if (state is GetServiceDetailLoading && state is! GetServiceDetailSuccess) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          // Success State
          if (state is GetServiceDetailSuccess) {
            // FIX: Wrap content with RefreshIndicator for swipe-to-refresh.
            return RefreshIndicator(
              onRefresh: _fetchServiceDetail,
              color: AppColors.primary,
              child: _buildDetailContent(state.serviceDetail),
            );
          }

          // Failure State
          if (state is GetServiceDetailFailure) {
            // FIX: Implement robust pull-to-refresh and centering for the error state.
            return RefreshIndicator(
              onRefresh: _fetchServiceDetail,
              color: AppColors.primary,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      // FIX: Use EmptyStateWidget for a consistent error message display.
                      child: EmptyStateWidget(
                        message: "Gagal memuat data: ${state.message}.\nTarik untuk menyegarkan.",
                        imagePath: ImageResources.appIconPng,
                      ),
                    ),
                  );
                },
              ),
            );
          }

          // Initial or other unhandled states
          return const Center(child: Text('Tidak ada data.'));
        },
      ),
    );
  }

  /// Builds the main content view when data is successfully loaded.
  Widget _buildDetailContent(ServiceDetailModel detail) {
    // FIX: Ensure the list is always scrollable to allow RefreshIndicator to work.
    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          color: AppColors.grey100,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard('Identitas', [
                _buildTwoColumnRow('Nama', detail.name ?? '-'),
                _buildTwoColumnRow('Tanggal Lahir', _formatDate(detail.birthDate) ?? '-'),
                _buildTwoColumnRow('Asuransi', detail.insurance ?? '-'),
              ]),
              _buildSectionCard('Kondisi Ruang Mesin', [
                _buildTwoColumnRow('Kondisi Ruang Mesin', detail.engineRoomCondition ?? '-'),
              ]),
              _buildSectionCard('Kondisi Karpet', [
                _buildTwoColumnRow('Karpet Dasar', detail.carpetCondition?.base ?? '-'),
                _buildTwoColumnRow('Karpet Pengemudi', detail.carpetCondition?.driver ?? '-'),
              ]),
              _buildSectionCard('Kondisi Ketebalan Ban', [
                _buildTwoColumnRow('FR LH', detail.tireThicknessCondtion?.frLh ?? '-', 'FR RH', detail.tireThicknessCondtion?.frRh ?? '-'),
                _buildTwoColumnRow('RR LH', detail.tireThicknessCondtion?.rrLh ?? '-', 'RR RH', detail.tireThicknessCondtion?.rrRh ?? '-'),
              ]),
              _buildSectionCard('Kondisi Baterai', [
                 _buildTwoColumnRow('Kondisi Baterai', detail.batteraiCondition ?? '-'),
              ]),
              _buildSectionCard('BBM & Kilometer', [
                _buildTwoColumnRow('Total BBM (Persentase)', '${detail.fuelTotal ?? '0'}%'),
                _buildTwoColumnRow('Kilometer', detail.kilometer?.toString() ?? '-'),
              ]),
              _buildSectionCard('Kondisi Body', [
                 _buildTwoColumnRow('KAP MESIN', detail.bodyCondition?.kapMesin ?? '-', 'ATAP MOBIL', detail.bodyCondition?.atapMobil ?? '-'),
                 _buildTwoColumnRow('SPION KIRI', detail.bodyCondition?.spionKiri ?? '-', 'SPION KANAN', detail.bodyCondition?.spionKanan ?? '-'),
                 _buildTwoColumnRow('BUMPER DEPAN', detail.bodyCondition?.bumperDepan ?? '-', 'BUMPER BELAKANG', detail.bodyCondition?.bumperBelakang ?? '-'),
                 _buildTwoColumnRow('PINTU DEPAN KIRI', detail.bodyCondition?.pintuDepanKiri ?? '-', 'FENDER DEPAN KIRI', detail.bodyCondition?.fenderDepanKiri ?? '-'),
                 _buildTwoColumnRow('PINTU DEPAN KANAN', detail.bodyCondition?.pintuDepanKanan ?? '-', 'FENDER DEPAN KANAN', detail.bodyCondition?.fenderDepanKanan ?? '-'),
                 _buildTwoColumnRow('PINTU BELAKANG KIRI', detail.bodyCondition?.pintuBelakangKiri ?? '-', 'PINTU BELAKANG KANAN', detail.bodyCondition?.pintuBelakangKanan ?? '-'),
                 _buildTwoColumnRow('FENDER BELAKANG KANAN', detail.bodyCondition?.fenderBelakangKanan ?? '-'),
              ]),
               _buildSectionCard('Catatan & Lainnya', [
                _buildTwoColumnRow('Jenis Service', detail.serviceType ?? '-', 'Nama Petugas', '-'), // Nama Petugas not in JSON
                _buildTwoColumnRow('Catatan', detail.note ?? '-', 'Trade In', detail.tradeIn == true ? 'Ya' : 'Tidak'),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a styled card for each section of the details.
  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Divider(),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Builds a row that can contain one or two columns of label-value pairs.
  Widget _buildTwoColumnRow(String label1, String value1, [String? label2, String? value2]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildLabelValue(label1, value1),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: label2 != null && value2 != null
                ? _buildLabelValue(label2, value2)
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  /// Builds a single label-value widget.
  Widget _buildLabelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ],
    );
  }

  /// Formats a date string into a more readable format.
  String? _formatDate(String? dateString) {
    if (dateString == null) return null;
    try {
      final inputFormat = DateFormat('dd-MM-yyyy');
      final date = inputFormat.parse(dateString);
      final outputFormat = DateFormat('dd MMMM yyyy', 'id_ID');
      return outputFormat.format(date);
    } catch (e) {
      return dateString;
    }
  }
}
