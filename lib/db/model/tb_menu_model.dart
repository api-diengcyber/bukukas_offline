enum MenuType {
  pemasukan,
  pengeluaran,
  hutang,
  piutang,
}

class TbMenuModel {
  String? name;
  MenuType? type;
  String? notes;
  String? defaultValue;
  String? total;
  String? paid;
  String? deadline;
  String? statusPaidOff;
  String? createdOn;

  TbMenuModel({
    this.name,
    this.type,
    this.notes,
    this.defaultValue,
    this.total,
    this.paid,
    this.deadline,
    this.statusPaidOff,
    this.createdOn,
  });
}
