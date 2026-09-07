import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Contact {
  final String name;
  final String email;
  final String phone;
  final String? category;
  bool isFavorite;

  Contact({
    required this.name,
    required this.email,
    required this.phone,
    this.category,
    this.isFavorite = false,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Buku Kontak',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Contact> contacts = [
    Contact(
      name: 'Muhammad Finza Muta\'ali',
      email: 'sgsok812@gmail.com',
      phone: '0895422365052',
      category: 'Teman',
      isFavorite: true,
    ),
  ];

  final StreamController<String> _searchController = StreamController<String>.broadcast();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.close();
    super.dispose();
  }

  void _toggleFavorite(Contact contact) {
    setState(() {
      contact.isFavorite = !contact.isFavorite;
    });
  }

  void _addContact(String name, String email, String phone, String? category) {
    setState(() {
      contacts.add(Contact(
        name: name,
        email: email,
        phone: phone,
        category: category != null && category.isEmpty ? null : category,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredContacts = contacts.where((contact) {
      final nameLower = contact.name.toLowerCase();
      final categoryLower = (contact.category ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return nameLower.contains(query) || categoryLower.contains(query);
    }).toList();

    final favoriteContacts = contacts.where((c) => c.isFavorite).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          title: const Text('BUKU KONTAK'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.account_circle), text: 'Kontak'),
              Tab(icon: Icon(Icons.star), text: 'Favorit'),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'BUKU KONTAK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.assignment_ind),
                title: const Text('Kontak'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Tambah Kontak'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TambahKontakScreen(),
                    ),
                  );
                  if (result != null && result is Contact) {
                    _addContact(
                      result.name,
                      result.email,
                      result.phone,
                      result.category,
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Favorit'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Tentang'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TentangScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Cari Kontak / Kategori',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _searchController.add(value);
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<String>(
                stream: _searchController.stream,
                initialData: '',
                builder: (context, snapshot) {
                  _searchQuery = snapshot.data ?? '';
                  final displayList = contacts.where((contact) {
                    final nameLower = contact.name.toLowerCase();
                    final categoryLower = (contact.category ?? '').toLowerCase();
                    final query = _searchQuery.toLowerCase();
                    return nameLower.contains(query) || categoryLower.contains(query);
                  }).toList();

                  return TabBarView(
                    children: [
                      ListView.builder(
                        itemCount: displayList.length,
                        itemBuilder: (context, index) {
                          final contact = displayList[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                contact.name.isNotEmpty
                                    ? contact.name[0].toUpperCase()
                                    : '?',
                              ),
                            ),
                            title: Text(contact.name),
                            subtitle: Text(
                              '${contact.email}\n${contact.phone}\nKategori: ${contact.category ?? 'Tanpa kategori'}',
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                contact.isFavorite ? Icons.star : Icons.star_border,
                                color: contact.isFavorite ? Colors.amber : Colors.grey,
                              ),
                              onPressed: () => _toggleFavorite(contact),
                            ),
                          );
                        },
                      ),
                      favoriteContacts.isEmpty
                          ? const Center(child: Text('Belum ada kontak favorit.'))
                          : ListView.builder(
                              itemCount: favoriteContacts.length,
                              itemBuilder: (context, index) {
                                final contact = favoriteContacts[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text(
                                      contact.name.isNotEmpty
                                          ? contact.name[0].toUpperCase()
                                          : '?',
                                    ),
                                  ),
                                  title: Text(contact.name),
                                  subtitle: Text(
                                    '${contact.email}\n${contact.phone}\nKategori: ${contact.category ?? 'Tanpa kategori'}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.star, color: Colors.amber),
                                    onPressed: () => _toggleFavorite(contact),
                                  ),
                                );
                              },
                            ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TambahKontakScreen(),
              ),
            );
            if (result != null && result is Contact) {
              _addContact(
                result.name,
                result.email,
                result.phone,
                result.category,
              );
            }
          },
        ),
      ),
    );
  }
}

class TambahKontakScreen extends StatefulWidget {
  const TambahKontakScreen({super.key});

  @override
  State<TambahKontakScreen> createState() => _TambahKontakScreenState();
}

class _TambahKontakScreenState extends State<TambahKontakScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Tambah Kontak'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama wajib diisi';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    if (!value.contains('@')) {
                      return 'Email harus mengandung karakter @';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'No Handphone'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'No Handphone wajib diisi';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'No Handphone hanya boleh angka';
                    }
                    if (value.length < 10) {
                      return 'No Handphone minimal 10 digit';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Kategori (Opsional)',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final newContact = Contact(
                        name: _nameController.text,
                        email: _emailController.text,
                        phone: _phoneController.text,
                        category: _categoryController.text.isEmpty
                            ? null
                            : _categoryController.text,
                      );
                      Navigator.pop(context, newContact);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TentangScreen extends StatelessWidget {
  const TentangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Tentang'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/foto.jpg'),
            ),
            SizedBox(height: 15),
            Text(
              'Muhammad Finza Muta\'ali',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text('XII RPL B'),
            SizedBox(height: 5),
            Text('SMK Negeri 5 Surakarta'),
          ],
        ),
      ),
    );
  }
}