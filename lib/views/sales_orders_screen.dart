import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../classes/odoo_provider.dart';
import 'sales_order_detail_screen.dart';

class SalesOrdersScreen extends StatefulWidget {
  const SalesOrdersScreen({super.key});

  @override
  State<SalesOrdersScreen> createState() => _SalesOrdersScreenState();
}

class _SalesOrdersScreenState extends State<SalesOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OdooProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OdooProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Sales Orders')),
      body: provider.ordersLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.ordersError != null
              ? Center(
                  child: Text(provider.ordersError!,
                      style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: () => context.read<OdooProvider>().loadOrders(),
                  child: ListView.builder(
                    itemCount: provider.orders.length,
                    itemBuilder: (context, i) {
                      final o = provider.orders[i];
                      final partnerName =
                          (o['partner_id'] is List) ? o['partner_id'][1] : '-';
                      return ListTile(
                        title: Text(o['name'] ?? ''),
                        subtitle: Text(
                            '$partnerName · ${o['date_order'] ?? '-'} · ${o['state']}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SalesOrderDetailScreen(orderId: o['id']),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
