import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
import 'package:kalla_u_pro_bengkel/common/app_text_styles.dart';
import 'package:kalla_u_pro_bengkel/common/image_resources.dart';
import 'package:kalla_u_pro_bengkel/features/home/presentation/pages/add_customer_screen.dart';
enum SnackBarType {
  success,
  error,
  warning,
  info, 
}
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
      extendedPadding: const EdgeInsets.symmetric(horizontal: 12,vertical: 1),
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

  static void showCustomSnackBar(
    BuildContext context, {
    required String message,
    required SnackBarType type,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    // Sembunyikan SnackBar yang mungkin sedang aktif
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    Color backgroundColor;
    IconData? iconData;
    Color iconColor = Colors.white;
    Color textColor = Colors.white;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = AppColors.primary; // Menggunakan primary untuk success
        iconData = Icons.check_circle_outline;
        break;
      case SnackBarType.error:
        backgroundColor = AppColors.error;
        iconData = Icons.error_outline;
        break;
      case SnackBarType.warning:
        backgroundColor = AppColors.secondary; // Menggunakan orange untuk warning
        iconData = Icons.warning_amber_outlined;
        // Untuk orange, teks hitam mungkin lebih kontras
        textColor = AppColors.textPrimary;
        iconColor = AppColors.textPrimary;
        break;
      case SnackBarType.info:
        backgroundColor = AppColors.blueLight; // Menggunakan blueLight untuk info
        iconData = Icons.info_outline;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (iconData != null) Icon(iconData, color: iconColor),
            if (iconData != null) const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.body1.copyWith(color: textColor), // Sesuaikan dengan text style Anda
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating, // Membuat SnackBar mengambang (opsional)
        shape: RoundedRectangleBorder( // Memberi sudut membulat (opsional)
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(10), // Margin jika behavior floating (opsional)
      ),
    );
  }

  // Fungsi helper untuk penggunaan yang lebih mudah
  static void showSuccessSnackBar(BuildContext context, String message, {Duration? duration, SnackBarAction? action}) {
    showCustomSnackBar(context, message: message, type: SnackBarType.success, duration: duration ?? const Duration(seconds: 3), action: action);
  }

  static void showErrorSnackBar(BuildContext context, String message, {Duration? duration, SnackBarAction? action}) {
    showCustomSnackBar(context, message: message, type: SnackBarType.error, duration: duration ?? const Duration(seconds: 4), action: action);
  }

  static void showWarningSnackBar(BuildContext context, String message, {Duration? duration, SnackBarAction? action}) {
    showCustomSnackBar(context, message: message, type: SnackBarType.warning, duration: duration ?? const Duration(seconds: 4), action: action);
  }

   static void showInfoSnackBar(BuildContext context, String message, {Duration? duration, SnackBarAction? action}) {
    showCustomSnackBar(context, message: message, type: SnackBarType.info, duration: duration ?? const Duration(seconds: 3), action: action);
  }
}

