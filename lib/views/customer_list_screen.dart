import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../classes/odoo_provider.dart';
import 'customer_detail_screen.dart';
import 'sales_orders_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OdooProvider>().loadCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OdooProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          if (provider.isInternal)
            IconButton(
              icon: const Icon(Icons.list_alt),
              tooltip: 'Sales Orders',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SalesOrdersScreen()),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (q) => context.read<OdooProvider>().searchCustomers(q),
            ),
          ),
          if (provider.customersError != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(provider.customersError!,
                  style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: provider.customersLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.filteredCustomers.isEmpty
                    ? const Center(child: Text('No customers found'))
                    : RefreshIndicator(
                        onRefresh: () => context.read<OdooProvider>().loadCustomers(),
                        child: ListView.builder(
                          itemCount: provider.filteredCustomers.length,
                          itemBuilder: (context, i) {
                            final c = provider.filteredCustomers[i];
                            return ListTile(
                              title: Text(c['name'] ?? ''),
                              subtitle: Text(
                                  '${c['phone'] ?? '-'} · ${c['city'] ?? '-'}'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CustomerDetailScreen(
                                      customerId: c['id'],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
