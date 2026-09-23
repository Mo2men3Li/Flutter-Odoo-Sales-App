import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../classes/odoo_provider.dart';

class SalesOrderDetailScreen extends StatefulWidget {
  const SalesOrderDetailScreen({super.key, required this.orderId});
  final int orderId;

  @override
  State<SalesOrderDetailScreen> createState() => _SalesOrderDetailScreenState();
}

class _SalesOrderDetailScreenState extends State<SalesOrderDetailScreen> {
  Map<String, dynamic>? _order;
  List<dynamic> _lines = [];
  bool _loading = true;
  bool _confirming = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final api = context.read<OdooProvider>().api;
      final orderResult = await api.searchRead(
        model: 'sale.order',
        domain: [
          ['id', '=', widget.orderId]
        ],
        fields: ['name', 'partner_id', 'amount_total', 'state', 'order_line'],
      );
      final order = orderResult.first as Map<String, dynamic>;

      List<dynamic> lines = [];
      if (order['order_line'] is List && (order['order_line'] as List).isNotEmpty) {
        lines = await api.searchRead(
          model: 'sale.order.line',
          domain: [
            ['id', 'in', order['order_line']]
          ],
          fields: ['product_id', 'product_uom_qty', 'price_subtotal'],
        );
      }

      setState(() {
        _order = order;
        _lines = lines;
      });
    } catch (e) {
      setState(() => _error = 'Failed to load order: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _confirm() async {
    setState(() => _confirming = true);
    try {
      await context.read<OdooProvider>().confirmOrder(widget.orderId);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Failed to confirm: $e');
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDraft = _order?['state'] == 'draft' || _order?['state'] == 'sent';

    return Scaffold(
      appBar: AppBar(title: Text(_order?['name'] ?? 'Order')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer: ${(_order?['partner_id'] is List) ? _order!['partner_id'][1] : '-'}'),
                  const SizedBox(height: 4),
                  Text('Status: ${_order?['state'] ?? '-'}'),
                  const SizedBox(height: 4),
                  Text('Total: ${_order?['amount_total'] ?? '-'}'),
                  const Divider(height: 24),
                  const Text('Products', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _lines.length,
                      itemBuilder: (context, i) {
                        final l = _lines[i];
                        final productName =
                            (l['product_id'] is List) ? l['product_id'][1] : '-';
                        return ListTile(
                          title: Text(productName),
                          subtitle: Text('Qty: ${l['product_uom_qty']}'),
                          trailing: Text('${l['price_subtotal']}'),
                        );
                      },
                    ),
                  ),
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  if (isDraft)
                    _confirming
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _confirm,
                            child: const Text('Confirm Order'),
                          ),
                ],
              ),
            ),
    );
  }
}
