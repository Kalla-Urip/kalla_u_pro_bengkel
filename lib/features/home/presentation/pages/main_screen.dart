import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import bloc
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
import 'package:kalla_u_pro_bengkel/common/app_routes.dart';
import 'package:kalla_u_pro_bengkel/common/image_resources.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/car_item_widget.dart';
import 'package:kalla_u_pro_bengkel/core/util/utils.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_service_data_cubit.dart'; // Import cubit
import 'package:kalla_u_pro_bengkel/features/home/data/models/service_data_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/empty_state_widget.dart'; // Import model

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger initial data fetch when the screen loads
    _fetchServiceData();
  }

  void _navigateToProfile() {
    context.push(AppRoutes.profile);
  }

  Future<void> _fetchServiceData() async {
    // Call the cubit to fetch service data
    context.read<GetServiceDataCubit>().fetchServiceData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Top section with primary color background
          Container(
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
            color: AppColors.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo
                Image.asset(
                  ImageResources.kallaToyotaLogoWhitepng,
                  height: 30,
                ),
                // User profile icon
                GestureDetector(
                  onTap: _navigateToProfile,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      ImageResources.icProfile,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Vehicle list section using BlocConsumer
          Expanded(
            child: BlocConsumer<GetServiceDataCubit, GetServiceDataState>(
              listener: (context, state) {
                if (state is GetServiceDataFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${state.message}')),
                  );
                }
              },
              builder: (context, state) {
                if (state is GetServiceDataLoading) {
                  return const Center(child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ));
                } else if (state is GetServiceDataSuccess) {
                  if (state.serviceData.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _fetchServiceData,
                      color: AppColors.primary,
                      child: const SingleChildScrollView( // Wrap with SingleChildScrollView for pull-to-refresh on empty state
                        physics: AlwaysScrollableScrollPhysics(),
                        child: EmptyStateWidget(
                          message: "Tidak ada data layanan yang tersedia saat ini.",
                        ),
                      ),
                    );
                  } else {
                    return RefreshIndicator(
                      onRefresh: _fetchServiceData,
                      color: AppColors.primary,
                      child: _buildServiceDataList(state.serviceData),
                    );
                  }
                } else if (state is GetServiceDataFailure) {
                  return RefreshIndicator(
                    onRefresh: _fetchServiceData,
                    color: AppColors.primary,
                    child: SingleChildScrollView( // Wrap with SingleChildScrollView for pull-to-refresh on error state
                      physics: AlwaysScrollableScrollPhysics(),
                      child: EmptyStateWidget(
                        message: "Gagal memuat data: ${state.message}. Tarik untuk menyegarkan.",
                        imagePath: ImageResources.appIconPng, // You can use a different error image
                      ),
                    ),
                  );
                }
                // Initial state or unhandled states
                return RefreshIndicator(
                  onRefresh: _fetchServiceData,
                  color: AppColors.primary,
                  child: const SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: EmptyStateWidget(
                      message: "Tarik untuk memuat data layanan.",
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Utils.buildFloatingActionButton(onPressed: () async {
        // Add vehicle functionality
        context.push(AppRoutes.addCustomer);
      }),
    );
  }

  Widget _buildServiceDataList(List<ServiceDataModel> serviceData) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: serviceData.length,
      itemBuilder: (context, index) {
        final item = serviceData[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CarItemWidget(
            // Safely accessing nullable properties with null-aware operator ?? ''
            name: item.owner ?? '',
            plate: item.plateNumber ?? '',
            type: item.type ?? '',
            year: (item.year ?? '').toString(), // Year can be int?, convert to string safely
            index: index + 1,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Detail kendaraan ${item.plateNumber ?? ''}')),
              );
            },
          ),
        );
      },
    );
  }
}

// Separate CarItemWidget definition
class CarItemWidget extends StatelessWidget {
  // Made properties nullable to match ServiceDataModel
  final String? name;
  final String? plate;
  final String? type;
  final String? year;
  final int index;
  final VoidCallback onTap;

  const CarItemWidget({
    super.key,
    this.name, // Now nullable
    this.plate, // Now nullable
    this.type,  // Now nullable
    this.year,  // Now nullable
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Orange left accent
            Container(
              width: 4,
              decoration: const BoxDecoration(
                color: AppColors.orange,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Car details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Baris pertama dengan nomor, nama, dan plat
                          Row(
                            children: [
                              Text(
                                "${index.toString()}. ",
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          name ?? 'N/A', // Use N/A if name is null
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            plate ?? 'N/A', // Use N/A if plate is null
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Baris kedua dengan type dan year
                          Row(
                            children: [
                              // Spasi untuk menyelaraskan dengan nama (setelah nomor)
                              const SizedBox(width: 14),

                              // Type dan year dengan width yang sama dengan nama dan plat
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${type ?? 'N/A'} - ${year ?? 'N/A'}', // Use N/A if type or year is null
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    // Di sini kita memberi spacer untuk mendorong teks ke kiri
                                    // jadi akan sejajar dengan name
                                    const SizedBox(width: 100),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Detail icon
                    GestureDetector(
                      onTap: onTap,
                      child: SvgPicture.asset(
                        "assets/icons/ic_arrow.svg",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
