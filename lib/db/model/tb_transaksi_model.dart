class TbTransaksiModel {
  int? id;
  String? transactionDate;
  String? notes; // Ini catatan transaksi
  String? valueIn;
  String? valueOut;
  String? debtType;
  String? createdOn;
  String? allowDelete;
  int? menuId;
  String? menuName;
  String? menuType;
  String? menuDeadline;
  String? menuNotes; // <--- TAMBAHKAN INI (Catatan dari tabel Menu)
  int? bukukasId;

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
    this.menuName,
    this.menuType,
    this.menuDeadline,
    this.menuNotes, // <--- Masukkan ke constructor
    this.bukukasId,
  });

  factory TbTransaksiModel.fromJson(Map<String, dynamic> json) => TbTransaksiModel(
        id: json["id"],
        transactionDate: json["transactionDate"],
        notes: json["notes"],
        valueIn: json["valueIn"],
        valueOut: json["valueOut"],
        debtType: json["debtType"],
        createdOn: json["createdOn"],
        allowDelete: json["allowDelete"],
        menuId: json["menuId"],
        menuName: json["menuName"],
        menuType: json["menuType"],
        menuDeadline: json["menuDeadline"],
        menuNotes: json["menuNotes"], // <--- Ambil dari hasil Join SQL
        bukukasId: json["bukukasId"] != null ? int.tryParse(json["bukukasId"].toString()) : null,
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
        "menuName": menuName,
        "menuType": menuType,
        "menuDeadline": menuDeadline,
        "menuNotes": menuNotes,
        "bukukasId": bukukasId,
      };
}