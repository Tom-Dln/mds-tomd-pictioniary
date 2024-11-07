class TeamMember {
  int id;
  String name;
  String type;

  TeamMember({required this.id, required this.name, this.type = "red"});

  factory TeamMember.fromJson(Map<String, dynamic> json, String type) {
    return TeamMember(
      id: json['id'],
      name: json['name'],
      type: type,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
      };
}
