import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:keuangan/db/model/tb_transaksi_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ExportService {
  final formatCurrency = NumberFormat.simpleCurrency(locale: 'id_ID', decimalDigits: 0);

  // --- EXPORT KE EXCEL ---
  Future<void> exportToExcel(List<TbTransaksiModel> data) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Laporan Keuangan'];
    excel.delete('Sheet1');

    // Header
    sheetObject.appendRow([
      TextCellValue('Tanggal'),
      TextCellValue('Menu'),
      TextCellValue('Jenis'),
      TextCellValue('Keterangan'),
      TextCellValue('Masuk'),
      TextCellValue('Keluar'),
    ]);

    int grandTotal = 0;

    // Data
    for (var item in data) {
      int vIn = int.tryParse(item.valueIn ?? "0") ?? 0;
      int vOut = int.tryParse(item.valueOut ?? "0") ?? 0;
      grandTotal += (vIn - vOut);

      sheetObject.appendRow([
        TextCellValue(item.transactionDate?.split(' ')[0] ?? "-"),
        TextCellValue(item.menuName ?? "-"),
        TextCellValue(item.menuType ?? "-"),
        TextCellValue(item.notes ?? "-"),
        IntCellValue(vIn),
        IntCellValue(vOut),
      ]);
    }

    // Baris Total Saldo di Excel
    sheetObject.appendRow([
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue('TOTAL SALDO AKHIR'),
      TextCellValue(''),
      TextCellValue(grandTotal.toString()),
    ]);

    final directory = await getTemporaryDirectory();
    String filePath = "${directory.path}/Laporan_Keuangan_${DateTime.now().millisecondsSinceEpoch}.xlsx";
    
    var fileBytes = excel.encode();
    if (fileBytes != null) {
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

      await Share.shareXFiles([XFile(filePath)], text: 'Laporan Keuangan Excel');
    }
  }

  // --- EXPORT KE PDF ---
  Future<void> exportToPdf(List<TbTransaksiModel> data) async {
    final pdf = pw.Document();

    // 1. Hitung Grand Total terlebih dahulu
    int grandTotal = 0;
    for (var item in data) {
      int vIn = int.tryParse(item.valueIn ?? "0") ?? 0;
      int vOut = int.tryParse(item.valueOut ?? "0") ?? 0;
      grandTotal += (vIn - vOut);
    }

    // 2. Siapkan data tabel (Konversi List Model ke List String)
    List<List<String>> tableData = data.map((item) {
      int vIn = int.tryParse(item.valueIn ?? "0") ?? 0;
      int vOut = int.tryParse(item.valueOut ?? "0") ?? 0;
      int subTotal = vIn - vOut;
      
      return [
        item.transactionDate?.split(' ')[0] ?? "-",
        item.menuName ?? "-",
        item.menuType ?? "-", // Ganti keterangan jadi Jenis (Pemasukan/Pengeluaran dll)
        formatCurrency.format(subTotal),
      ];
    }).toList();

    // 3. Tambahkan baris Total Saldo di akhir list data
    tableData.add([
      '', 
      '', 
      'TOTAL SALDO', 
      formatCurrency.format(grandTotal)
    ]);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0, 
            child: pw.Text("LAPORAN KEUANGAN BUKUKAS", 
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Tanggal', 'Menu', 'Jenis', 'Nominal'],
            data: tableData,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
            cellHeight: 30,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerRight,
            },
            // Memberikan style tebal khusus untuk baris total (baris terakhir)
            cellStyle: pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              "Dicetak pada: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}",
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
            ),
          )
        ],
      ),
    );

    // Simpan dan Bagikan
    final directory = await getTemporaryDirectory();
    String filePath = "${directory.path}/Laporan_Keuangan_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(filePath)], text: 'Laporan Keuangan PDF');
  }
}