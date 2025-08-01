class TelegramUser {
  final String id;
  final String firstName;
  final String? lastName;
  final String? username;
  final String? photoUrl;
  final String? authDate;
  final String? hash;

  TelegramUser({
    required this.id,
    required this.firstName,
    this.lastName,
    this.username,
    this.photoUrl,
    this.authDate,
    this.hash,
  });

  factory TelegramUser.fromJson(Map<String, dynamic> json) {
    return TelegramUser(
      id: json['id'].toString(),
      firstName: json['first_name'],
      lastName: json['last_name'],
      username: json['username'],
      photoUrl: json['photo_url'],
      authDate: json['auth_date'],
      hash: json['hash'],
    );
  }
}