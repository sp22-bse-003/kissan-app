import 'package:flutter/material.dart';
import 'package:kissan/core/widgets/tts_icon_button.dart';

Widget OrderCard({
  required String title,
  required String date,
  required String price,
  required int quantity,
  required String imageUrl,
  required VoidCallback onApprove,
  required VoidCallback onReject,
}) {
  return Card(
    surfaceTintColor: Colors.white,
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: Colors.grey[200],
                width: 120,
                height: 120,
                child:
                    imageUrl.isNotEmpty
                        ? Image.asset(
                          imageUrl,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.shopping_bag,
                                color: Colors.grey,
                                size: 48,
                              ),
                            );
                          },
                        )
                        : const Icon(
                          Icons.shopping_bag,
                          color: Colors.grey,
                          size: 48,
                        ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "$date - $price",
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 15),
                Text("$quantity items", style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TtsIconButton(text: title, iconSize: 24),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: onApprove,
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: onReject,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
