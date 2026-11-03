
import 'package:get/get.dart';
import '../../core/database/BharatStorage.dart';
import '../data/api/ProfileApi.dart';
import '../data/model/InvoiceModel.dart';
import 'package:posterapp/core/network/dio_client.dart';


class InvoiceController extends GetxController {
  var invoiceModel = Rxn<InvoiceModel>(); // nullable reactive model
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  final api = ProfileApi(buildDio());

  Future<void> getInvoice() async {
    try {
      isLoading.value = true;

      String token = BharatStorage.getAuthKey() ?? '';
      final res = await api.fetchInvoice('Bearer $token');

      if (res.response.statusCode == 200) {
        invoiceModel.value = InvoiceModel.fromJson(res.data);
      } else if (res.response.statusCode == 401) {
        errorMessage.value = "Unauthorized";
        // logOutUser(false);
      } else {
        errorMessage.value = "Error: ${res.response.statusCode}";
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}