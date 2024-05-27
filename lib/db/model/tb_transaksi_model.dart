// To parse this JSON data, do
//
//     final tbTransaksiModel = tbTransaksiModelFromJson(jsonString);

import 'dart:convert';

List<TbTransaksiModel> tbTransaksiModelFromJson(String str) =>
    List<TbTransaksiModel>.from(
        json.decode(str).map((x) => TbTransaksiModel.fromJson(x)));

String tbTransaksiModelToJson(List<TbTransaksiModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TbTransaksiModel {
  int? id;
  String? transactionDate;
  String? notes;
  String? valueIn;
  String? valueOut;
  String? debtType;
  String? createdOn;
  String? allowDelete;
  int? menuId;
  String? menuType;
  String? menuName;
  String? menuNotes;
  String? menuDeadline;

  TbTransaksiModel({
    this.id,
    this.transactionDate,
    this.notes,
    this.valueIn,
    this.valueOut,
    this.debtType,
    this.createdOn,
    this.allowDelete,
    this.menuId,
    this.menuType,
    this.menuName,
    this.menuNotes,
    this.menuDeadline,
  });

  factory TbTransaksiModel.fromJson(Map<String, dynamic> json) =>
      TbTransaksiModel(
        id: json["id"],
        transactionDate: json["transactionDate"],
        notes: json["notes"],
        valueIn: json["valueIn"],
        valueOut: json["valueOut"],
        debtType: json["debtType"],
        createdOn: json["createdOn"],
        allowDelete: json["allowDelete"],
        menuId: json["menuId"],
        menuType: json["menuType"],
        menuName: json["menuName"],
        menuNotes: json["menuNotes"],
        menuDeadline: json["menuDeadline"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "transactionDate": transactionDate,
        "notes": notes,
        "valueIn": valueIn,
        "valueOut": valueOut,
        "debtType": debtType,
        "createdOn": createdOn,
        "allowDelete": allowDelete,
        "menuId": menuId,
        "menuType": menuType,
        "menuName": menuName,
        "menuNotes": menuNotes,
        "menuDeadline": menuDeadline,
      };
}
