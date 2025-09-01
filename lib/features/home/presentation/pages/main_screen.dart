import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
import 'package:kalla_u_pro_bengkel/common/app_routes.dart';
import 'package:kalla_u_pro_bengkel/common/image_resources.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/car_item_widget.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/input_method_selection_dialog.dart';
import 'package:kalla_u_pro_bengkel/core/util/utils.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_service_data_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/service_data_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/empty_state_widget.dart';
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
    _fetchServiceData();
  }

  void _navigateToProfile() {
    context.push(AppRoutes.profile);
  }

  Future<void> _fetchServiceData() async {
    context.read<GetServiceDataCubit>().fetchServiceData();
  }

  void _showInputMethodDialog() {
    showDialog(
      context: context,
      builder: (context) => InputMethodSelectionDialog(
        onManualMethod: () async {
          final result = await context.push(AppRoutes.addCustomer);
          if (result == true && mounted) {
            _fetchServiceData();
          }
        },
        onAiMethod: () async {
          final result = await context.push(AppRoutes.webviewWac);
          if (result == true && mounted) {
            _fetchServiceData();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
            color: AppColors.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  ImageResources.kallaToyotaLogoWhitepng,
                  height: 30,
                ),
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
                if (state is GetServiceDataLoading || state is GetServiceDataInitial) {
                  return _buildShimmerList();
                } else if (state is GetServiceDataSuccess) {
                  if (state.serviceData.isEmpty) {
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
                        },
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
                      },
                    ),
                  );
                }
                return const Center(child: Text("Silakan tarik untuk memuat data."));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Utils.buildFloatingActionButton(onPressed: () async {
        _showInputMethodDialog();
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
            name: item.owner ?? "",
            plate: item.plateNumber ?? "",
            type: item.type ?? "",
            year: item.year?.toString() ?? "",
            index: index + 1,
            onTap: () {
              // FIX: Navigate to detail screen with the service ID
              if (item.id != null) {
                context.push('${AppRoutes.serviceDetail}/${item.id}');
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ID layanan tidak tersedia.')),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildShimmerItem(),
          );
        },
      ),
    );
  }

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
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
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
