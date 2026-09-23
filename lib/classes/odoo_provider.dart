import 'package:flutter/material.dart';
import 'odoo_api.dart';

class OdooProvider extends ChangeNotifier {
  OdooProvider({required this.api});
  final OdooApi api;

  bool authLoading = false;
  String? authError;
  bool isInternal = false;

  Future<bool> login(String username, String password) async {
    authLoading = true;
    authError = null;
    notifyListeners();

    try {
      final ok = await api.login(username, password);
      if (ok) {
        isInternal = await api.isInternalUser();
      } else {
        authError = 'Invalid username or password';
      }
      return ok;
    } catch (e) {
      authError = 'Could not reach the server: $e';
      return false;
    } finally {
      authLoading = false;
      notifyListeners();
    }
  }

  List<dynamic> customers = [];
  List<dynamic> filteredCustomers = [];
  bool customersLoading = false;
  String? customersError;

  Future<void> loadCustomers() async {
    customersLoading = true;
    customersError = null;
    notifyListeners();

    try {
      final result = await api.searchRead(
        model: 'res.partner',
        domain: [
          ['customer_rank', '>', 0]
        ],
        fields: ['name', 'phone', 'city'],
      );
      customers = result;
      filteredCustomers = result;
    } catch (e) {
      customersError = 'Failed to load customers: $e';
    } finally {
      customersLoading = false;
      notifyListeners();
    }
  }

  void searchCustomers(String query) {
    filteredCustomers = customers
        .where((c) =>
            (c['name'] ?? '').toString().toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }

  Future<void> updateCustomerPhone(int id, String phone) async {
    await api.writeRecord(model: 'res.partner', id: id, values: {'phone': phone});
    await loadCustomers(); // keep list in sync
  }

  List<dynamic> orders = [];
  bool ordersLoading = false;
  String? ordersError;

  Future<void> loadOrders() async {
    ordersLoading = true;
    ordersError = null;
    notifyListeners();

    try {
      orders = await api.searchRead(
        model: 'sale.order',
        fields: ['name', 'partner_id', 'date_order', 'state'],
      );
    } catch (e) {
      ordersError = 'Failed to load orders: $e';
    } finally {
      ordersLoading = false;
      notifyListeners();
    }
  }

  Future<void> confirmOrder(int id) async {
    await api.callKw(model: 'sale.order', method: 'action_confirm', args: [
      [id]
    ]);
    await loadOrders();
  }
}
