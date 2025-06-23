import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
import 'package:kalla_u_pro_bengkel/common/app_routes.dart';
import 'package:kalla_u_pro_bengkel/common/image_resources.dart';
// FIX: Import the now separate and corrected CarItemWidget
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/car_item_widget.dart';
import 'package:kalla_u_pro_bengkel/core/util/utils.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_service_data_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/service_data_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/empty_state_widget.dart';
// FEATURE: Import shimmer package for loading effect.
// Please add `shimmer: ^3.0.0` to your pubspec.yaml dependencies.
import 'package:shimmer/shimmer.dart';

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
                // FEATURE: Show shimmer loading effect
                if (state is GetServiceDataLoading || state is GetServiceDataInitial) {
                  return _buildShimmerList();
                } 
                else if (state is GetServiceDataSuccess) {
                  if (state.serviceData.isEmpty) {
                    // FIX: Implemented robust pull-to-refresh and centering for empty state
                    return RefreshIndicator(
                      onRefresh: _fetchServiceData,
                      color: AppColors.primary,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: constraints.maxHeight),
                              child: const EmptyStateWidget(
                                message: "Tidak ada data layanan yang tersedia saat ini.",
                              ),
                            ),
                          );
                        }
                      ),
                    );
                  } else {
                    return RefreshIndicator(
                      onRefresh: _fetchServiceData,
                      color: AppColors.primary,
                      child: _buildServiceDataList(state.serviceData),
                    );
                  }
                } 
                else if (state is GetServiceDataFailure) {
                   // FIX: Implemented robust pull-to-refresh and centering for error state
                  return RefreshIndicator(
                    onRefresh: _fetchServiceData,
                    color: AppColors.primary,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: EmptyStateWidget(
                              message: "Gagal memuat data: ${state.message}.\nTarik untuk menyegarkan.",
                              imagePath: ImageResources.appIconPng,
                            ),
                          ),
                        );
                      }
                    ),
                  );
                }
                // Fallback case
                return const Center(child: Text("Silakan tarik untuk memuat data."));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Utils.buildFloatingActionButton(onPressed: () async {
        // FIX: Wait for AddCustomerScreen to pop. If it returns true, it means
        // a customer was added, so we should refresh the list.
        final result = await context.push(AppRoutes.addCustomer);
        if (result == true && mounted) {
          _fetchServiceData();
        }
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
          // FIX: Using the single, corrected CarItemWidget
          child: CarItemWidget(
            name: item.owner ?? "",
            plate: item.plateNumber ?? "",
            type: item.type?? "",
            year: item.year?.toString() ?? "",
            index: index + 1,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Detail kendaraan ${item.plateNumber ?? ''}')),
              );
              // TODO: Navigate to detail screen, e.g., context.push('/details', extra: item);
            },
          ),
        );
      },
    );
  }
  
  /// FEATURE: Builds the shimmer loading list.
  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: 6, // Display 6 shimmer items as placeholders
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildShimmerItem(),
          );
        },
      ),
    );
  }

  /// FEATURE: Builds a single shimmer placeholder item that mimics the CarItemWidget layout.
  Widget _buildShimmerItem() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: Colors.white, // Color is handled by Shimmer
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 12.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
