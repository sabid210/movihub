class UserModel {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final List<String> favourites;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl = '',
    this.favourites = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid:        json['uid'] ?? '',
      name:       json['name'] ?? '',
      email:      json['email'] ?? '',
      photoUrl:   json['photoUrl'] ?? '',
      favourites: List<String>.from(json['favourites'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid':        uid,
        'name':       name,
        'email':      email,
        'photoUrl':   photoUrl,
        'favourites': favourites,
      };

  UserModel copyWith({
    String? name,
    String? photoUrl,
    List<String>? favourites,
  }) {
    return UserModel(
      uid:        uid,
      name:       name ?? this.name,
      email:      email,
      photoUrl:   photoUrl ?? this.photoUrl,
      favourites: favourites ?? this.favourites,
    );
  }
}