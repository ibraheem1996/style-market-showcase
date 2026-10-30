class UserEntity {
  final int? userId;
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final int? userVerify;
  final int? userApprove;
  final String? userType;
  final String? userCreatedAt;

  UserEntity({
    this.userId,
    this.userName,
    this.userEmail,
    this.userPhone = "",
    this.userVerify = 0,
    this.userApprove = 0,
    this.userType = "",
    this.userCreatedAt = "",
  });
}
