import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
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
  
  // Controllers and data for vehicle condition (Step 2)
  String _engineCondition = '';
  String _floorMatCondition = '';
  String _driverFloorMat = '';
  String _tireFRCondition = '';
  
  // Controllers and data for notes and others (Step 3)
  final _serviceTypeController = TextEditingController();
  final _notesController = TextEditingController();
  final _mechanicController = TextEditingController();
  bool _isTradeIn = false;
  
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
        title: const Text(
          'Tambah Customer',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
          engineCondition: _engineCondition,
          floorMatCondition: _floorMatCondition,
          driverFloorMat: _driverFloorMat,
          tireFRCondition: _tireFRCondition,
          onEngineConditionChanged: (value) {
            setState(() {
              _engineCondition = value ?? '';
            });
          },
          onFloorMatConditionChanged: (value) {
            setState(() {
              _floorMatCondition = value ?? '';
            });
          },
          onDriverFloorMatChanged: (value) {
            setState(() {
              _driverFloorMat = value ?? '';
            });
          },
          onTireFRConditionChanged: (value) {
            setState(() {
              _tireFRCondition = value ?? '';
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
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Penyimpanan'),
        content: const Text(
          'Apakah Anda yakin ingin menyimpan data customer ini? '
          'Pastikan semua informasi yang Anda masukkan sudah benar.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              // Close dialog
              Navigator.pop(context);
              // Save data and return to previous screen
              _saveCustomerData();
              context.pop();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
  
  void _saveCustomerData() {
    // Collect all data and save
    final customerData = {
      'plateNumber': _plateNumberController.text,
      'vehicleType': _vehicleTypeController.text,
      'vehicleYear': _vehicleYearController.text,
      'address': _addressController.text,
      'insurance': _insuranceController.text,
      'hasMToyotaApp': _hasMToyotaApp,
      'engineCondition': _engineCondition,
      'floorMatCondition': _floorMatCondition,
      'driverFloorMat': _driverFloorMat,
      'tireFRCondition': _tireFRCondition,
      'serviceType': _serviceTypeController.text,
      'notes': _notesController.text,
      'mechanic': _mechanicController.text,
      'isTradeIn': _isTradeIn,
    };
    
    // TODO: Implement the actual saving logic
    print('Saving customer data: $customerData');
  }
}