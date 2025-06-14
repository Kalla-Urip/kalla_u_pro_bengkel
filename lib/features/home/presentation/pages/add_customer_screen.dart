import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
import 'package:kalla_u_pro_bengkel/common/app_text_styles.dart';
import 'package:kalla_u_pro_bengkel/common/image_resources.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/add_customer_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_vehicle_type_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/pages/custom_barode_screen.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/customer_identity_step.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/notes_and_other_step.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/vehicle_condition_step.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
   int _currentStep = 0;
  final _identityFormKey = GlobalKey<FormState>();
  final _conditionFormKey = GlobalKey<FormState>();
  final _notesFormKey = GlobalKey<FormState>();

  // Step 1 Controllers
  final _frameNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _plateNumberController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _vehicleYearController = TextEditingController();
  final _addressController = TextEditingController();
  final _insuranceController = TextEditingController();
  bool _hasMToyotaApp = true; // Default value

  // Step 2 Data
  Map<String, String> _conditionValues = {};
  Map<String, bool> _carryItemValues = {
    'STNK': false, 'Booklet': false, 'Toolset': false, 'Payung': false,
    'Uang': false, 'Kotak P3K': false, 'Segitiga Pengaman': false,
  };

  // Step 3 Controllers
  final _serviceTypeController = TextEditingController();
  final _notesController = TextEditingController();
  final _mechanicController = TextEditingController();
  final _stallController = TextEditingController(); // Controller baru untuk Stall
  bool _isTradeIn = false;

  @override
  void initState() {
    super.initState();
    final vehicleTypeState = context.read<GetVehicleTypeCubit>().state;
    if (vehicleTypeState is GetVehicleTypeInitial) {
      context.read<GetVehicleTypeCubit>().fetchVehicleTypes();
    }

    _initializeConditionValues();
  }

  void _initializeConditionValues() {
    _conditionValues = {
      'ruangMesin': '',
      'karpetDasar': '',
      'karpetPengemudi': '',
      'banFRRH': '',
      'banFRLH': '',
      'banRRRH': '',
      'banRRLH': '',
      'baterai': '',
      'bbm': '',
      'kilometer': '',
    };

    final bodyParts = [
      'Kap Mesin', 'Atap Mobil', 'Bumper Depan', 'Bumper Belakang',
      'Fender Depan Kanan', 'Fender Depan Kiri', 'Fender Belakang Kanan',
      'Fender Belakang Kiri', 'Pintu Depan Kanan', 'Pintu Depan Kiri',
      'Pintu Belakang Kanan', 'Pintu Belakang Kiri', 'Spion Kanan', 'Spion Kiri'
    ];

    for (final part in bodyParts) {
      final key = 'body_${part.replaceAll(' ', '_').toLowerCase()}';
      _conditionValues[key] = '';
    }
  }

  @override
  void dispose() {
    // Dispose all controllers, including the new ones
    _frameNumberController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _whatsappController.dispose();
    _plateNumberController.dispose();
    _vehicleTypeController.dispose();
    _vehicleYearController.dispose();
    _addressController.dispose();
    _insuranceController.dispose();
    _serviceTypeController.dispose();
    _notesController.dispose();
    _mechanicController.dispose();
     _stallController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddCustomerCubit, AddCustomerState>(
      listener: (context, state) {
        // Menghilangkan dialog loading jika ada
        if (state is! AddCustomerLoading) {
           final isDialogShowing = ModalRoute.of(context)?.isCurrent != true;
            if (isDialogShowing) {
              Navigator.of(context).pop();
            }
        }

        if (state is AddCustomerLoading) {
          // Tampilkan dialog loading
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        } else if (state is AddCustomerSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(
              content: Text('Data customer berhasil disimpan!'),
              backgroundColor: Colors.green,
            ));
          context.pop(); // Kembali ke halaman sebelumnya setelah sukses
        } else if (state is AddCustomerFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text('Gagal: ${state.message}'),
              backgroundColor: Colors.red,
            ));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          leadingWidth: 21,
          title: const Text('Tambah Customer', style: AppTextStyles.subtitle2),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (_currentStep > 0) {
                setState(() => _currentStep -= 1);
              } else {
                context.pop();
              }
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildStepperHeader(),
              Expanded(child: _buildStepContent()),
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepperHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepIndicator(
            step: 1,
            title: 'Identitas\nCustomer',
            isActive: _currentStep >= 0,
            isCompleted: _currentStep > 0,
          ),
          _buildStepArrow(isActive: _currentStep > 0),
          _buildStepIndicator(
            step: 2,
            title: 'Kondisi\nMobil',
            isActive: _currentStep >= 1,
            isCompleted: _currentStep > 1,
          ),
          _buildStepArrow(isActive: _currentStep > 1),
          _buildStepIndicator(
            step: 3,
            title: 'Catatan &\nLainnya',
            isActive: _currentStep >= 2,
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator({
    required int step,
    required String title,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppColors.primary.withOpacity(0.1)
                : Colors.grey.shade200,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: AppColors.primary)
                : Text(
                    step.toString(),
                    style: TextStyle(
                      color: isActive ? AppColors.primary : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? AppColors.primary : Colors.grey,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepArrow({required bool isActive}) {
    return SvgPicture.asset(
      isActive
          ? ImageResources.icArrowActiveRight
          : ImageResources.icArrowInactiveRight,
      width: 24,
      height: 24,
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return CustomerIdentityStep(
          formKey: _identityFormKey,
          // Pass new controllers to the widget
          frameNumberController: _frameNumberController,
          nameController: _nameController,
          dobController: _dobController,
          whatsappController: _whatsappController,
          plateNumberController: _plateNumberController,
          vehicleTypeController: _vehicleTypeController,
          vehicleYearController: _vehicleYearController,
          addressController: _addressController,
          insuranceController: _insuranceController,
          hasMToyotaApp: _hasMToyotaApp,
          onMToyotaAppChanged: (value) {
            setState(() {
              _hasMToyotaApp = value ?? false;
            });
          },
          // New callback to handle navigation to barcode scanner
          onScanBarcode: () async {
            final result = await Navigator.push<String>(
              context,
              MaterialPageRoute(builder: (context) => const CustomBarcodeScreen()),
            );
            if (result != null) {
              setState(() {
                _frameNumberController.text = result;
              });
            }
          },
        );
      case 1:
        return VehicleConditionStep(
          formKey: _conditionFormKey,
          conditionValues: _conditionValues,
          carryItemValues: _carryItemValues,
          onConditionChanged: (values) {
            setState(() {
              _conditionValues = values;
            });
          },
          onCarryItemChanged: (values) {
            setState(() {
              _carryItemValues = values;
            });
          },
        );
      case 2:
        return NotesAndOthersStep(
          formKey: _notesFormKey,
          serviceTypeController: _serviceTypeController,
          notesController: _notesController,
          mechanicController: _mechanicController,
          isTradeIn: _isTradeIn,
          stallController: _stallController,
          onTradeInChanged: (value) {
            setState(() {
              _isTradeIn = value ?? false;
            });
          },
        );
      default:
        return Container();
    }
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep -= 1;
                  });
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Kembali',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _handleNextOrSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                _currentStep == 2 ? 'Simpan' : 'Selanjutnya',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _handleNextOrSubmit() {
    // Validasi step saat ini sebelum lanjut
    bool isStepValid = false;
    if (_currentStep == 0) {
      isStepValid = _identityFormKey.currentState?.validate() ?? false;
    } else if (_currentStep == 1) {
      // Step 2 tidak memiliki form validation, dianggap selalu valid
      // Jika ada validasi, tambahkan di sini. Contoh: _conditionFormKey.currentState?.validate()
      isStepValid = true; 
    } else if (_currentStep == 2) {
       isStepValid = _notesFormKey.currentState?.validate() ?? false;
    }

    if (!isStepValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua data yang wajib diisi.'), backgroundColor: Colors.orange),
      );
      return; // Hentikan proses jika validasi gagal
    }

    // Lanjutkan ke step berikutnya atau submit
    if (_currentStep < 2) {
      setState(() {
        _currentStep += 1;
      });
    } else {
      // Sudah di step terakhir, tampilkan dialog konfirmasi
      _showConfirmationDialog();
    }
  }

 


  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                ImageResources.icWarning,
                width: 100,
              ),
              const SizedBox(height: 16),
              Text(
                'Konfirmasi Tambah Customer',
                style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Silahkan Klik Ya, jika data customer Anda telah sesuai',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Batal',
                        style: AppTextStyles.subtitle2.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                       onPressed: () {
            Navigator.pop(context); // Tutup dialog konfirmasi
            _submitDataToApi(); // Panggil metode untuk submit ke API
        },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Ya',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


   void _submitDataToApi() {
    // --- MAPPING DATA SESUAI cURL ---

    // 1. Luggage Items: Konversi bool ke 'Ya' atau 'Tidak'
    final luggageData = {
      'luggage_stnk': _carryItemValues['STNK']! ? 'Ya' : 'Tidak',
      'luggage_booklet': _carryItemValues['Booklet']! ? 'Ya' : 'Tidak',
      'luggage_toolset': _carryItemValues['Toolset']! ? 'Ya' : 'Tidak',
      'luggage_umbrella': _carryItemValues['Payung']! ? 'Ya' : 'Tidak',
      'luggage_money': _carryItemValues['Uang']! ? 'Ya' : 'Tidak',
      'luggage_p3k': _carryItemValues['Kotak P3K']! ? 'Ya' : 'Tidak',
      'luggage_triangle_protection': _carryItemValues['Segitiga Pengaman']! ? 'Ya' : 'Tidak',
    };

    // 2. Body Condition Items: Ganti key
    final bodyConditionData = <String, String>{};
    _conditionValues.forEach((key, value) {
      if (key.startsWith('body_')) {
        final newKey = 'bodyCondition_${key.substring(5)}';
        bodyConditionData[newKey] = value;
      }
    });

    // 3. Gabungkan semua data menjadi satu Map
    final Map<String, dynamic> customerData = {
      // Step 1
      'chassisNumber': _frameNumberController.text,
      'name': _nameController.text,
      'birthDate': _dobController.text,
      'phone': _whatsappController.text,
      'plateNumber': _plateNumberController.text,
      'typeId': _vehicleTypeController.text, // TODO: Kirim ID, bukan nama. Perlu mapping. Untuk sekarang, kirim nama.
      'year': _vehicleYearController.text,
      'insurance': _insuranceController.text,
      'mToyota': _hasMToyotaApp ? 'Ya' : 'Tidak',
      'source': 'toyota', // Sesuai cURL

      // Step 2
      'engineRoomCondition': _conditionValues['ruangMesin'],
      'baseCarpetCondition': _conditionValues['karpetDasar'],
      'driverCarpetCondition': _conditionValues['karpetPengemudi'],
      'fr_rh': _conditionValues['banFRRH'],
      'fr_lh': _conditionValues['banFRLH'],
      'rr_rh': _conditionValues['banRRRH'],
      'rr_lh': _conditionValues['banRRLH'],
      'batteraiCondition': _conditionValues['baterai'],
      'fuelTotal': _conditionValues['bbm'],
      'kilometer': _conditionValues['kilometer'],
      ...luggageData,
      ...bodyConditionData,

      // Step 3
      'serviceType': _serviceTypeController.text,
      'note': _notesController.text.isNotEmpty ? _notesController.text : '-',
      'tradeIn': _isTradeIn ? 'Ya' : 'Tidak',
      'StallId': _stallController.text,
      'MechanicId': _mechanicController.text,
    };
    
    // Hapus nilai null atau kosong untuk menghindari error di server
    customerData.removeWhere((key, value) => value == null || value == '');

    // Panggil Cubit untuk mengirim data
    context.read<AddCustomerCubit>().submitCustomerData(customerData);
  }

}