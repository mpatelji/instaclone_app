
class UserModel {
  String? id;

  List<String>? followers;
  List<String>? following;

  UserModel({
    this.id,
    this.followers,
    this.following,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["id"],
        followers: json["followers"] == null
            ? []
            : List<String>.from(json["followers"]!.map((x) => x)),
        following: json["following"] == null
            ? []
            : List<String>.from(json["following"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "followers": followers == null
            ? []
            : List<dynamic>.from(followers!.map((x) => x)),
        "following": following == null
            ? []
            : List<dynamic>.from(following!.map((x) => x)),
      };
}
