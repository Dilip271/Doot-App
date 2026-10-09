import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const DootApp());
}

class DootApp extends StatelessWidget {
  const DootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF16A34A)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7F6),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Splash();
        }
        return snapshot.data == null ? const LoginPage() : const HomePage();
      },
    );
  }
}

class Splash extends StatelessWidget {
  const Splash({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Doot', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800)),
              SizedBox(height: 12),
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  String? error;

  Future<void> login() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() { busy = true; error = null; });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => error = '${e.code}: ${e.message ?? 'Login failed'}');
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Doot', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  const Text('Business Manager', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 28),
                  TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Admin Email', prefixIcon: Icon(Icons.email_outlined)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: password,
                    obscureText: true,
                    onSubmitted: (_) => login(),
                    decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 14),
                    Text(error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: busy ? null : login,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Text(busy ? 'Signing in...' : 'Login'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum Section { dashboard, products, orders, settings }

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Section section = Section.dashboard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doot', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Logout',
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.logout),
            ),
          )
        ],
      ),
      drawer: NavigationDrawer(
        selectedIndex: section.index,
        onDestinationSelected: (i) {
          Navigator.pop(context);
          setState(() => section = Section.values[i]);
        },
        children: const [
          Padding(
            padding: EdgeInsets.fromLTRB(28, 24, 16, 12),
            child: Text('DOOT', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          ),
          NavigationDrawerDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
          NavigationDrawerDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: Text('Products')),
          NavigationDrawerDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag), label: Text('Orders')),
          NavigationDrawerDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Settings')),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: switch (section) {
          Section.dashboard => const DashboardPage(key: ValueKey('dashboard')),
          Section.products => const ProductsPage(key: ValueKey('products')),
          Section.orders => const OrdersPage(key: ValueKey('orders')),
          Section.settings => const SettingsPage(key: ValueKey('settings')),
        },
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>> get orders =>
      FirebaseFirestore.instance.collection('orders').snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> get products =>
      FirebaseFirestore.instance.collection('products').snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: orders,
      builder: (context, os) {
        final docs = os.data?.docs ?? [];
        num sales = 0;
        int pending = 0;
        for (final d in docs) {
          final x = d.data();
          sales += (x['total'] ?? x['subtotal'] ?? 0) is num
              ? (x['total'] ?? x['subtotal'] ?? 0) as num
              : num.tryParse('${x['total'] ?? 0}') ?? 0;
          if ((x['status'] ?? 'Pending').toString().toLowerCase() == 'pending') pending++;
        }
        return StreamBuilder(
          stream: products,
          builder: (context, ps) {
            final count = ps.data?.docs.length ?? 0;
            return ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const Text('Dashboard', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                LayoutBuilder(builder: (context, c) {
                  final w = c.maxWidth;
                  final itemWidth = w > 800 ? (w - 48) / 4 : (w > 500 ? (w - 16) / 2 : w);
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      StatCard(title: 'Products', value: '$count', icon: Icons.inventory_2),
                      StatCard(title: 'Orders', value: '${docs.length}', icon: Icons.shopping_bag),
                      StatCard(title: 'Pending', value: '$pending', icon: Icons.pending_actions),
                      StatCard(title: 'Sales', value: '₹${sales.toStringAsFixed(0)}', icon: Icons.currency_rupee),
                    ].map((x) => SizedBox(width: itemWidth, child: x)).toList(),
                  );
                }),
                const SizedBox(height: 22),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_done, color: Colors.green, size: 30),
                        const SizedBox(width: 12),
                        Expanded(child: Text('Doot is connected to your Firebase database.', style: Theme.of(context).textTheme.titleMedium)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  const StatCard({super.key, required this.title, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            ])
          ]),
        ),
      );
}

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});
  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final db = FirebaseFirestore.instance;
  final name = TextEditingController();
  final unit = TextEditingController();
  final price = TextEditingController();
  final old = TextEditingController();
  final category = TextEditingController();
  final emoji = TextEditingController();
  Uint8List? imageBytes;
  bool saving = false;

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.single.bytes != null) {
      setState(() => imageBytes = result.files.single.bytes);
    }
  }

  Future<void> addProduct() async {
    if (name.text.trim().isEmpty || price.text.trim().isEmpty) return;
    setState(() => saving = true);
    try {
      String imageData = '';
      if (imageBytes != null) {
        imageData = 'data:image/jpeg;base64,${base64Encode(imageBytes!)}';
        if (imageData.length > 900000) {
          throw Exception('Photo is too large. Please choose a smaller photo.');
        }
      }
      await db.collection('products').add({
        'name': name.text.trim(),
        'unit': unit.text.trim(),
        'price': double.tryParse(price.text.trim()) ?? 0,
        'old': double.tryParse(old.text.trim()) ?? 0,
        'cat': category.text.trim().isEmpty ? 'Home' : category.text.trim(),
        'emoji': emoji.text.trim().isEmpty ? '🛒' : emoji.text.trim(),
        'imageData': imageData,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product added')));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void showAdd() {
    name.clear(); unit.clear(); price.clear(); old.clear(); category.clear(); emoji.clear();
    imageBytes = null;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          title: const Text('Add Product'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 520,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                if (imageBytes != null) Image.memory(imageBytes!, height: 120, fit: BoxFit.contain),
                OutlinedButton.icon(
                  onPressed: () async { await pickImage(); setDialog(() {}); },
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Choose Product Photo'),
                ),
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Product Name')),
                TextField(controller: unit, decoration: const InputDecoration(labelText: 'Unit (e.g. 1 KG)')),
                TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Selling Price')),
                TextField(controller: old, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'MRP / Old Price')),
                TextField(controller: category, decoration: const InputDecoration(labelText: 'Category')),
                TextField(controller: emoji, decoration: const InputDecoration(labelText: 'Emoji fallback')),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(onPressed: saving ? null : addProduct, child: Text(saving ? 'Saving...' : 'Add Product')),
          ],
        ),
      ),
    );
  }

  Future<void> delete(String id) async {
    await db.collection('products').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: db.collection('products').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snap) {
        final products = snap.data?.docs ?? [];
        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Row(children: [
              const Expanded(child: Text('Products', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800))),
              FilledButton.icon(onPressed: showAdd, icon: const Icon(Icons.add), label: const Text('Add Product')),
            ]),
            const SizedBox(height: 16),
            if (snap.hasError)
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Could not load products: ${snap.error}'))),
            ...products.map((d) {
              final p = d.data();
              final img = p['imageData']?.toString() ?? '';
              return Card(
                child: ListTile(
                  leading: img.isNotEmpty
                      ? Image.memory(base64Decode(img.split(',').last), width: 52, height: 52, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported))
                      : Text(p['emoji']?.toString() ?? '🛒', style: const TextStyle(fontSize: 30)),
                  title: Text(p['name']?.toString() ?? 'Product'),
                  subtitle: Text('${p['unit'] ?? ''}  •  ₹${p['price'] ?? 0}  •  ${p['cat'] ?? ''}'),
                  trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => delete(d.id)),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  Future<void> setStatus(String id, String status) =>
      FirebaseFirestore.instance.collection('orders').doc(id).update({'status': status});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('orders').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snap) {
        final orders = snap.data?.docs ?? [];
        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text('Orders', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            if (snap.hasError)
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Could not load orders: ${snap.error}'))),
            ...orders.map((d) {
              final o = d.data();
              final items = (o['items'] is List) ? (o['items'] as List) : [];
              final status = o['status']?.toString() ?? 'Pending';
              return Card(
                child: ExpansionTile(
                  title: Text('${o['customerName'] ?? 'Customer'} • ₹${o['total'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${o['phone'] ?? ''} • $status'),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    Align(alignment: Alignment.centerLeft, child: Text('Address: ${o['address'] ?? ''}')),
                    const SizedBox(height: 8),
                    Align(alignment: Alignment.centerLeft, child: Text('Items: ${items.map((e) => '${e['name'] ?? 'Item'} x${e['qty'] ?? 1}').join(', ')}')),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(labelText: 'Order Status'),
                      items: const ['Pending', 'Confirmed', 'Preparing', 'Out for Delivery', 'Delivered', 'Cancelled']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) { if (v != null) setStatus(d.id, v); },
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.delivery_dining),
            title: const Text('Delivery Charge'),
            subtitle: const Text('Current customer website rule: ₹30 fixed delivery charge.'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.cloud_outlined),
            title: const Text('Firebase Project'),
            subtitle: const Text('doot-delivery'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('Signed-in account'),
            subtitle: Text(FirebaseAuth.instance.currentUser?.email ?? ''),
          ),
        ),
      ],
    );
  }
}
