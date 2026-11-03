import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_to_pdf/flutter_to_pdf.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../viewmodel/invoice_view_model.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  final ExportDelegate exportDelegate = ExportDelegate();
  final InvoiceController controller = Get.put(InvoiceController());

  Future<void> _savePdf(String exportId) async {
    final pdf = await exportDelegate.exportToPdfDocument(exportId);
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/payment_receipt.pdf");
    await file.writeAsBytes(await pdf.save());

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: "Invoice PDF"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Invoice"),
          backgroundColor: AppColors.primaryColor),
      body: Center(
        child: ExportFrame(
          frameId: "invoiceA4",
          exportDelegate: exportDelegate,
          child: InvoiceA4Page(
            controller: controller,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _savePdf("invoiceA4"),
        label: const Text("Share PDF"),
        icon: const Icon(Icons.picture_as_pdf),
      ),
    );
  }
}

class InvoiceA4Page extends StatelessWidget {
  final InvoiceController controller;

  const InvoiceA4Page({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Container(
        width: 430,
        // A4 width in points
        height: 842,
        // A4 height in points
        color: Colors.white,
        padding: const EdgeInsets.all(24),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.invoiceModel.value != null) {
            final invoice = controller.invoiceModel.value!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Alnico Tech Private Limited",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("GSTIN: 27ABBCA0322N1ZV",
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("INVOICE",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        Text("Invoice Id: ${invoice.data.invoiceNumber}",
                            style: const TextStyle(fontSize: 10)),
                        // Text("18FD6B3E-4C27-4621-9865-7E2C3D49AF8B",
                        //     style: TextStyle(fontSize: 8)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // --- BILLING INFO ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Bill To:",
                            style: TextStyle(fontWeight: FontWeight.w300)),
                        // SizedBox(width: Get.width*0.5,
                        //   child: Text(profileCtr.nameCtr.value.text,maxLines: 2,
                        //       style:
                        //       const TextStyle(fontWeight: FontWeight.bold)),
                        // ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: 5,
                      children: [
                        Text("Date:  ${invoice.data.paymentDate}"),
                        Text("Payment Terms:  ${invoice.data.status}"),
                        // Container(
                        //     padding: EdgeInsets.fromLTRB(30, 4, 4, 4),
                        //     decoration: BoxDecoration(color: Colors.grey[200]),
                        //     child: const Text("Balance Due: Rs.0.00",
                        //         style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // --- TABLE HEADER ---
                Container(
                  color: Colors.black87,
                  padding: const EdgeInsets.all(8),
                  child: const Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Text("Item",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70))),
                      Expanded(
                          child: Text("cgst",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70))),
                      Expanded(
                          child: Text("sgst",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70))),
                      Expanded(
                          child: Text("Base Amount",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70))),
                    ],
                  ),
                ),

                // --- TABLE ROW ---
                Container(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(invoice.data.description)),
                      Expanded(
                          child: Text(invoice.data.cgst,
                              textAlign: TextAlign.center)),
                      Expanded(
                          child: Text(invoice.data.sgst,
                              textAlign: TextAlign.center)),
                      Expanded(
                          child: Text(invoice.data.baseAmount,
                              textAlign: TextAlign.center)),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child:
                      Text("HSN Code : 998319", style: TextStyle(fontSize: 10)),
                ),

                const SizedBox(
                  height: 20,
                ),

                // --- TOTALS ---
                SizedBox(
                  width: 595, // A4 width in points

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 5,
                    children: [
                      Text(
                          "Amount Paid: Rs.${invoice.data.unitPrice.toString()}"),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- NOTES ---
                Text("Notes:",
                    style: TextStyle(
                        fontWeight: FontWeight.w300, color: Colors.grey[500])),
                const SizedBox(height: 6),
                // Text("1.Purchase is valid up to Sep 30, 2025",
                //     style: TextStyle(
                //         fontWeight: FontWeight.w400, color: Colors.black87)),
                const Text(
                    "1. This is a computer generated invoice and does not require any signature.",
                    style: TextStyle(
                        fontWeight: FontWeight.w400, color: Colors.black87)),
                const Text(
                    "2. This bill is generated post service activation and shall be considered as service delivery slip as well.",
                    style: TextStyle(
                        fontWeight: FontWeight.w400, color: Colors.black87)),

                const SizedBox(
                  height: 30,
                ),

                // --- FOOTER ---
                const Text(
                  "Registered Address: 7TH FLOOR S 11 UNIT NO 1171 AND 1172 INNOV8 SOLITAIRE CORPORATE PARK, ANDHERI EAST, Chakala MIDC, Mumbai, Maharashtra, India 400093",
                  style: TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ],
            );
          }
          return Text(
            controller.errorMessage.value.isNotEmpty
                ? controller.errorMessage.value
                : "No data",
          );
        }),
      ),
    );
  }
}
