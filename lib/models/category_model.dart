class Category {
  String id;
  String categoryImage;
  String categoryName;

  Category({
    required this.id,
    required this.categoryImage,
    required this.categoryName,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryImage': categoryImage,
      'categoryName': categoryName,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      categoryImage: map['categoryImage'] as String,
      categoryName: map['categoryName'] as String,
    );
  }
}
