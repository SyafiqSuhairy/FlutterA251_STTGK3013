class Pet {
  String? petId;
  String? userId;
  String? petName;
  String? petType;
  String? category;
  String? description;
  List<String>? imagePaths;
  String? lat;
  String? lng;
  String? dateReg;

  Pet({
    this.petId,
    this.userId,
    this.petName,
    this.petType,
    this.category,
    this.description,
    this.imagePaths,
    this.lat,
    this.lng,
    this.dateReg,
  });

  Pet.fromJson(Map<String, dynamic> json) {
    petId = json['pet_id'];
    userId = json['user_id'];
    petName = json['pet_name'];
    petType = json['pet_type'];
    category = json['category'];
    description = json['description'];
    
    if (json['image_paths'] != null && json['image_paths'].toString().isNotEmpty) {
      imagePaths = json['image_paths'].toString().split(',');
    } else {
      imagePaths = [];
    }

    lat = json['lat'];
    lng = json['lng'];
    dateReg = json['date_reg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pet_id'] = petId;
    data['user_id'] = userId;
    data['pet_name'] = petName;
    data['pet_type'] = petType;
    data['category'] = category;
    data['description'] = description;
    
    // Join the list back into a string if we ever need to send it back
    data['image_paths'] = imagePaths?.join(',');
    
    data['lat'] = lat;
    data['lng'] = lng;
    data['date_reg'] = dateReg;
    return data;
  }
}