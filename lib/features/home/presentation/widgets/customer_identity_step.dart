import 'package:flutter/material.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
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
    final vehicleTypes = ['Avanza', 'Calya', 'Innova', 'Rush', 'Veloz', 'Zenix'];
    
    // Sample years for dropdown
    final years = List.generate(10, (index) => (DateTime.now().year - index).toString());
    
    // Sample insurance options
    final insuranceOptions = ['Askrindo', 'ACA', 'Adira', 'Allianz', 'Asuransi Sinar Mas', 'Astra Buana'];

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
          CustomDropdown(
            controller: vehicleTypeController,
            hintText: 'Pilih tipe kendaraan',
            items: vehicleTypes,
            // Removed validator to allow empty selection
          ),
          const SizedBox(height: 16),

          // Tahun Kendaraan
          _buildSectionTitle('Tahun Kendaraan'),
          CustomDropdown(
            controller: vehicleYearController,
            hintText: 'Pilih tahun kendaraan',
            items: years,
            // Removed validator to allow empty selection
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
          CustomDropdown(
            controller: insuranceController,
            hintText: 'Pilih asuransi',
            items: insuranceOptions,
            // Optional field
          ),
          const SizedBox(height: 16),

          // Download M-Toyota
          _buildSectionTitle('Download M-Toyota'),
          Row(
            children: [
              Radio<bool>(
                value: true,
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