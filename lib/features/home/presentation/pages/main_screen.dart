import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
import 'package:kalla_u_pro_bengkel/common/app_routes.dart';
import 'package:kalla_u_pro_bengkel/common/image_resources.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/car_item_widget.dart';
import 'package:kalla_u_pro_bengkel/core/util/utils.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  void _navigateToProfile() {
    context.push(AppRoutes.profile);
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
          
          // Vehicle list
          Expanded(
            child: _buildVehicleList(),
          ),
        ],
      ),
      floatingActionButton: Utils.buildFloatingActionButton(onPressed: () async {
        // Add vehicle functionality
        context.push(AppRoutes.addCustomer);
      }),
    );
  }

  Widget _buildVehicleList() {
    // Sample data based on the image
    final vehicles = [
      {'name': 'Dianne Russell', 'plate': 'DE 0616 TA', 'type': 'Zenix', 'year': '2022'},
      {'name': 'Ralph Edwards', 'plate': 'DD 1305 TA', 'type': 'Zenix', 'year': '2022'},
      {'name': 'Devon Lane', 'plate': 'DD 0525 TA', 'type': 'Zenix', 'year': '2022'},
      {'name': 'Esther Howard', 'plate': 'DD 1110 TA', 'type': 'Zenix', 'year': '2022'},
      {'name': 'Arlene McCoy', 'plate': 'DD 1010 TA', 'type': 'Zenix', 'year': '2022'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CarItemWidget(
            name: vehicle['name'] ?? '',
            plate: vehicle['plate'] ?? '',
            type: vehicle['type'] ?? '',
            year: vehicle['year'] ?? '',
            index: index + 1,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Detail kendaraan ${vehicle['plate']}')),
              );
            },
          ),
        );
      },
    );
  }
}