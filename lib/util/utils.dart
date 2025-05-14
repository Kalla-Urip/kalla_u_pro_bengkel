import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
import 'package:kalla_u_pro_bengkel/common/app_text_styles.dart';
import 'package:kalla_u_pro_bengkel/common/image_resources.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/pages/add_customer_screen.dart';

class Utils {
    static FloatingActionButton buildFloatingActionButton({
    required VoidCallback onPressed,
  }) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: SvgPicture.asset(
        ImageResources.icAdd,
        width: 32,
        height: 32,
      ),
      label: const Text(
        "Tambah",
          style: AppTextStyles.subtitle3,
      ),
      extendedIconLabelSpacing: 8,
      isExtended: true,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: AppColors.primary,
      extendedPadding: EdgeInsets.symmetric(horizontal: 12,vertical: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100), // Adjust the radius here
      ),
    );
  }

    static Future<void> showCustomDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'OK',
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (onCancel != null) onCancel();
              },
              child: Text(cancelText),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onConfirm != null) onConfirm();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

