import 'package:flutter/material.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/custom_drop_down.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/custom_text_field.dart';
class NotesAndOthersStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController serviceTypeController;
  final TextEditingController notesController;
  final TextEditingController mechanicController;
  final bool isTradeIn;
  final ValueChanged<bool?> onTradeInChanged;

  const NotesAndOthersStep({
    Key? key,
    required this.formKey,
    required this.serviceTypeController,
    required this.notesController,
    required this.mechanicController,
    required this.isTradeIn,
    required this.onTradeInChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample service types
    final serviceTypes = ['Tune Up', 'Ganti Oli', 'Pemeriksaan Rutin', 'Perbaikan AC', 'Ganti Ban', 'Lainnya'];
    
    // Sample mechanics
    final mechanics = ['Muh Rifqy', 'Ahmad Dahlan', 'Budi Santoso', 'Deni Kurniawan', 'Eko Prasetyo'];

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // Jenis Service
          _buildSectionTitle('Jenis Service'),
          CustomDropdown(
            controller: serviceTypeController,
            hintText: 'Pilih jenis service',
            items: serviceTypes,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Jenis service wajib dipilih';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Catatan
          _buildSectionTitle('Catatan'),
          CustomTextField(
            controller: notesController,
            hintText: 'Masukkan catatan tambahan',
            maxLines: 3,
            validator: (value) => null, // Optional field
          ),
          const SizedBox(height: 24),

          // Petugas Bengkel
          _buildSectionTitle('Petugas Bengkel'),
          CustomDropdown(
            controller: mechanicController,
            hintText: 'Pilih petugas bengkel',
            items: mechanics,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Petugas bengkel wajib dipilih';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Trade In
          _buildSectionTitle('Trade In'),
          _buildTradeInOptions(),
          // If trade-in is selected, show additional info
          if (isTradeIn) 
            _buildTradeInInfoBox(),
          const SizedBox(height: 40),
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

  Widget _buildTradeInOptions() {
    return Row(
      children: [
        Radio<bool>(
          value: true,
          groupValue: isTradeIn,
          onChanged: onTradeInChanged,
          activeColor: AppColors.primary,
        ),
        const Text(
          'Tertarik',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(width: 24),
        Radio<bool>(
          value: false,
          groupValue: isTradeIn,
          onChanged: onTradeInChanged,
          activeColor: AppColors.primary,
        ),
        const Text(
          'Tidak',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTradeInInfoBox() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Info Trade In',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Pelanggan tertarik untuk melakukan trade in. '
              'Petugas marketing akan menghubungi pelanggan untuk informasi lebih lanjut.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            
            // Optional: add more details or fields for trade-in follow-up
            _buildTradeInFollowupOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeInFollowupOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 16, thickness: 1),
        const Text(
          'Preferensi Kontak',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildChip('Telepon'),
            _buildChip('WhatsApp'),
            _buildChip('Email'),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Detail kendaraan yang diminati akan dicatat oleh petugas marketing.',
          style: TextStyle(
            fontSize: 11,
            color: Colors.black54,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.primary,
        ),
      ),
    );
  }
}