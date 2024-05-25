import 'dart:convert';

enum MenuType {
// ignore: constant_identifier_names
  Pemasukan,
// ignore: constant_identifier_names
  Pengeluaran,
// ignore: constant_identifier_names
  Hutang,
// ignore: constant_identifier_names
  Piutang,
}

List<TbMenuModel> tbMenuModelFromJson(String str) => List<TbMenuModel>.from(
    json.decode(str).map((x) => TbMenuModel.fromJson(x)));

String tbMenuModelToJson(List<TbMenuModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TbMenuModel {
  int? id;
  String? name;
  String? type;
  String? notes;
  String? defaultValue;
  String? total;
  String? paid;
  String? deadline;
  String? statusPaidOff;
  String? createdOn;
  int? totalTransaction;

  TbMenuModel({
    this.id,
    this.name,
    this.type,
    this.notes,
    this.defaultValue,
    this.total,
    this.paid,
    this.deadline,
    this.statusPaidOff,
    this.createdOn,
    this.totalTransaction,
  });

  factory TbMenuModel.fromJson(Map<String, dynamic> json) => TbMenuModel(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        notes: json["notes"],
        defaultValue: json["defaultValue"],
        total: json["total"],
        paid: json["paid"],
        deadline: json["deadline"],
        statusPaidOff: json["statusPaidOff"],
        createdOn: json["createdOn"],
        totalTransaction: json["totalTransaction"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "notes": notes,
        "defaultValue": defaultValue,
        "total": total,
        "paid": paid,
        "deadline": deadline,
        "statusPaidOff": statusPaidOff,
        "createdOn": createdOn,
        "totalTransaction": totalTransaction,
      };
}
