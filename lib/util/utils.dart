import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
import 'package:kalla_u_pro_bengkel/common/app_text_styles.dart';

class Utils {
    static FloatingActionButton buildFloatingActionButton({
    required VoidCallback onPressed,
  }) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: SvgPicture.asset(
        'assets/icons/ic_add.svg',
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
}

