import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_mechanic_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_stall_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/custom_drop_down.dart';

class NotesAndOthersStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController serviceTypeController;
  final TextEditingController mechanicController;
  final TextEditingController stallController;
  final TextEditingController sourceController;
  final bool isTradeIn;
  final ValueChanged<bool?> onTradeInChanged;
  final GetStallsState stallState;
  final GetMechanicsState mechanicState;

  const NotesAndOthersStep({
    super.key,
    required this.formKey,
    required this.serviceTypeController,
    required this.mechanicController,
    required this.stallController,
    required this.sourceController,
    required this.isTradeIn,
    required this.onTradeInChanged,
    required this.stallState,
    required this.mechanicState,
  });

  @override
  Widget build(BuildContext context) {
    final serviceTypes = {
      'Tune Up': 'Tune Up',
      'Ganti Oli': 'Ganti Oli',
      'Pemeriksaan Rutin': 'Pemeriksaan Rutin',
      'Servis Berkala': 'Servis Berkala',
      'Perbaikan AC': 'Perbaikan AC',
      'Lainnya': 'Lainnya'
    };
    
    final sourceOptions = {'Toyota': 'toyota', 'Otoxpert': 'otoxpert'};

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionTitle('Jenis Service'),
          CustomDropdown(
            controller: serviceTypeController,
            hintText: 'Pilih jenis service (opsional)',
            items: serviceTypes,
            validator: (value) => null, // Optional
          ),
          const SizedBox(height: 24),
          
          _buildSectionTitle('Sumber'),
          CustomDropdown(
            controller: sourceController,
            hintText: 'Pilih sumber',
            items: sourceOptions,
            validator: (value) => (value?.isEmpty ?? true) ? 'Sumber wajib dipilih' : null,
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('Petugas Bengkel (Mekanik)'),
          _buildMechanicDropdown(context),
          const SizedBox(height: 24),

          _buildSectionTitle('Stall'),
          _buildStallDropdown(context),
          const SizedBox(height: 24),

          _buildSectionTitle('Trade In'),
          _buildTradeInOptions(),
          if (isTradeIn) _buildTradeInInfoBox(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStallDropdown(BuildContext context) {
    final state = stallState;
    if (state is GetStallsSuccess) {
      final Map<String, String> stallItems = {for (var stall in state.stalls) stall.name: stall.id.toString()};
      return CustomDropdown(
        controller: stallController,
        hintText: 'Pilih stall',
        items: stallItems,
        validator: (value) => null,
      );
    }
    if (state is GetStallsFailure) {
      return _buildErrorWidget(message: state.message, onRetry: () => context.read<GetStallsCubit>().fetchStalls());
    }
    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
  }

  Widget _buildMechanicDropdown(BuildContext context) {
    final state = mechanicState;
    if (state is GetMechanicsSuccess) {
      final Map<String, String> mechanicItems = {for (var mechanic in state.mechanics) mechanic.name: mechanic.id.toString()};
      return CustomDropdown(
        controller: mechanicController,
        hintText: 'Pilih petugas bengkel',
        items: mechanicItems,
        validator: (value) => null,
      );
    }
    if (state is GetMechanicsFailure) {
      return _buildErrorWidget(message: state.message, onRetry: () => context.read<GetMechanicsCubit>().fetchMechanics());
    }
    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
  }

  Widget _buildErrorWidget({required String message, required VoidCallback onRetry}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.red.withOpacity(0.05),
      ),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade800)),
          const SizedBox(height: 4),
          TextButton(onPressed: onRetry, child: const Text('Coba Lagi', style: TextStyle(color: AppColors.primary))),
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

  Widget _buildTradeInOptions() {
    return Row(
      children: [
        Radio<bool>(value: true, groupValue: isTradeIn, onChanged: onTradeInChanged, activeColor: AppColors.primary),
        const Text('Tertarik', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 24),
        Radio<bool>(value: false, groupValue: isTradeIn, onChanged: onTradeInChanged, activeColor: AppColors.primary),
        const Text('Tidak', style: TextStyle(fontSize: 14)),
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
          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Info Trade In', style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.primary)),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Pelanggan tertarik untuk melakukan trade in. Tim akan menghubungi pelanggan untuk informasi lebih lanjut.',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
