import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';

class VehicleConditionStep extends StatefulWidget {

  final Map<String, String> conditionValues;
  final Map<String, bool> carryItemValues;
  final ValueChanged<Map<String, String>> onConditionChanged;
  final ValueChanged<Map<String, bool>> onCarryItemChanged;

  const VehicleConditionStep({
    super.key,
    required this.conditionValues,
    required this.carryItemValues,
    required this.onConditionChanged,
    required this.onCarryItemChanged,
  });

  @override
  State<VehicleConditionStep> createState() => _VehicleConditionStepState();
}

class _VehicleConditionStepState extends State<VehicleConditionStep> {
  late Map<String, String> _conditionValues;
  late Map<String, bool> _carryItemValues;
  
  // Text controllers for BBM & Kilometer
  final TextEditingController _bbmController = TextEditingController();
  final TextEditingController _kilometerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _conditionValues = Map.from(widget.conditionValues);
    _carryItemValues = Map.from(widget.carryItemValues);
    
    // Initialize controllers with values if available
    _bbmController.text = _conditionValues['bbm'] ?? '';
    _kilometerController.text = _conditionValues['kilometer'] ?? '';
  }

  void _updateCondition(String key, String value) {
    setState(() {
      _conditionValues[key] = value;
      widget.onConditionChanged(_conditionValues);
    });
  }

  void _toggleCarryItem(String key) {
    setState(() {
      _carryItemValues[key] = !(_carryItemValues[key] ?? false);
      widget.onCarryItemChanged(_carryItemValues);
    });
  }
  
  @override
  void dispose() {
    _bbmController.dispose();
    _kilometerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Kondisi Ruang Mesin
          _buildSectionTitle('Kondisi Ruang Mesin'),
          _buildSectionContent(
            child: _buildToggleButtons(
              options: const ['Bersih', 'Kotor'],
              key: 'ruangMesin',
            ),
          ),

          // Kondisi Karpet
          _buildSectionTitle('Kondisi Karpet'),
          _buildSectionContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSubSectionTitle('Karpet Dasar'),
                _buildToggleButtons(
                  options: const ['Lock', 'Unlock'],
                  key: 'karpetDasar',
                ),
                const SizedBox(height: 16),
                _buildSubSectionTitle('Karpet Pengemudi'),
                _buildToggleButtons(
                  options: const ['Double', 'Variasi'],
                  key: 'karpetPengemudi',
                ),
              ],
            ),
          ),

          // Kondisi Ketebalan Ban
          _buildSectionTitle('Kondisi Ketebalan Ban'),
          _buildSectionContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSubSectionTitle('FR RH'),
                _buildToggleButtons(
                  options: const ['Hijau', 'Kuning', 'Merah'],
                  key: 'banFRRH',
                  isColorCoded: true,
                ),
                const SizedBox(height: 12),
                _buildSubSectionTitle('FR LH'),
                _buildToggleButtons(
                  options: const ['Hijau', 'Kuning', 'Merah'],
                  key: 'banFRLH',
                  isColorCoded: true,
                ),
                const SizedBox(height: 12),
                _buildSubSectionTitle('RR RH'),
                _buildToggleButtons(
                  options: const ['Hijau', 'Kuning', 'Merah'],
                  key: 'banRRRH',
                  isColorCoded: true,
                ),
                const SizedBox(height: 12),
                _buildSubSectionTitle('RR LH'),
                _buildToggleButtons(
                  options: const ['Hijau', 'Kuning', 'Merah'],
                  key: 'banRRLH',
                  isColorCoded: true,
                ),
              ],
            ),
          ),
          
          // Kondisi Baterai
          _buildSectionTitle('Kondisi Baterai'),
          _buildSectionContent(
            child: _buildToggleButtons(
              options: const ['Good', 'Bad Cell', 'Recharger', 'Replace'],
              key: 'baterai',
              isWrap: true,
            ),
          ),
          
          // BBM & Kilometer
          _buildSectionTitle('BBM & Kilometer'),
          _buildSectionContent(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildValidatedTextField(
                  controller: _bbmController,
                  label: 'Total BBM (%)',
                  hint: 'Contoh: 50',
                  onChanged: (value) => _updateCondition('bbm', value),
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildValidatedTextField(
                  controller: _kilometerController,
                  label: 'Kilometer',
                  hint: 'Contoh: 15000',
                  onChanged: (value) => _updateCondition('kilometer', value),
                )),
              ],
            ),
          ),
          
          // Barang Bawaan
          _buildSectionTitle('Barang Bawaan'),
          _buildSectionContent(
            child: _buildCarryItemsGrid(),
          ),
          
          // Kondisi Body
          _buildSectionTitle('Kondisi Body'),
          _buildSectionContent(
            child: _buildBodyConditionItems(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      color: AppColors.grey100,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContent({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 24, right: 16, bottom: 24),
      child: child,
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
    required String key,
    bool isColorCoded = false,
    bool isWrap = false,
  }) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((option) {
        final isSelected = _conditionValues[key] == option;

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
          onTap: () => _updateCondition(key, option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isColorCoded 
                  ? (isSelected ? getButtonColor() : Colors.transparent)
                  : (isSelected ? AppColors.primary50 : Colors.transparent),
              border: Border.all(
                color: isSelected 
                    ? (isColorCoded ? getButtonColor() : AppColors.primary700)
                    : Colors.grey.shade300,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected 
                    ? (isColorCoded ? Colors.white : AppColors.primary)
                    : Colors.black87,
                fontWeight: isSelected ? FontWeight.normal : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildCarryItemsGrid() {
    final items = {
      'STNK': 'STNK',
      'Booklet': 'Booklet',
      'Toolset': 'Toolset',
      'Payung': 'Payung',
      'Uang': 'Uang',
      'Kotak P3K': 'Kotak P3K',
      'Segitiga Pengaman': 'Segitiga Pengaman',
    };
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final key = items.keys.elementAt(index);
        final value = items.values.elementAt(index);
        final isSelected = _carryItemValues[key] ?? false;
        
        return InkWell(
          onTap: () => _toggleCarryItem(key),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // *** BAGIAN INI YANG DIPERBAIKI ***
                // Membungkus Text dengan Expanded agar fleksibel
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    // Properti softWrap dan overflow untuk penanganan teks yang lebih baik
                    softWrap: true,
                    overflow: TextOverflow.fade,
                  ),
                ),
                // Menambah jarak antara teks dan checkbox
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                  child: isSelected 
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildBodyConditionItems() {
    final bodyParts = [
      'Kap Mesin',
      'Atap Mobil',
      'Bumper Depan',
      'Bumper Belakang',
      'Fender Depan Kanan',
      'Fender Depan Kiri',
      'Fender Belakang Kanan',
      'Fender Belakang Kiri',
      'Pintu Depan Kanan',
      'Pintu Depan Kiri',
      'Pintu Belakang Kanan',
      'Pintu Belakang Kiri',
      'Spion Kanan',
      'Spion Kiri',
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bodyParts.length,
      itemBuilder: (context, index) {
        final part = bodyParts[index];
        final key = 'body_${part.replaceAll(' ', '_').toLowerCase()}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                part,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 10),
              _buildToggleButtons(
                options: const ['Normal', 'Lecet', 'Penyok'],
                key: key,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildValidatedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) => (value?.isEmpty ?? true) ? 'Wajib diisi' : null,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}