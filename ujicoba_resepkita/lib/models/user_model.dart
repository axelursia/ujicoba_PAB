class User {
  String id;
  String username;
  String email;
  String profilePicture;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.profilePicture,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      profilePicture: map['profilePicture'],
    );
  }
}
