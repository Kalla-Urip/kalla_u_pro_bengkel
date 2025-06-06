import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_vehicle_type_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/custom_drop_down.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/custom_text_field.dart';

class CustomerIdentityStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController plateNumberController;
  final TextEditingController vehicleTypeController;
  final TextEditingController vehicleYearController;
  final TextEditingController addressController;
  final TextEditingController insuranceController;
  final bool hasMToyotaApp;
  final ValueChanged<bool?> onMToyotaAppChanged;

  const CustomerIdentityStep({
    super.key,
    required this.formKey,
    required this.plateNumberController,
    required this.vehicleTypeController,
    required this.vehicleYearController,
    required this.addressController,
    required this.insuranceController,
    required this.hasMToyotaApp,
    required this.onMToyotaAppChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Sample vehicle types for dropdown
    final vehicleTypes = [
      'Avanza',
      'Calya',
      'Innova',
      'Rush',
      'Veloz',
      'Zenix'
    ];

    // Sample years for dropdown
    final years =
        List.generate(10, (index) => (DateTime.now().year - index).toString());

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // Nomor Plat
          _buildSectionTitle('Nomor Plat'),
          CustomTextField(
            controller: plateNumberController,
            hintText: 'Masukkan nomor plat',
            // Removed validator to allow empty fields
          ),
          const SizedBox(height: 16),

          // Tipe Kendaraan
          _buildSectionTitle('Tipe Kendaraan'),
          BlocBuilder<GetVehicleTypeCubit, GetVehicleTypeState>(
            builder: (context, state) {
              // --- 1. Loading State ---
              if (state is GetVehicleTypeLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                );
              }
              // --- 2. Failure State ---
              if (state is GetVehicleTypeFailure) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.red.withOpacity(0.05),
                  ),
                  child: Column(
                    children: [
                      Text(state.message, textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade800)),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () {
                          context.read<GetVehicleTypeCubit>().fetchVehicleTypes();
                        },
                        child: const Text('Coba Lagi', style: TextStyle(color: AppColors.primary)),
                      ),
                    ],
                  ),
                );
              }
              // --- 3. Success State ---
              if (state is GetVehicleTypeSuccess) {
                return CustomDropdown(
                  controller: vehicleTypeController,
                  hintText: 'Pilih tipe kendaraan',
                  items: state.vehicleTypes.map((e) => e.name).toList(),
                );
              }
              // --- 4. Initial State (Fallback) ---
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Tahun Kendaraan
          _buildSectionTitle('Tahun Kendaraan'),
          CustomTextField(
            controller: vehicleYearController,
            hintText: 'Masukkan tahun kendaraan',
            keyboardType: TextInputType.number,
            // Input formatter to allow only digits
            // Note: You'll need to add this parameter to your CustomTextField widget
          ),
          const SizedBox(height: 16),

          // Alamat
          _buildSectionTitle('Alamat'),
          CustomTextField(
            controller: addressController,
            hintText: 'Masukkan alamat',
            maxLines: 2,
            // Removed validator to allow empty fields
          ),
          const SizedBox(height: 16),

          // Asuransi
          _buildSectionTitle('Asuransi'),
          CustomTextField(
            controller: insuranceController,
            hintText: 'Pilih asuransi',
            // Optional field
          ),
          const SizedBox(height: 16),

          // Download M-Toyota
          _buildSectionTitle('Download M-Toyota'),
          Row(
            children: [
              Radio<bool>(
                value: true,
                visualDensity: const VisualDensity(
                  horizontal: VisualDensity.minimumDensity,
                  vertical: VisualDensity.minimumDensity,
                ),
                groupValue: hasMToyotaApp,
                onChanged: onMToyotaAppChanged,
                activeColor: AppColors.primary,
              ),
              const Text('Sudah'),
              const SizedBox(width: 24),
              Radio<bool>(
                value: false,
                groupValue: hasMToyotaApp,
                onChanged: onMToyotaAppChanged,
                activeColor: AppColors.primary,
                visualDensity: const VisualDensity(
                  horizontal: VisualDensity.minimumDensity,
                  vertical: VisualDensity.minimumDensity,
                ),
              ),
              const Text('Belum'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
