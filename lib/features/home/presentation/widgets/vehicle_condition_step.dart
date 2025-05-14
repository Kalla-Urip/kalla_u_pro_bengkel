import 'package:flutter/material.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';

class VehicleConditionStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String engineCondition;
  final String floorMatCondition;
  final String driverFloorMat;
  final String tireFRCondition;
  final ValueChanged<String?> onEngineConditionChanged;
  final ValueChanged<String?> onFloorMatConditionChanged;
  final ValueChanged<String?> onDriverFloorMatChanged;
  final ValueChanged<String?> onTireFRConditionChanged;

  const VehicleConditionStep({
    Key? key,
    required this.formKey,
    required this.engineCondition,
    required this.floorMatCondition,
    required this.driverFloorMat,
    required this.tireFRCondition,
    required this.onEngineConditionChanged,
    required this.onFloorMatConditionChanged,
    required this.onDriverFloorMatChanged,
    required this.onTireFRConditionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // Kondisi Ruang Mesin
          _buildSectionTitle('Kondisi Ruang Mesin'),
          _buildToggleButtons(
            options: const ['Bersih', 'Kotor'],
            selectedValue: engineCondition,
            onChanged: onEngineConditionChanged,
          ),
          const SizedBox(height: 24),

          // Kondisi Karpet
          _buildSectionTitle('Kondisi Karpet'),
          _buildSubSectionTitle('Karpet Dasar'),
          _buildToggleButtons(
            options: const ['Lock', 'Unlock'],
            selectedValue: floorMatCondition,
            onChanged: onFloorMatConditionChanged,
          ),
          const SizedBox(height: 16),

          _buildSubSectionTitle('Karpet Pengemudi'),
          _buildToggleButtons(
            options: const ['Double', 'Variasi'],
            selectedValue: driverFloorMat,
            onChanged: onDriverFloorMatChanged,
          ),
          const SizedBox(height: 24),

          // Kondisi Ketebalan Ban
          _buildSectionTitle('Kondisi Ketebalan Ban'),
          _buildSubSectionTitle('FR RH'),
          _buildToggleButtons(
            options: const ['Hijau', 'Kuning', 'Merah'],
            selectedValue: tireFRCondition,
            onChanged: onTireFRConditionChanged,
            isColorCoded: true,
          ),
          const SizedBox(height: 24),

          // Additional tire conditions can be added here
          // For the sake of brevity, only one tire is shown
          
          // Note: removed validation warning message to allow progress without selections
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSubSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildToggleButtons({
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String?> onChanged,
    bool isColorCoded = false,
  }) {
    return Wrap(
      spacing: 12,
      children: options.map((option) {
        final isSelected = selectedValue == option;
        
        // Determine button color based on option if color coded
        Color getButtonColor() {
          if (!isColorCoded) return isSelected ? AppColors.primary : Colors.transparent;
          
          switch (option.toLowerCase()) {
            case 'hijau':
              return Colors.green;
            case 'kuning':
              return Colors.amber;
            case 'merah':
              return Colors.red;
            default:
              return isSelected ? AppColors.primary : Colors.transparent;
          }
        }
        
        return InkWell(
          onTap: () => onChanged(option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: isColorCoded 
                  ? (isSelected ? getButtonColor() : Colors.transparent)
                  : (isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent),
              border: Border.all(
                color: isSelected 
                    ? (isColorCoded ? getButtonColor() : AppColors.primary)
                    : Colors.grey.shade300,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected 
                    ? (isColorCoded ? Colors.white : AppColors.primary)
                    : Colors.black87,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}