import 'package:flutter/material.dart';
import 'package:kalla_u_pro_bengkel/common/app_colors.dart';
import 'package:kalla_u_pro_bengkel/common/image_resources.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String imagePath;

  const EmptyStateWidget({
    Key? key,
    this.message = "Tidak ada pekerjaan yang tersedia saat ini.",
    this.imagePath = ImageResources.errorIcon, // Ganti dengan path aset Anda
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // FIX: This widget structure is correct. The centering issue is fixed in the parent
    // (MainScreen) by ensuring the parent container has a defined height, allowing
    // this Center widget to position its child in the vertical middle.
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 150,
            height: 150,
            color: Colors.grey[400], // Optional: beri warna pada gambar
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textGrey,
                height: 1.5, // Improve line spacing for multi-line messages
              ),
            ),
          ),
        ],
      ),
    );
  }
}
