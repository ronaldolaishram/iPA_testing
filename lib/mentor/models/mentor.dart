class Mentor {
  final String id;
  final String name;
  final String email;
  final String profession;
  final String company;
  final String experience;
  final List<String> expertise;
  final String about;
  final List<String> education;
  final List<String> certifications;
  final int menteesEngaged;
  final int networkSize;
  final int contributions;
  final String? profileImageUrl;

  Mentor({
    required this.id,
    required this.name,
    required this.email,
    required this.profession,
    required this.company,
    required this.experience,
    required this.expertise,
    required this.about,
    required this.education,
    required this.certifications,
    required this.menteesEngaged,
    required this.networkSize,
    required this.contributions,
    this.profileImageUrl,
  });

  factory Mentor.fromMap(Map<String, dynamic> data, String id) {
    return Mentor(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profession: data['profession'] ?? '',
      company: data['company'] ?? '',
      experience: data['experience'] ?? '',
      expertise: List<String>.from(data['expertise'] ?? []),
      about: data['about'] ?? '',
      education: List<String>.from(data['education'] ?? []),
      certifications: List<String>.from(data['certifications'] ?? []),
      menteesEngaged: data['menteesEngaged'] ?? 0,
      networkSize: data['networkSize'] ?? 0,
      contributions: data['contributions'] ?? 0,
      profileImageUrl: data['profileImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profession': profession,
      'company': company,
      'experience': experience,
      'expertise': expertise,
      'about': about,
      'education': education,
      'certifications': certifications,
      'menteesEngaged': menteesEngaged,
      'networkSize': networkSize,
      'contributions': contributions,
      'profileImageUrl': profileImageUrl,
    };
  }
}