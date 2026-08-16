import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/models/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}

extension UserModelMapper on UserModel {
  User toDomain() => User(id: id, email: email, name: '$firstName $lastName'.trim());
}
