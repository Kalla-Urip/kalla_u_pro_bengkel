import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/custom_text_field.dart';

class VehicleConditionStep extends StatefulWidget {
  final ScrollController scrollController;
  final Map<String, String> conditionValues;
  final Map<String, List<String>> bodyConditionValues; // Changed for multi-select
  final Map<String, bool> carryItemValues;
  final TextEditingController notesController;
  final ValueChanged<Map<String, String>> onConditionChanged;
  final ValueChanged<Map<String, List<String>>> onBodyConditionChanged; // Changed for multi-select
  final ValueChanged<Map<String, bool>> onCarryItemChanged;

  const VehicleConditionStep({
    super.key,
    required this.scrollController,
    required this.conditionValues,
    required this.bodyConditionValues,
    required this.carryItemValues,
    required this.notesController,
    required this.onConditionChanged,
    required this.onBodyConditionChanged,
    required this.onCarryItemChanged,
  });

  @override
  State<VehicleConditionStep> createState() => _VehicleConditionStepState();
}

class _VehicleConditionStepState extends State<VehicleConditionStep> {
  late Map<String, String> _conditionValues;
  late Map<String, List<String>> _bodyConditionValues;
  late Map<String, bool> _carryItemValues;

  final TextEditingController _kilometerController = TextEditingController();
  final TextEditingController _bbmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _conditionValues = Map.from(widget.conditionValues);
    _bodyConditionValues = Map.from(widget.bodyConditionValues);
    _carryItemValues = Map.from(widget.carryItemValues);
    
    _kilometerController.text = _conditionValues['kilometer'] ?? '';
    _kilometerController.addListener(() {
      _updateCondition('kilometer', _kilometerController.text);
    });

    _bbmController.text = _conditionValues['bbm'] ?? '';
    _bbmController.addListener(() {
      _updateCondition('bbm', _bbmController.text);
    });
  }

  void _updateCondition(String key, String value) {
    setState(() {
      _conditionValues[key] = value;
      widget.onConditionChanged(_conditionValues);
    });
  }

  void _toggleBodyCondition(String key, String value) {
    setState(() {
      if (_bodyConditionValues[key]!.contains(value)) {
        _bodyConditionValues[key]!.remove(value);
      } else {
        _bodyConditionValues[key]!.add(value);
      }
      widget.onBodyConditionChanged(_bodyConditionValues);
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
    _kilometerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      // The key from the parent can be used here if needed for validation triggering
      child: ListView(
        controller: widget.scrollController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionTitle('Kondisi Ruang Mesin'),
          _buildSectionContent(
            child: _buildToggleButtons(
              options: const ['Bersih', 'Kotor'],
              key: 'ruangMesin',
            ),
          ),

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
                  options: const ['Standart', 'Double', 'Variasi'], // Added 'Standart'
                  key: 'karpetPengemudi',
                ),
              ],
            ),
          ),

          _buildSectionTitle('Kondisi Ketebalan Ban'),
          _buildSectionContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTireCondition('Depan Kanan', 'banDepanKanan'),
                _buildTireCondition('Depan Kiri', 'banDepanKiri'),
                _buildTireCondition('Belakang Kanan', 'banBelakangKanan'),
                _buildTireCondition('Belakang Kiri', 'banBelakangKiri'),
              ],
            ),
          ),
          
          _buildSectionTitle('Kondisi Baterai'),
          _buildSectionContent(
            child: _buildToggleButtons(
              options: const ['Good', 'Bad Cell', 'Recharger', 'Replace', 'Butuh Pengecekan'],
              key: 'baterai',
              isWrap: true,
            ),
          ),
          
             _buildSectionTitle('BBM & Kilometer'),
          _buildSectionContent(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildFreeTextField(
                    controller: _bbmController,
                    label: 'Total BBM',
                    hint: 'Contoh: 2 bar, 1/4',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildValidatedTextField(
                  controller: _kilometerController,
                  label: 'Kilometer',
                  hint: 'Contoh: 15000',
                )),
              ],
            ),
          ),
          
          _buildSectionTitle('Barang Bawaan'),
          _buildSectionContent(
            child: _buildCarryItemsGrid(),
          ),
          
          _buildSectionTitle('Kondisi Body'),
          _buildSectionContent(
            child: _buildBodyConditionItems(),
          ),

          _buildSectionTitle('Tambahan (Tidak ada dalam inputan)'),
           _buildSectionContent(
            child: CustomTextField(
              controller: widget.notesController,
              hintText: 'Masukkan catatan tambahan (opsional)',
              maxLines: 4,
              validator: (value) => null, // Optional
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTireCondition(String label, String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubSectionTitle(label),
          _buildToggleButtons(
            options: const ['Hijau', 'Kuning', 'Merah'],
            key: key,
            isColorCoded: true,
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
            case 'hijau': return Colors.green;
            case 'kuning': return Colors.amber;
            case 'merah': return Colors.red;
            default: return isSelected ? AppColors.primary : Colors.transparent;
          }
        }
        
        return InkWell(
          onTap: () => _updateCondition(key, option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
    final items = [
      'STNK', 'Booklet', 'Toolset', 'Payung', 'Uang', 'Kotak P3K', 
      'Segitiga Pengaman', 'Ban Serep', 'Baut Roda'
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final key = items[index];
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
                Expanded(
                  child: Text(
                    key,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    softWrap: true,
                    overflow: TextOverflow.fade,
                  ),
                ),
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
      'Kap Mesin', 'Atap Mobil', 'Bumper Depan', 'Bumper Belakang', 'Pintu Bagasi',
      'Fender Depan Kanan', 'Fender Depan Kiri', 'Fender Belakang Kanan', 'Fender Belakang Kiri',
      'Pintu Depan Kanan', 'Pintu Depan Kiri', 'Pintu Belakang Kanan', 'Pintu Belakang Kiri',
      'Spion Kanan', 'Spion Kiri',
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bodyParts.length,
      itemBuilder: (context, index) {
        final part = bodyParts[index];
        final key = 'body_${part.replaceAll(' ', '_').toLowerCase()}';
        
        List<String> options = ['Normal', 'Lecet', 'Penyok'];
        if (part.contains('Spion') || part.contains('Bumper')) {
          options.add('Robek');
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(part, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
              const SizedBox(height: 10),
              _buildMultiSelectToggleButtons(options: options, partKey: key),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMultiSelectToggleButtons({required List<String> options, required String partKey}) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((option) {
        final isSelected = _bodyConditionValues[partKey]?.contains(option) ?? false;

        return InkWell(
          onTap: () => _toggleBodyCondition(partKey, option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary50 : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppColors.primary700 : Colors.grey.shade300,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.black87,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildValidatedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          // The main validation logic is now handled in the parent screen's _handleNextOrSubmit
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

    Widget _buildFreeTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
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
