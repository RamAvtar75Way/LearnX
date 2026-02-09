import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPaymentMethodScreen()));
            },
          )
        ],
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          return FutureBuilder<List<String>>(
            future: authService.getPaymentMethods(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final methods = snapshot.data ?? [];
              
              if (methods.isEmpty) return const Center(child: Text("No payment methods saved"));

              return ListView.builder(
                itemCount: methods.length,
                itemBuilder: (context, index) {
                  final method = methods[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.credit_card, color: Colors.blue),
                      title: Text(method),
                      subtitle: index == 0 ? const Text("Default", style: TextStyle(color: Colors.green)) : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red), 
                        onPressed: () async {
                           await authService.removePaymentMethod(method);
                        }
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _cardNumberController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Payment Method")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cardNumberController,
              decoration: const InputDecoration(labelText: "Card Number (e.g. Visa ending in...)", border: OutlineInputBorder())
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                 Expanded(child: TextField(decoration: InputDecoration(labelText: "Expiry Date", border: OutlineInputBorder()))),
                 SizedBox(width: 16),
                 Expanded(child: TextField(decoration: InputDecoration(labelText: "CVV", border: OutlineInputBorder()))),
              ],
            ),
             const SizedBox(height: 16),
             const TextField(decoration: InputDecoration(labelText: "Card Holder Name", border: OutlineInputBorder())),
             const SizedBox(height: 24),
             SizedBox(
               width: double.infinity,
               child: ElevatedButton(
                 onPressed: () async {
                    if (_cardNumberController.text.isNotEmpty) {
                      final authService = Provider.of<AuthService>(context, listen: false);
                      await authService.addPaymentMethod(_cardNumberController.text);
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment method added")));
                      }
                    }
                 },
                 child: const Text("Add Card"),
               ),
             )
          ],
        ),
      ),
    );
  }
}
