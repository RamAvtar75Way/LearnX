import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../services/course_service.dart';
import '../../services/auth_service.dart';

class PurchaseScreen extends StatefulWidget {
  final Course course;

  const PurchaseScreen({super.key, required this.course});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  bool _isLoading = false;
  String? _selectedMethod;
  List<String> _paymentMethods = [];

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final methods = await authService.getPaymentMethods();
    setState(() {
      _paymentMethods = methods;
      if (_paymentMethods.isNotEmpty) {
        _selectedMethod = _paymentMethods.first;
      }
    });
  }

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    final authService = Provider.of<AuthService>(context, listen: false);
    final courseService = Provider.of<CourseService>(context, listen: false);
    final user = authService.userModel;

    if (user != null) {
        await courseService.enrollStudent(user.uid, user.name, user.email, widget.course.id);
        
        if (mounted) {
          setState(() => _isLoading = false);
          // Show success and navigate back or to course
           showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text("Success!"),
              content: const Text("You have successfully enrolled in this course."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Close dialog
                    Navigator.pop(context); // Close Purchase Screen
                    // We rely on CourseDetailScreen to refresh on re-focus or we can return result
                  }, 
                  child: const Text("Start Learning")
                )
              ],
            )
           );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Order Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Container(
                    width: 50, height: 50, color: Colors.grey[200],
                    child: widget.course.thumbnailUrl.isNotEmpty ? Image.network(widget.course.thumbnailUrl, fit: BoxFit.cover, errorBuilder: (c,e,s)=>const Icon(Icons.image)) : const Icon(Icons.image)
                ),
                title: Text(widget.course.title),
                subtitle: Text(widget.course.instructorName),
                trailing: Text("\$${widget.course.price}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const Divider(height: 32),
             const Text("Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              items: _paymentMethods.isEmpty 
                  ? [const DropdownMenuItem(value: null, child: Text("No saved cards"))]
                  : _paymentMethods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) {
                setState(() => _selectedMethod = val);
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
             const Spacer(),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 const Text("Total:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                 Text("\$${widget.course.price}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
               ],
             ),
             const SizedBox(height: 16),
             SizedBox(
               width: double.infinity,
               child: ElevatedButton(
                 onPressed: (_isLoading || _selectedMethod == null) ? null : _processPayment,
                 style: ElevatedButton.styleFrom(
                   padding: const EdgeInsets.symmetric(vertical: 16),
                   backgroundColor: Colors.green,
                   foregroundColor: Colors.white,
                 ),
                 child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Pay Now", style: TextStyle(fontSize: 18)),
               ),
             ),
          ],
        ),
      ),
    );
  }
}
