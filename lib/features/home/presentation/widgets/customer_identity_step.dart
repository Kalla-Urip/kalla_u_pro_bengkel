import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
import 'package:kalla_u_pro_bengkel/common/image_resources.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_customer_by_chasis_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_vehicle_type_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/custom_drop_down.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/custom_text_field.dart';

class CustomerIdentityStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController frameNumberController;
  final TextEditingController nameController;
  final TextEditingController dobController;
  final TextEditingController whatsappController;
  final VoidCallback onScanBarcode;
  final VoidCallback onSearchChassis;
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
    required this.frameNumberController,
    required this.nameController,
    required this.dobController,
    required this.whatsappController,
    required this.onScanBarcode,
    required this.onSearchChassis,
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
          _buildSectionTitle('Nomor Rangka'),
          CustomTextField(
            controller: frameNumberController,
            hintText: 'Masukkan atau pindai nomor rangka',
            validator: (value) => (value?.isEmpty ?? true) ? 'Nomor rangka wajib diisi' : null,
            suffix: InkWell(
              onTap: onScanBarcode,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset(ImageResources.icBarcode),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: BlocBuilder<GetCustomerByChassisCubit, GetCustomerByChassisState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state is GetCustomerByChassisLoading ? null : onSearchChassis,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      )),
                  child: state is GetCustomerByChassisLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Cari',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('Nama'),
          CustomTextField(
            controller: nameController,
            hintText: 'Masukkan nama customer',
            validator: (value) => (value?.isEmpty ?? true) ? 'Nama wajib diisi' : null,
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('Tanggal Lahir (Opsional)'),
          CustomTextField(
            controller: dobController,
            hintText: 'Pilih tanggal lahir',
            readOnly: true,
            validator: (value) => null, // Made optional
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1920),
                lastDate: DateTime.now(),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(primary: AppColors.primary),
                  ),
                  child: child!,
                ),
              );
              if (pickedDate != null) {
                dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
              }
            },
            suffix: const Icon(Icons.calendar_today, color: AppColors.textGrey, size: 20),
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('No. Whatsapp'),
          CustomTextField(
            controller: whatsappController,
            hintText: 'Contoh: 08123456789',
            keyboardType: TextInputType.number,
            validator: (value) => (value?.isEmpty ?? true) ? 'No. Whatsapp wajib diisi' : null,
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('Nomor Plat'),
          CustomTextField(
            controller: plateNumberController,
            hintText: 'Masukkan nomor plat kendaraan',
            validator: (value) => (value?.isEmpty ?? true) ? 'Nomor plat wajib diisi' : null,
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('Tipe Kendaraan'),
          BlocBuilder<GetVehicleTypeCubit, GetVehicleTypeState>(
            builder: (context, state) {
              if (state is GetVehicleTypeSuccess) {
                return CustomDropdown(
                  controller: vehicleTypeController,
                  hintText: 'Pilih tipe kendaraan',
                  items: Map.fromEntries(
                    state.vehicleTypes.map(
                      (tipe) => MapEntry(tipe.name ?? 'Unknown', tipe.id?.toString() ?? ''),
                    ),
                  ),
                  validator: (value) => (value?.isEmpty ?? true) ? 'Tipe kendaraan wajib dipilih' : null,
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
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            },
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('Tahun Kendaraan'),
          CustomTextField(
            controller: vehicleYearController,
            hintText: 'Masukkan tahun kendaraan',
            keyboardType: TextInputType.number,
            validator: (value) => (value?.isEmpty ?? true) ? 'Tahun kendaraan wajib diisi' : null,
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('Alamat (Opsional)'),
          CustomTextField(
            controller: addressController,
            hintText: 'Masukkan alamat customer',
            maxLines: 2,
            validator: (value) => null, // Made optional
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('Asuransi (Opsional)'),
          CustomTextField(
            controller: insuranceController,
            hintText: 'Masukkan nama asuransi',
            validator: (value) => null, // Made optional
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('Download M-Toyota'),
          Row(
            children: [
              Radio<bool>(value: true, groupValue: hasMToyotaApp, onChanged: onMToyotaAppChanged, activeColor: AppColors.primary),
              const Text('Sudah'),
              const SizedBox(width: 24),
              Radio<bool>(value: false, groupValue: hasMToyotaApp, onChanged: onMToyotaAppChanged, activeColor: AppColors.primary),
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
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }
}
