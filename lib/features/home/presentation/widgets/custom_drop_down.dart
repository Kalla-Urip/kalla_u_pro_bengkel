import 'package:flutter/material.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';


class CustomDropdown extends StatefulWidget {
  final TextEditingController controller; // Controller ini akan menyimpan ID
  final String hintText;
  final Map<String, String> items; // Diubah menjadi Map<Nama, ID>
  final String? Function(String?)? validator;
  final Function(String displayName, String id)? onChanged; // Callback dengan nama dan ID

  const CustomDropdown({
    super.key,
    required this.controller,
    required this.hintText,
    required this.items,
    this.validator,
    this.onChanged,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String? _selectedDisplayName;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    String? selectedDisplayName;
    if (widget.controller.text.isNotEmpty && widget.items.containsValue(widget.controller.text)) {
      selectedDisplayName = widget.items.keys.firstWhere((key) => widget.items[key] == widget.controller.text);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Widget yang terlihat seperti TextField
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                   selectedDisplayName ?? widget.hintText,
                    style: TextStyle(
                      fontSize: 14,
                      color: _selectedDisplayName != null ? Colors.black : Colors.grey.shade400,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        
        // Wrapper FormField tak terlihat untuk validasi
        // Ini memastikan pesan error dari validator bisa ditampilkan
        FormField<String>(
          initialValue: widget.controller.text,
          validator: widget.validator,
          builder: (state) {
            // Kita perlu update state FormField saat nilai berubah
            // agar validasi berjalan dengan benar.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (state.value != widget.controller.text) {
                state.didChange(widget.controller.text);
              }
            });
            
            if (state.hasError) {
              return Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        
        // Daftar item dropdown yang muncul
        if (_isExpanded)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final displayName = widget.items.keys.elementAt(index);
                final id = widget.items.values.elementAt(index);
                final isSelected = widget.controller.text == id;

                return InkWell(
                  onTap: () {
                    setState(() {
                      widget.controller.text = id; // Simpan ID di controller
                      _selectedDisplayName = displayName; // Simpan nama untuk tampilan
                      _isExpanded = false;
                    });
                    // Panggil callback jika ada
                    widget.onChanged?.call(displayName, id);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                    child: Text(
                      displayName,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primary : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}