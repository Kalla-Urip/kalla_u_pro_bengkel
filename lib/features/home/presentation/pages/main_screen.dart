import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
import 'package:kalla_u_pro_bengkel/common/app_routes.dart';
import 'package:kalla_u_pro_bengkel/common/image_resources.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/car_item_widget.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/progress_card_widget.dart';
import 'package:kalla_u_pro_bengkel/util/utils.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToProfile() {
    context.go(AppRoutes.profile);
  }

  void _addNewVehicle() {
    // Navigate to add vehicle screen (not implemented yet)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tambah kendaraan baru')),
    );
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status bar and user icon
               
                const SizedBox(height: 16),
    
                // Logo and user icon row
                Row(
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
                        child:  SvgPicture.asset(
                          ImageResources.icProfile,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Progress text
                const Text(
                  'Progress Hari Ini',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Progress cards
                const Row(
                  children: [
                    Expanded(
                      child: ProgressCardWidget(
                        title: 'Dalam\nAntrian',
                        value: '12',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ProgressCardWidget(
                        title: 'Dalam\nPengerjaan',
                        value: '3',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ProgressCardWidget(
                        title: 'Selesai\nPengerjaan',
                        value: '8',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              indicatorWeight: 3,
              labelPadding: const EdgeInsets.symmetric(vertical: 8,horizontal: 21),
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textGrey,
              tabs: const [
                Center(child: Text('Dalam\nAntrian', textAlign: TextAlign.center)),
                Center(child: Text('Dalam\nPengerjaan', textAlign: TextAlign.center)),
                Center(child: Text('Selesai\nPengerjaan', textAlign: TextAlign.center)),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Dalam Antrian tab
                _buildVehicleListTab(
                  [
                    {'name': 'Syafii Qurani', 'plate': 'DD 1305 TA', 'type': 'Zenix', 'year': '2022'},
                    {'name': 'Syafii Qurani', 'plate': 'DD 1305 TA', 'type': 'Zenix', 'year': '2022'},
                    {'name': 'Syafii Qurani', 'plate': 'DD 1305 TA', 'type': 'Zenix', 'year': '2022'},
                    {'name': 'Syafii Qurani', 'plate': 'DD 1305 TA', 'type': 'Zenix', 'year': '2022'},
                    {'name': 'Syafii Qurani', 'plate': 'DD 1305 TA', 'type': 'Zenix', 'year': '2022'},
                    {'name': 'Syafii Qurani', 'plate': 'DD 1305 TA', 'type': 'Zenix', 'year': '2022'},
                    {'name': 'Syafii Qurani', 'plate': 'DD 1305 TA', 'type': 'Zenix', 'year': '2022'},
                  ],
                ),
                
                // Dalam Pengerjaan tab
                _buildVehicleListTab(
                  [
                    {'name': 'Syafii Qurani', 'plate': 'DD 1305 TA', 'type': 'Zenix', 'year': '2022'},
                    {'name': 'Syafii Qurani', 'plate': 'DD 1305 TA', 'type': 'Zenix', 'year': '2022'},
                    {'name': 'Syafii Qurani', 'plate': 'DD 1305 TA', 'type': 'Zenix', 'year': '2022'},
                  ],
                ),
                
                // Selesai Pengerjaan tab
                _buildVehicleListTab(
                  [
                    {'name': 'Syafii Qurani', 'plate': 'DD 1305 TA', 'type': 'Zenix', 'year': '2022'},
                    {'name': 'Syafii Qurani', 'plate': 'DD 1305 TA', 'type': 'Zenix', 'year': '2022'},
                    {'name': 'Syafii Qurani', 'plate': 'DD 1305 TA', 'type': 'Zenix', 'year': '2022'},
                    {'name': 'Syafii Qurani', 'plate': 'DD 1305 TA', 'type': 'Zenix', 'year': '2022'},
                    {'name': 'Syafii Qurani', 'plate': 'DD 1305 TA', 'type': 'Zenix', 'year': '2022'},
                    {'name': 'Syafii Qurani', 'plate': 'DD 1305 TA', 'type': 'Zenix', 'year': '2022'},
                    {'name': 'Syafii Qurani', 'plate': 'DD 1305 TA', 'type': 'Zenix', 'year': '2022'},
                    {'name': 'Syafii Qurani', 'plate': 'DD 1305 TA', 'type': 'Zenix', 'year': '2022'},
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Utils.buildFloatingActionButton(onPressed: () async{

      })
    );
  }

  Widget _buildVehicleListTab(List<Map<String, String>> vehicles) {
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