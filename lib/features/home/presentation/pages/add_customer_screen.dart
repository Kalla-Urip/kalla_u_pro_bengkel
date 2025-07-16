import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
import 'package:kalla_u_pro_bengkel/common/app_text_styles.dart';
import 'package:kalla_u_pro_bengkel/common/image_resources.dart';
import 'package:kalla_u_pro_bengkel/features/home/data/models/chasis_customer_model.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/add_customer_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_customer_by_chasis_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_mechanic_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_stall_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/bloc/get_vehicle_type_cubit.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/pages/custom_barode_screen.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/customer_identity_step.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/notes_and_other_step.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/vehicle_condition_step.dart';
import 'package:kalla_u_pro_bengkel/core/util/utils.dart'; // Import Utils for custom snackbar


class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  int _currentStep = 0;
  final _identityFormKey = GlobalKey<FormState>();
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
    'STNK': false,
    'Booklet': false,
    'Toolset': false,
    'Payung': false,
    'Uang': false,
    'Kotak P3K': false,
    'Segitiga Pengaman': false,
  };

  // Step 3 Controllers
  final _serviceTypeController = TextEditingController();
  final _notesController = TextEditingController();
  final _mechanicController = TextEditingController();
  final _stallController = TextEditingController();
  final _sourceController = TextEditingController();
  bool _isTradeIn = false;

  @override
  void initState() {
    super.initState();
    context.read<GetVehicleTypeCubit>().fetchVehicleTypes();
    context.read<GetStallsCubit>().fetchStalls();
    context.read<GetMechanicsCubit>().fetchMechanics();
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
    _sourceController.dispose();
    super.dispose();
  }

  void _searchChassisNumber() {
    final chassisNumber = _frameNumberController.text.trim();
    if (chassisNumber.isEmpty) {
      Utils.showWarningSnackBar(context, 'Nomor rangka tidak boleh kosong untuk pencarian.');
      return;
    }
    context.read<GetCustomerByChassisCubit>().searchCustomerByChassisNumber(chassisNumber);
  }

  void _populateFieldsFromChassisData(ChassisCustomerModel customer) {
    _nameController.text = customer.name ?? '';
    _dobController.text = customer.birthDate ?? '';
    _whatsappController.text = customer.phone ?? '';
    _plateNumberController.text = customer.plateNumber ?? '';
    _vehicleYearController.text = (customer.year ?? '').toString();
    _addressController.text = customer.address ?? '';
    _insuranceController.text = customer.insurance ?? '';
    _hasMToyotaApp = customer.mToyota ?? false;

    final vehicleTypeState = context.read<GetVehicleTypeCubit>().state;
    if (vehicleTypeState is GetVehicleTypeSuccess) {
      try {
        // Mencari tipe kendaraan yang cocok berdasarkan ID
        final matchedType = vehicleTypeState.vehicleTypes.firstWhere(
          (type) => type.id == customer.typeId,
        );
        // Jika ditemukan, set controller dengan ID-nya
        _vehicleTypeController.text = matchedType.id.toString();
      } catch (e) {
        // Jika tidak ditemukan (firstWhere akan throw error), tangani di sini
        _vehicleTypeController.clear();
        Utils.showWarningSnackBar(context, 'Tipe kendaraan dari data tidak ditemukan di daftar pilihan.');
      }
    } else {
      // Jika daftar tipe kendaraan belum dimuat
      _vehicleTypeController.clear();
      Utils.showWarningSnackBar(context, 'Daftar tipe kendaraan belum dimuat.');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AddCustomerCubit, AddCustomerState>(
          listener: (context, state) {
            if (state is! AddCustomerLoading) {
              final isDialogShowing = ModalRoute.of(context)?.isCurrent != true;
              if (isDialogShowing) {
                Navigator.of(context).pop();
              }
            }
            if (state is AddCustomerLoading) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              );
            } else if (state is AddCustomerSuccess) {
              Utils.showSuccessSnackBar(context, 'Data customer berhasil disimpan!');
              context.pop(true);
            } else if (state is AddCustomerFailure) {
              Utils.showErrorSnackBar(context, 'Gagal: ${state.message}');
            }
          },
        ),
        BlocListener<GetCustomerByChassisCubit, GetCustomerByChassisState>(
          listener: (context, state) {
            if (state is GetCustomerByChassisSuccess) {
              _populateFieldsFromChassisData(state.customer);
              Utils.showSuccessSnackBar(context, 'Data customer ditemukan dan berhasil diisi!');
            } else if (state is GetCustomerByChassisNotFound) {
              Utils.showInfoSnackBar(context, state.message);
              _nameController.clear();
              _dobController.clear();
              _whatsappController.clear();
              _plateNumberController.clear();
              _vehicleTypeController.clear();
              _vehicleYearController.clear();
              _addressController.clear();
              _insuranceController.clear();
              _hasMToyotaApp = false;
              setState(() {});
            } else if (state is GetCustomerByChassisFailure) {
              Utils.showErrorSnackBar(context, 'Gagal mencari data: ${state.message}');
            }
          },
        ),
      ],
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
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepIndicator(step: 1, title: 'Identitas\nCustomer', isActive: _currentStep >= 0, isCompleted: _currentStep > 0),
          _buildStepArrow(isActive: _currentStep > 0),
          _buildStepIndicator(step: 2, title: 'Kondisi\nMobil', isActive: _currentStep >= 1, isCompleted: _currentStep > 1),
          _buildStepArrow(isActive: _currentStep > 1),
          _buildStepIndicator(step: 3, title: 'Catatan &\nLainnya', isActive: _currentStep >= 2, isCompleted: false),
        ],
      ),
    );
  }

  Widget _buildStepIndicator({required int step, required String title, required bool isActive, required bool isCompleted}) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade200,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: AppColors.primary)
                : Text(step.toString(), style: TextStyle(color: isActive ? AppColors.primary : Colors.grey, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: isActive ? AppColors.primary : Colors.grey, fontWeight: isActive ? FontWeight.w500 : FontWeight.normal),
        ),
      ],
    );
  }

  Widget _buildStepArrow({required bool isActive}) {
    return SvgPicture.asset(
      isActive ? ImageResources.icArrowActiveRight : ImageResources.icArrowInactiveRight,
      width: 24,
      height: 24,
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return CustomerIdentityStep(
          formKey: _identityFormKey,
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
          onMToyotaAppChanged: (value) => setState(() => _hasMToyotaApp = value ?? false),
          onScanBarcode: () async {
            final result = await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => const CustomBarcodeScreen()));
            if (result != null) {
              setState(() {
                _frameNumberController.text = result;
                _searchChassisNumber();
              });
            }
          },
          onSearchChassis: _searchChassisNumber,
        );
      case 1:
        return VehicleConditionStep(
          conditionValues: _conditionValues,
          carryItemValues: _carryItemValues,
          onConditionChanged: (values) => setState(() => _conditionValues = values),
          onCarryItemChanged: (values) => setState(() => _carryItemValues = values),
        );
      case 2:
        return BlocBuilder<GetStallsCubit, GetStallsState>(
          builder: (context, stallState) {
            return BlocBuilder<GetMechanicsCubit, GetMechanicsState>(
              builder: (context, mechanicState) {
                if (stallState is GetStallsLoading || mechanicState is GetMechanicsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return NotesAndOthersStep(
                  formKey: _notesFormKey,
                  serviceTypeController: _serviceTypeController,
                  notesController: _notesController,
                  mechanicController: _mechanicController,
                  isTradeIn: _isTradeIn,
                  stallController: _stallController,
                  sourceController: _sourceController,
                  onTradeInChanged: (value) => setState(() => _isTradeIn = value ?? false),
                  stallState: stallState,
                  mechanicState: mechanicState,
                );
              },
            );
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
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep -= 1),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Kembali', style: TextStyle(color: AppColors.primary)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _handleNextOrSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                _currentStep == 2 ? 'Simpan' : 'Selanjutnya',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateVehicleConditions() {
    final bool hasEmptySelection = _conditionValues.values.any((value) => value.isEmpty);
    if (hasEmptySelection) {
      return false;
    }
    return true;
  }

  void _handleNextOrSubmit() {
    bool isStepValid = false;
    if (_currentStep == 0) {
      isStepValid = _identityFormKey.currentState?.validate() ?? false;
    } else if (_currentStep == 1) {
      isStepValid = _validateVehicleConditions();
    } else if (_currentStep == 2) {
      isStepValid = _notesFormKey.currentState?.validate() ?? false;
    }

    if (!isStepValid) {
      Utils.showWarningSnackBar(context, 'Harap isi semua data yang wajib diisi pada langkah ini.');
      return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
    } else {
      _showConfirmationDialog();
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(ImageResources.icWarning, width: 100),
              const SizedBox(height: 16),
              Text('Konfirmasi Tambah Customer', style: AppTextStyles.subtitle2.copyWith(color: AppColors.textPrimary), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('Silahkan Klik Ya, jika data customer Anda telah sesuai', style: TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Batal', style: AppTextStyles.subtitle2.copyWith(color: AppColors.textPrimary)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _submitDataToApi();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Ya', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
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
    final luggageData = {
      'luggage_stnk': _carryItemValues['STNK']! ? 'Ya' : 'Tidak',
      'luggage_booklet': _carryItemValues['Booklet']! ? 'Ya' : 'Tidak',
      'luggage_toolset': _carryItemValues['Toolset']! ? 'Ya' : 'Tidak',
      'luggage_umbrella': _carryItemValues['Payung']! ? 'Ya' : 'Tidak',
      'luggage_money': _carryItemValues['Uang']! ? 'Ya' : 'Tidak',
      'luggage_p3k': _carryItemValues['Kotak P3K']! ? 'Ya' : 'Tidak',
      'luggage_triangle_protection': _carryItemValues['Segitiga Pengaman']! ? 'Ya' : 'Tidak',
    };

    final bodyConditionData = <String, String>{};
    _conditionValues.forEach((key, value) {
      if (key.startsWith('body_')) {
        final newKey = 'bodyCondition_${key.substring(5)}';
        bodyConditionData[newKey] = value;
      }
    });

    final Map<String, dynamic> customerData = {
      'chassisNumber': _frameNumberController.text,
      'name': _nameController.text,
      'birthDate': _dobController.text,
      'phone': _whatsappController.text,
      'plateNumber': _plateNumberController.text,
      'typeId': _vehicleTypeController.text,
      'year': _vehicleYearController.text,
      'insurance': _insuranceController.text,
      'address': _addressController.text,
      'mToyota': _hasMToyotaApp ? '1' : '0',
      'source': _sourceController.text,
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
      // --- PERUBAHAN: Logika default untuk serviceType ---
      'serviceType': _serviceTypeController.text.isNotEmpty ? _serviceTypeController.text : 'Lainnya',
      'note': _notesController.text.isNotEmpty ? _notesController.text : '-',
      'tradeIn': _isTradeIn ? 'Ya' : 'Tidak',
      'StallId': _stallController.text,
      'MechanicId': _mechanicController.text,
    };

    customerData.removeWhere((key, value) => value == null || (value is String && value.isEmpty && key != 'mToyota' && key != 'tradeIn'));
    context.read<AddCustomerCubit>().submitCustomerData(customerData);
  }
}