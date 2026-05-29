import 'package:e_learning_v1/core/config/network_config.dart';


class CourseModel {
  final String id;
  final String title;
  final String description;


  final String imageUrl;

 
  final bool isFree;
  final double price;
  bool isEnrolled;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl = "",
    this.isFree = true,
    this.price = 0,
    this.isEnrolled = false,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    // Backend field names may differ from mock data.
    final id = json["id"] ?? json["_id"];
    final title = json["title"] ?? json["Coursename"] ?? json["courseName"] ?? "";
    final description = json["description"] ?? json["Coursedescription"] ?? "";
    var imageUrl = json["imageUrl"] ?? json["coursethumbnail"] ?? "";
    
  
    // Use NetworkConfig to correct image URL
    // This ensures localhost is replaced with computer IP

    imageUrl = NetworkConfig.getImageUrl(imageUrl);

    final hasPrice = json.containsKey("price") || json.containsKey("CoursePrice");
    final priceValue = json["price"] ?? json["CoursePrice"];
    final price = (priceValue is num)
        ? priceValue.toDouble()
        : double.tryParse(priceValue?.toString() ?? "") ?? 0.0;

    // Only treat a course as free when it is explicitly marked free, or when a
    // price is provided and it is zero.
    final isFree = (json["isFree"] ?? false) || (hasPrice && price == 0);

    return CourseModel(
      id: id.toString(),
      title: title,
      description: description,
      imageUrl: imageUrl,
      isFree: isFree,
      price: price,
      isEnrolled: json["isEnrolled"] ?? false,
    );
  }
}