// lib/features/services/data/service_model.dart

class Service {
  final String id;
  final String name;
  final String description;
  final int price;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  factory Service.fromMap(Map<String, dynamic> map, String id) {
    return Service(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? 0,
    );
  }
}
