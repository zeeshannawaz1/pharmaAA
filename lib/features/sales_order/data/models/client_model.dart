class ClientModel {
  final String clientCode;
  final String clientName;
  final String clientAdd;
  final String city;
  final String area;

  ClientModel({
    required this.clientCode,
    required this.clientName,
    required this.clientAdd,
    required this.city,
    required this.area,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      clientCode: json['CLIENTCODE'] as String,
      clientName: json['CLIENTNAME'] as String,
      clientAdd: json['CLIENTADD'] as String,
      city: json['CITY'] as String? ?? '',
      area: json['AREA'] as String? ?? '',
    );
  }
} 
