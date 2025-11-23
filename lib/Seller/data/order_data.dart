class OrderData {
  final String title;
  final String date;
  final String price;
  final int quantity;
  final String imageAsset;

  OrderData({
    required this.title,
    required this.date,
    required this.price,
    required this.quantity,
    required this.imageAsset,
  });
}

List<OrderData> orders = [
  OrderData(
    title: "DAP (SONA)",
    date: "10/05/2025",
    price: "Rs. 4000",
    quantity: 3,
    imageAsset: "assets/images/dap.png",
  ),
  OrderData(
    title: "Sarsabz Urea",
    date: "10/05/2025",
    price: "Rs. 5000",
    quantity: 5,
    imageAsset: "assets/images/sarsabz_urea.png",
  ),
  OrderData(
    title: "SOP Fertilizer",
    date: "10/05/2025",
    price: "Rs. 4300",
    quantity: 2,
    imageAsset: "assets/images/sarsabz_slopi.png",
  ),
];
