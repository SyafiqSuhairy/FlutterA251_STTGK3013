class Pet {
  String? petId;
  String? userId;
  String? petName;
  String? petType;
  String? category;      
  String? description;
  String? petStatus;     
  int? needsDonation; 
  String? lat;
  String? lng;
  String? dateReg;
  List<String>? imagePaths; 
  String? firstImage;
  String? userName;
  String? userPhone;
  String? userProfile;

  Pet({
    this.petId,
    this.userId,
    this.petName,
    this.petType,
    this.category,
    this.description,
    this.petStatus,
    this.needsDonation,
    this.lat,
    this.lng,
    this.dateReg,
    this.imagePaths,
    this.firstImage,
    this.userName,
    this.userPhone,
    this.userProfile,
  });

  Pet.fromJson(Map<String, dynamic> json) {
    petId = json['pet_id'];
    userId = json['user_id'];
    petName = json['pet_name'];
    petType = json['pet_type'];
    category = json['category'];
    description = json['description'];
    petStatus = json['pet_status'];
    // Safely parse needs_donation from both String and Int input
    needsDonation = int.tryParse(json['needs_donation'].toString()) ?? 0;
    lat = json['lat'];
    lng = json['lng'];
    dateReg = json['date_reg'];

    // Handle 'image_paths' from your Database
    if (json['image_paths'] != null && json['image_paths'].toString().isNotEmpty) {
       // Split "pet1.png,pet2.png" into ["pet1.png", "pet2.png"]
       imagePaths = json['image_paths'].toString().split(',');
       // Set the first image for the main card view
       firstImage = imagePaths![0];
    } else {
       imagePaths = [];
       firstImage = "default_pet.png"; 
    }

    userName = json['user_name'];
    userPhone = json['user_phone'];
    userProfile = json['profile_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pet_id'] = petId;
    data['user_id'] = userId;
    data['pet_name'] = petName;
    data['pet_type'] = petType;
    data['category'] = category;
    data['description'] = description;
    data['pet_status'] = petStatus;
    data['needs_donation'] = needsDonation;
    data['lat'] = lat;
    data['lng'] = lng;
    data['date_reg'] = dateReg;
    data['image_paths'] = imagePaths?.join(','); 
    data['user_name'] = userName;
    data['user_phone'] = userPhone;
    data['profile_image'] = userProfile;
    
    return data;
  }
}