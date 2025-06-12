import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
import 'package:kalla_u_pro_bengkel/common/image_resources.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_vehicle_type_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/custom_drop_down.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/custom_text_field.dart';

class CustomerIdentityStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  // --- NEW CONTROLLERS & CALLBACK ---
  final TextEditingController frameNumberController;
  final TextEditingController nameController;
  final TextEditingController dobController;
  final TextEditingController whatsappController;
  final VoidCallback onScanBarcode;
  // --- END OF NEW CONTROLLERS & CALLBACK ---
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
    // Add new required parameters
    required this.frameNumberController,
    required this.nameController,
    required this.dobController,
    required this.whatsappController,
    required this.onScanBarcode,
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
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // --- NEW FIELDS AS PER REQUEST ---

          // Nomor Rangka
          _buildSectionTitle('Nomor Rangka'),
          CustomTextField(
            controller: frameNumberController,
            hintText: 'Masukkan Nomor Rangka',
            suffix: InkWell(
              onTap: onScanBarcode,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset(
                  ImageResources.icBarcode, // Assuming you have this asset
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Tombol Cari
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement API call to search for frame number
                print('Searching for frame number: ${frameNumberController.text}');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur pencarian belum diimplementasikan.')),
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  )
              ),
              child: const Text(
                'Cari',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),


          // Nama
          _buildSectionTitle('Nama'),
          CustomTextField(
            controller: nameController,
            hintText: 'Masukkan Nama',
          ),
          const SizedBox(height: 16),

          // Tanggal Lahir
          _buildSectionTitle('Tanggal Lahir'),
          CustomTextField(
            controller: dobController,
            hintText: 'Pilih Tanggal Lahir',
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.primary,
                        onPrimary: Colors.white,
                        onSurface: AppColors.textPrimary,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                dobController.text = formattedDate;
              }
            },
            suffix: const Icon(Icons.calendar_today, color: AppColors.textGrey, size: 20),
          ),
          const SizedBox(height: 16),

          // No. Whatsapp
          _buildSectionTitle('No. Whatsapp'),
          CustomTextField(
            controller: whatsappController,
            hintText: 'Masukkan No. Whatsapp',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          // --- END OF NEW FIELDS ---

          // Nomor Plat
          _buildSectionTitle('Nomor Plat'),
          CustomTextField(
            controller: plateNumberController,
            hintText: 'Masukkan nomor plat',
          ),
          const SizedBox(height: 16),

          // Tipe Kendaraan
          _buildSectionTitle('Tipe Kendaraan'),
          BlocBuilder<GetVehicleTypeCubit, GetVehicleTypeState>(
            builder: (context, state) {
              if (state is GetVehicleTypeLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }
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
              if (state is GetVehicleTypeSuccess) {
                return CustomDropdown(
                  controller: vehicleTypeController,
                  hintText: 'Pilih tipe kendaraan',
                  items: state.vehicleTypes.map((e) => e.name).toList(),
                );
              }
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: CircularProgressIndicator(color: AppColors.primary),
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
          ),
          const SizedBox(height: 16),

          // Alamat
          _buildSectionTitle('Alamat'),
          CustomTextField(
            controller: addressController,
            hintText: 'Masukkan alamat',
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // Asuransi
          _buildSectionTitle('Asuransi'),
          CustomTextField(
            controller: insuranceController,
            hintText: 'Pilih asuransi',
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
