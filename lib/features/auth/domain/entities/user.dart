import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String userId;
  final String userName;
  final String prCode;
  final String prgCode;
  final String pinCode;

  const User({
    required this.userId,
    required this.userName,
    required this.prCode,
    required this.prgCode,
    required this.pinCode,
  });

  @override
  List<Object?> get props => [userId, userName, prCode, prgCode, pinCode];
} 
