import 'package:json_annotation/json_annotation.dart';

part 'organization.g.dart';

/// Organization data synchronized with the Django REST Framework API.
@JsonSerializable(fieldRename: FieldRename.snake)
class Organization {
  const Organization({
    required this.title,
    required this.category,
    this.id,
    this.desc1,
    this.desc2,
    this.desc3,
    this.thumbnail,
    this.startedAt,
    this.endedAt,
    this.starCount = 0,
    this.isStarred = false,
    this.starredByNames = '',
  });

  factory Organization.fromJson(Map<String, dynamic> json) =>
      _$OrganizationFromJson(json);

  /// Generated UUID assigned by Django.
  @JsonKey(includeToJson: false)
  final String? id;

  final String title;
  final String category;

  @JsonKey(name: 'desc_1')
  final String? desc1;

  @JsonKey(name: 'desc_2')
  final String? desc2;

  @JsonKey(name: 'desc_3')
  final String? desc3;

  final String? thumbnail;
  final DateTime? startedAt;
  final DateTime? endedAt;

  /// These fields are calculated by the backend.
  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;

  @JsonKey(includeToJson: false, defaultValue: false)
  final bool isStarred;

  @JsonKey(includeToJson: false, defaultValue: '')
  final String starredByNames;

  Map<String, dynamic> toJson() => _$OrganizationToJson(this);
}
