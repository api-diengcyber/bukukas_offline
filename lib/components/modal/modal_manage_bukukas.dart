import 'package:flutter/material.dart';
import 'package:keuangan/db/tb_bukukas.dart';
import 'package:keuangan/providers/global_bloc.dart';
import 'package:provider/provider.dart';

class ManageBukukasModal extends StatefulWidget {
  const ManageBukukasModal({super.key});

  @override
  State<ManageBukukasModal> createState() => _ManageBukukasModalState();
}

class _ManageBukukasModalState extends State<ManageBukukasModal> {
  List<Map<String, dynamic>> listBuku = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Mengambil daftar buku kas dari database
  Future<void> _loadData() async {
    setState(() => isLoading = true);
    var data = await TbBukukas().getAll();
    setState(() {
      listBuku = data;
      isLoading = false;
    });
  }

  // Dialog untuk mengganti nama buku
  void _showRenameDialog(int id, String currentName) {
    TextEditingController controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Ganti Nama Buku", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: "Contoh: Toko Sembako, Pribadi",
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await TbBukukas().update(id, controller.text);
                _loadData(); // Refresh list modal
                Navigator.pop(context);
              }
            },
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final globalBloc = context.watch<GlobalBloc>();
    // Mendapatkan tinggi layar agar modal tidak overflow
    final double screenHeight = MediaQuery.of(context).size.height;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white, // Mencegah warna tint material 3 yang aneh
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      actionsPadding: const EdgeInsets.all(24),
      
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Pilih Buku Kas",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.grey),
            splashRadius: 20,
          ),
        ],
      ),
      
      content: ConstrainedBox(
        // Batasi tinggi konten maksimal 70% dari layar untuk mencegah overflow
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.7,
          minWidth: double.maxFinite,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (listBuku.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("Belum ada buku kas", style: TextStyle(color: Colors.grey)),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true, // Penting agar tidak error size
                  itemCount: listBuku.length,
                  itemBuilder: (context, index) {
                    var buku = listBuku[index];
                    bool isActive = globalBloc.activeBukukasId == buku['id'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.blue.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isActive ? Colors.blue : Colors.grey.shade200,
                          width: isActive ? 2 : 1,
                        ),
                        boxShadow: [
                          if (!isActive)
                            BoxShadow(
                              color: Colors.grey.shade100,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            // Simpan pilihan buku ke Bloc & SharedPreferences
                            globalBloc.setActiveBukukas(buku['id'], buku['name']);
                            Navigator.pop(context, 'changed');
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                // Icon Buku
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isActive ? Colors.blue : Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.book_rounded,
                                    color: isActive ? Colors.white : Colors.grey.shade500,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Nama Buku
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        buku['name'],
                                        style: TextStyle(
                                          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                          fontSize: 16,
                                          color: isActive ? Colors.blue.shade900 : Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (isActive)
                                        const Text(
                                          "Sedang Aktif",
                                          style: TextStyle(fontSize: 12, color: Colors.blue),
                                        )
                                    ],
                                  ),
                                ),
                                // Tombol Edit
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                                  onPressed: () => _showRenameDialog(buku['id'], buku['name']),
                                  tooltip: "Ganti Nama",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      
      // Bagian Bawah (Tombol Tambah)
      actions: [
        Column(
          children: [
            const Divider(height: 1),
            const SizedBox(height: 16),
            if (listBuku.length < 5)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    String nameBaru = "Bukukas ${listBuku.length + 1}";
                    await TbBukukas().create(nameBaru);
                    _loadData();
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text("Tambah Buku Kas Baru", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      "Maksimal 5 buku tercapai",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
          ],
        )
      ],
    );
  }
}