class Challenge {
  int id;
  int gameSessionId;
  int challengerId;
  int challengedId;
  String startTime;
  String endTime;
  String isResolved;
  String firstWord;
  String secondWord;
  String thirdWord;
  String fourthWord;
  String forbiddenWords;
  String imagePath;
  String previousImages;
  String proposals;
  String createdAt;
  String updatedAt;
  String fifthWord;
  String prompt;

  Challenge({
    required this.id,
    required this.gameSessionId,
    required this.challengerId,
    required this.challengedId,
    required this.startTime,
    required this.endTime,
    required this.isResolved,
    required this.firstWord,
    required this.secondWord,
    required this.thirdWord,
    required this.fourthWord,
    required this.forbiddenWords,
    required this.imagePath,
    required this.previousImages,
    required this.proposals,
    required this.createdAt,
    required this.updatedAt,
    required this.fifthWord,
    required this.prompt,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      gameSessionId: json['game_session_id'],
      challengerId: json['challenger_id'],
      challengedId: json['challenged_id'],
      startTime: json['start_time'] ?? "",
      endTime: json['end_time'] ?? "",
      isResolved: json['is_resolved'] ?? "",
      firstWord: json['first_word'] ?? "",
      secondWord: json['second_word'] ?? "",
      thirdWord: json['third_word'] ?? "",
      fourthWord: json['fourth_word'] ?? "",
      forbiddenWords: json['forbidden_words'] ?? "",
      imagePath: json['image_path'] ?? "",
      previousImages: json['previous_images'] ?? "",
      proposals: json['proposals'] ?? "",
      createdAt: json['created_at'] ?? "",
      updatedAt: json['updated_at'] ?? "",
      fifthWord: json['fifth_word'] ?? "",
      prompt: json['prompt'] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'game_session_id': gameSessionId,
        'challenger_id': challengerId,
        'challenged_id': challengedId,
        'start_time': startTime,
        'end_time': endTime,
        'is_resolved': isResolved,
        'first_word': firstWord,
        'second_word': secondWord,
        'third_word': thirdWord,
        'fourth_word': fourthWord,
        'forbidden_words': forbiddenWords,
        'image_path': imagePath,
        'previous_images': previousImages,
        'proposals': proposals,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'fifth_word': fifthWord,
        'prompt': prompt,
      };
}
