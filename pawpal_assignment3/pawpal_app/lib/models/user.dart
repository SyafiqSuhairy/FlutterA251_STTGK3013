class User {
  String? userId;
  String? email;
  String? name;
  String? phone;
  String? password;
  String? regDate;
  String? profileImage; 

  User({
    this.userId,
    this.email,
    this.name,
    this.phone,
    this.password,
    this.regDate,
    this.profileImage,
  });

  User.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    email = json['email'];
    name = json['name'];
    phone = json['phone'];
    password = json['password'];
    regDate = json['reg_date'];
    
    profileImage = json['profile_image']; 
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['email'] = email;
    data['name'] = name;
    data['phone'] = phone;
    data['password'] = password;
    data['reg_date'] = regDate;
    data['profile_image'] = profileImage;
    return data;
  }
}