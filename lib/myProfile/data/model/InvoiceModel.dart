// To parse this JSON data, do
//
//     final invoiceModel = invoiceModelFromJson(jsonString);

import 'dart:convert';

InvoiceModel invoiceModelFromJson(String str) => InvoiceModel.fromJson(json.decode(str));

String invoiceModelToJson(InvoiceModel data) => json.encode(data.toJson());

class InvoiceModel {
  bool status;
  Data data;
  String msg;

  InvoiceModel({
    required this.status,
    required this.data,
    required this.msg,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => InvoiceModel(
    status: json["status"],
    data: Data.fromJson(json["data"]),
    msg: json["msg"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data.toJson(),
    "msg": msg,
  };
}

class Data {
  String invoiceNumber;
  DateTime invoiceDate;
  String paymentDate;
  String description;
  DateTime createdAt;
  String razorpayInvoiceId;
  String status;
  int unitPrice;
  String baseAmount;
  String cgst;
  String sgst;

  Data({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.paymentDate,
    required this.description,
    required this.createdAt,
    required this.razorpayInvoiceId,
    required this.status,
    required this.unitPrice,
    required this.baseAmount,
    required this.cgst,
    required this.sgst,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    invoiceNumber: json["invoice_number"],
    invoiceDate: DateTime.parse(json["invoice_date"]),
    paymentDate: json["payment_date"],
    description: json["description"],
    createdAt: DateTime.parse(json["created_at"]),
    razorpayInvoiceId: json["razorpay_invoice_id"],
    status: json["status"],
    unitPrice: json["unitPrice"],
    baseAmount: json["baseAmount"],
    cgst: json["cgst"],
    sgst: json["sgst"],
  );

  Map<String, dynamic> toJson() => {
    "invoice_number": invoiceNumber,
    "invoice_date": "${invoiceDate.year.toString().padLeft(4, '0')}-${invoiceDate.month.toString().padLeft(2, '0')}-${invoiceDate.day.toString().padLeft(2, '0')}",
    "payment_date": paymentDate,
    "description": description,
    "created_at": createdAt.toIso8601String(),
    "razorpay_invoice_id": razorpayInvoiceId,
    "status": status,
    "unitPrice": unitPrice,
    "baseAmount": baseAmount,
    "cgst": cgst,
    "sgst": sgst,
  };
}