import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
import 'package:kalla_u_pro_bengkel/common/app_text_styles.dart';
import 'package:kalla_u_pro_bengkel/common/image_resources.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/customer_identity_step.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/notes_and_other_step.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/widgets/vehicle_condition_step.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  // Current step index
  int _currentStep = 0;
  
  // Form keys for each step
  final _identityFormKey = GlobalKey<FormState>();
  final _conditionFormKey = GlobalKey<FormState>();
  final _notesFormKey = GlobalKey<FormState>();
  
  // Controllers and data for customer identity (Step 1)
  final _plateNumberController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _vehicleYearController = TextEditingController();
  final _addressController = TextEditingController();
  final _insuranceController = TextEditingController();
  bool _hasMToyotaApp = false;
  
  // Data for vehicle condition (Step 2)
  // Updated to use maps for easier state management
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
  
  // Controllers and data for notes and others (Step 3)
  final _serviceTypeController = TextEditingController();
  final _notesController = TextEditingController();
  final _mechanicController = TextEditingController();
  bool _isTradeIn = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize default values for condition
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
    
    // Initialize body condition
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
    // Dispose all controllers
    _plateNumberController.dispose();
    _vehicleTypeController.dispose();
    _vehicleYearController.dispose();
    _addressController.dispose();
    _insuranceController.dispose();
    _serviceTypeController.dispose();
    _notesController.dispose();
    _mechanicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leadingWidth: 21,
        title: const Text(
          'Tambah Customer',
          style: AppTextStyles.subtitle2
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Handle back navigation with consideration for current step
            if (_currentStep > 0) {
              setState(() {
                _currentStep -= 1;
              });
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Custom stepper indicator
          _buildStepperHeader(),
          
          // Main content area
          Expanded(
            child: _buildStepContent(),
          ),
          
          // Bottom navigation buttons
          _buildBottomButtons(),
        ],
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
          // Step 1
          _buildStepIndicator(
            step: 1,
            title: 'Identitas\nCustomer',
            isActive: _currentStep >= 0,
            isCompleted: _currentStep > 0,
          ),
          
          // Arrow 1
          _buildStepArrow(isActive: _currentStep > 0),
          
          // Step 2
          _buildStepIndicator(
            step: 2,
            title: 'Kondisi\nMobil',
            isActive: _currentStep >= 1,
            isCompleted: _currentStep > 1,
          ),
          
          // Arrow 2
          _buildStepArrow(isActive: _currentStep > 1),
          
          // Step 3
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
        // Circle with number or check
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
        // Step title
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
    // Use custom SVG assets for active and inactive states
    return SvgPicture.asset(
      isActive 
          ? ImageResources.icArrowActiveRight // Active arrow SVG
          : ImageResources.icArrowInactiveRight, // Inactive arrow SVG
      width: 24,
      height: 24,
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return CustomerIdentityStep(
          formKey: _identityFormKey,
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
          // Back button (except for first step)
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
          
          // Next or Submit button
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _handleNextStep();
              },
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

  void _handleNextStep() {
    // Removed validation so the next button is always enabled
    if (_currentStep < 2) {
      // Move to next step regardless of validation
      setState(() {
        _currentStep += 1;
      });
    } else {
      // Submit the form
      _submitForm();
    }
  }
  
  void _submitForm() {
  // Show custom confirmation dialog
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
            // Custom icon with circular background
            SvgPicture.asset(
              ImageResources.icWarning,
              width: 100,
              ),
            const SizedBox(height: 16),
            
            // Title
             Text(
              'Konfirmasi Tambah Customer',
              style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textPrimary
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            const Text(
              'Silahkan Klik Ya, jika data customer Anda telah sesuai',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Batal button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child:  Text(
                      'Batal',
                      style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textPrimary
              ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Ya button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Close dialog
                      Navigator.pop(context);
                      // Save data and return to previous screen
                      _saveCustomerData();
                      context.pop();
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
  
    void _saveCustomerData() {
    // Collect all data and save
    final customerData = {
      // Step 1: Customer Identity
      'plateNumber': _plateNumberController.text,
      'vehicleType': _vehicleTypeController.text,
      'vehicleYear': _vehicleYearController.text,
      'address': _addressController.text,
      'insurance': _insuranceController.text,
      'hasMToyotaApp': _hasMToyotaApp,
      
      // Step 2: Vehicle Condition
      'conditionValues': _conditionValues,
      'carryItemValues': _carryItemValues,
      
      // Step 3: Notes and Others
      'serviceType': _serviceTypeController.text,
      'notes': _notesController.text,
      'mechanic': _mechanicController.text,
      'isTradeIn': _isTradeIn,
    };
    
    // TODO: Implement the actual saving logic
    print('Saving customer data: $customerData');
  }
}