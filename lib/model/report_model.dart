class Report {
  final int id;
  final String description;
  final String commentText;
  final String newsTtile;

  Report({required this.id, required this.description, required this.commentText,required this.newsTtile});

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      description: json['description'],
      commentText: json['comment']['text'],
      newsTtile: json['comment']['news']['title'],
    );
  }
}
