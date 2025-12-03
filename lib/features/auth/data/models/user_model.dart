import 'package:aa_app/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.userId,
    required super.userName,
    required super.prCode,
    required super.prgCode,
    required super.pinCode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['USERID'] ?? '',
      userName: json['USERNAME'] ?? '',
      prCode: json['PRCODE'] ?? '',
      prgCode: json['PRGCODE'] ?? '',
      pinCode: json['PINCODE'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'USERID': userId,
      'USERNAME': userName,
      'PRCODE': prCode,
      'PRGCODE': prgCode,
      'PINCODE': pinCode,
    };
  }
} 
