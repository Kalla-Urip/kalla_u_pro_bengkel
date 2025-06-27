import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/mechanic_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/stall_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_mechanic_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_stall_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/custom_drop_down.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/custom_text_field.dart';

class NotesAndOthersStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController serviceTypeController;
  final TextEditingController notesController;
  final TextEditingController mechanicController;
  final TextEditingController stallController;
  final TextEditingController sourceController; // <-- [MODIFIED] Added controller
  final bool isTradeIn;
  final ValueChanged<bool?> onTradeInChanged;
  // Menerima state, bukan list model
  final GetStallsState stallState;
  final GetMechanicsState mechanicState;

  const NotesAndOthersStep({
    super.key,
    required this.formKey,
    required this.serviceTypeController,
    required this.notesController,
    required this.mechanicController,
    required this.stallController,
    required this.sourceController, // <-- [MODIFIED] Added to constructor
    required this.isTradeIn,
    required this.onTradeInChanged,
    // Mengubah parameter di constructor
    required this.stallState,
    required this.mechanicState,
  });

  @override
  Widget build(BuildContext context) {
    // Service types can remain hardcoded if they are static
    final serviceTypes = {
      'Tune Up': 'Tune Up',
      'Ganti Oli': 'Ganti Oli',
      'Pemeriksaan Rutin': 'Pemeriksaan Rutin',
      'Perbaikan AC': 'Perbaikan AC',
      'Lainnya': 'Lainnya'
    };
    
    // <-- [MODIFIED] Added source options
    final sourceOptions = {
      'Toyota': 'toyota',
      'Otoxpert': 'otoxpert',
    };

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
            validator: (value) =>
                (value?.isEmpty ?? true) ? 'Jenis service wajib dipilih' : null,
          ),
          const SizedBox(height: 24),

          // Catatan
          _buildSectionTitle('Catatan'),
          CustomTextField(
            controller: notesController,
            hintText: 'Masukkan catatan tambahan (opsional)',
            maxLines: 3,
            validator: (value) => null, // Opsional
          ),
          const SizedBox(height: 24),
          
          // <-- [MODIFIED] Added Source Dropdown
          _buildSectionTitle('Sumber'),
          CustomDropdown(
            controller: sourceController,
            hintText: 'Pilih sumber',
            items: sourceOptions,
            validator: (value) =>
                (value?.isEmpty ?? true) ? 'Sumber wajib dipilih' : null,
          ),
          const SizedBox(height: 24),

          // Petugas Bengkel (Mekanik) - Dengan error handling
          _buildSectionTitle('Petugas Bengkel (Mekanik)'),
          _buildMechanicDropdown(context),
          const SizedBox(height: 24),

          // Stall - Dengan error handling
          _buildSectionTitle('Stall'),
          _buildStallDropdown(context),
          const SizedBox(height: 24),

          // Trade In
          _buildSectionTitle('Trade In'),
          _buildTradeInOptions(),
          if (isTradeIn) _buildTradeInInfoBox(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Widget baru untuk membangun dropdown stall dengan penanganan state
  Widget _buildStallDropdown(BuildContext context) {
    final state = stallState; // Gunakan state yang di-pass
    if (state is GetStallsSuccess) {
      final Map<String, String> stallItems = {
        for (var stall in state.stalls) stall.name: stall.id.toString()
      };
      return CustomDropdown(
        controller: stallController,
        hintText: 'Pilih stall',
        items: stallItems,
        validator: (value) =>
            (value?.isEmpty ?? true) ? 'Stall wajib dipilih' : null,
      );
    }
    if (state is GetStallsFailure) {
      return _buildErrorWidget(
        message: state.message,
        onRetry: () {
          context.read<GetStallsCubit>().fetchStalls();
        },
      );
    }
    // State Loading atau Initial
    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
  }

  // Widget baru untuk membangun dropdown mekanik dengan penanganan state
  Widget _buildMechanicDropdown(BuildContext context) {
    final state = mechanicState; // Gunakan state yang di-pass
    if (state is GetMechanicsSuccess) {
      final Map<String, String> mechanicItems = {
        for (var mechanic in state.mechanics)
          mechanic.name: mechanic.id.toString()
      };
      return CustomDropdown(
        controller: mechanicController,
        hintText: 'Pilih petugas bengkel',
        items: mechanicItems,
        validator: (value) =>
            (value?.isEmpty ?? true) ? 'Petugas bengkel wajib dipilih' : null,
      );
    }
    if (state is GetMechanicsFailure) {
      return _buildErrorWidget(
        message: state.message,
        onRetry: () {
          context.read<GetMechanicsCubit>().fetchMechanics();
        },
      );
    }
    // State Loading atau Initial
    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
  }

  // Helper widget untuk error yang bisa dipakai ulang dengan gaya yang sama
  Widget _buildErrorWidget(
      {required String message, required VoidCallback onRetry}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.red.withOpacity(0.05),
      ),
      child: Column(
        children: [
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade800)),
          const SizedBox(height: 4),
          TextButton(
            onPressed: onRetry,
            child: const Text('Coba Lagi',
                style: TextStyle(color: AppColors.primary)),
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
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
            SizedBox(height: 8),
            Text(
              'Pelanggan tertarik untuk melakukan trade in. '
              'Tim akan menghubungi pelanggan untuk informasi lebih lanjut.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
            // const SizedBox(height: 8),
            // _buildTradeInFollowupOptions(),
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