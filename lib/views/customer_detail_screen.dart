import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../classes/odoo_provider.dart';

class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({super.key, required this.customerId});
  final int customerId;

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  Map<String, dynamic>? _customer;
  final _phoneCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;
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
      final result = await api.searchRead(
        model: 'res.partner',
        domain: [
          ['id', '=', widget.customerId]
        ],
        fields: ['name', 'phone', 'email', 'street', 'city'],
      );
      final c = result.first as Map<String, dynamic>;
      setState(() {
        _customer = c;
        _phoneCtrl.text = c['phone'] ?? '';
      });
    } catch (e) {
      setState(() => _error = 'Failed to load customer: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await context
          .read<OdooProvider>()
          .updateCustomerPhone(widget.customerId, _phoneCtrl.text.trim());
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Failed to save: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_customer?['name'] ?? 'Customer')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${_customer?['email'] ?? '-'}'),
                  const SizedBox(height: 8),
                  Text(
                      'Address: ${_customer?['street'] ?? '-'}, ${_customer?['city'] ?? '-'}'),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                  const SizedBox(height: 20),
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  _saving
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _save,
                          child: const Text('Save'),
                        ),
                ],
              ),
            ),
    );
  }
}
