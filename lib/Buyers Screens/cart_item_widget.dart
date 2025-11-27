import 'package:flutter/material.dart';

class CartItem {
  final String name;
  final String brand;
  final String weight;
  final double price;
  final String imageUrl;
  int quantity;
  bool isSelected;

  CartItem({
    required this.name,
    required this.brand,
    required this.weight,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
    this.isSelected = true,
  });

  double get itemTotalPrice => price * quantity;
}

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final VoidCallback? onDelete;
  final ValueChanged<bool?>? onSelected;

  const CartItemWidget({
    super.key,
    required this.item,
    this.onAdd,
    this.onRemove,
    this.onDelete,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(blurRadius: 6, offset: Offset(0, 2), color: Colors.black12),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: item.isSelected,
                      onChanged: onSelected,
                      activeColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child:
                        item.imageUrl.isEmpty
                            ? Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.shopping_bag,
                                size: 40,
                                color: Colors.grey,
                              ),
                            )
                            : item.imageUrl.startsWith('http')
                            ? Image.network(
                              item.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            )
                            : Image.asset(
                              item.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.shopping_bag,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.brand,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.weight,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _roundIconButton(
                              Icons.remove,
                              onPressed: item.quantity > 1 ? onRemove : null,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 8),
                            _roundIconButton(Icons.add, onPressed: onAdd),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Rs.${item.itemTotalPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 0.1,
            right: 0.1,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 18,
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIconButton(IconData icon, {VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onPressed == null ? Colors.grey : Colors.black,
        ),
      ),
    );
  }
}
