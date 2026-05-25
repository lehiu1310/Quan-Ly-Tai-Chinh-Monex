import 'dart:io';

import 'package:monex/data/app_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;

class ReportService {
  Future<void> shareMonthlyPdf(MonexAppState state) async {
    final doc = pw.Document();
    final transactions = [...state.transactions]
      ..sort((a, b) => b.date.compareTo(a.date));

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            'Monex monthly report',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Account: ${state.displayName}'),
          pw.Text('Balance: ${money(state.balance)}'),
          pw.Text('Income: ${money(state.incomeTotal)}'),
          pw.Text('Expense: ${money(state.expenseTotal)}'),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Type', 'Title', 'Category', 'Amount'],
            data: transactions.map((item) {
              return [
                shortDate(item.date),
                item.isIncome ? 'Income' : 'Expense',
                item.title,
                item.category,
                '${item.isIncome ? '+' : '-'} ${money(item.amount)}',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename:
          'monex_report_${DateTime.now().month}_${DateTime.now().year}.pdf',
    );
  }

  Future<void> shareMonthlyExcel(MonexAppState state) async {
    final workbook = xls.Workbook();
    final sheet = workbook.worksheets[0];
    sheet.name = 'Monex report';
    sheet.getRangeByName('A1').setText('Date');
    sheet.getRangeByName('B1').setText('Type');
    sheet.getRangeByName('C1').setText('Title');
    sheet.getRangeByName('D1').setText('Category');
    sheet.getRangeByName('E1').setText('Amount');

    final transactions = [...state.transactions]
      ..sort((a, b) => b.date.compareTo(a.date));
    for (var i = 0; i < transactions.length; i++) {
      final row = i + 2;
      final item = transactions[i];
      sheet.getRangeByIndex(row, 1).setText(shortDate(item.date));
      sheet
          .getRangeByIndex(row, 2)
          .setText(item.isIncome ? 'Income' : 'Expense');
      sheet.getRangeByIndex(row, 3).setText(item.title);
      sheet.getRangeByIndex(row, 4).setText(item.category);
      sheet
          .getRangeByIndex(row, 5)
          .setNumber(item.isIncome ? item.amount : -item.amount);
    }

    sheet.getRangeByName('G1').setText('Balance');
    sheet.getRangeByName('H1').setNumber(state.balance);
    sheet.getRangeByName('G2').setText('Income');
    sheet.getRangeByName('H2').setNumber(state.incomeTotal);
    sheet.getRangeByName('G3').setText('Expense');
    sheet.getRangeByName('H3').setNumber(state.expenseTotal);

    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/monex_report_${DateTime.now().month}_${DateTime.now().year}.xlsx',
    );
    await file.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles([XFile(file.path)], text: 'Monex report');
  }
}

final ReportService reportService = ReportService();
