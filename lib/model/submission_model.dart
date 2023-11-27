class Submission {
  final int id;
  final String request;
  final String respon;

  Submission({required this.id, required this.request, required this.respon});

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'],
      request: json['submission_request']['text'],
      respon: json['text'],
    );
  }
}
