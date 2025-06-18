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
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}