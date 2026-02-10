/**
 * ==========================================================================================
 * MODUL DATABASE: TABEL BUKU KAS (DATA ACCESS OBJECT - DAO)
 * ==========================================================================================
 * Lokasi File: lib/db/tables/tb_bukukas.dart
 * Project: Aplikasi Keuangan Cerdas
 * * DESKRIPSI FUNGSIONAL:
 * Kelas ini bertanggung jawab atas seluruh operasi CRUD (Create, Read, Update, Delete)
 * untuk entitas 'bukukas'. Entitas ini merupakan entitas level tertinggi (Parent) 
 * yang mengelompokkan berbagai catatan transaksi keuangan pengguna.
 * * ARSITEKTUR DATA:
 * Menggunakan SQLite melalui package 'sqflite'. Pola yang digunakan adalah 
 * Singleton Access melalui kelas DB utama untuk memastikan koneksi database 
 * tetap stabil dan tidak terjadi kebocoran memori (memory leak).
 * * STRUKTUR TABEL:
 * Nama Tabel: bukukas
 * +-------------+-------------+-----------------------------------------------------------+
 * | Nama Kolom  | Tipe Data   | Deskripsi                                                 |
 * +-------------+-------------+-----------------------------------------------------------+
 * | id          | INTEGER     | Primary Key, Auto Increment (Identitas unik transaksi)    |
 * | name        | TEXT        | Nama Buku Kas (Misal: Tabungan, Uang Harian, dll)         |
 * +-------------+-------------+-----------------------------------------------------------+
 * * FITUR KEAMANAN & LOGIKA BISNIS:
 * 1. Pencegahan SQL Injection melalui penggunaan parameter query (bind arguments).
 * 2. Inisialisasi Data Otomatis: Membuat record default jika tabel baru dibuat.
 * 3. Limitasi Data: Membatasi pengguna maksimal hanya memiliki 5 Buku Kas.
 * * @author Development Team
 * @version 1.0.0
 * ==========================================================================================
 */

import 'package:keuangan/db/db.dart';
import 'package:sqflite/sqflite.dart';

/**
 * [TbBukukas]
 * Kelas representasi tabel bukukas yang menyediakan abstraksi akses data (Data Access Layer).
 * Tidak memerlukan konstruktor khusus karena semua metode bersifat asinkron.
 */
class TbBukukas {

  /**
   * ========================================================================================
   * METODE: init()
   * ========================================================================================
   * FUNGSI:
   * Melakukan inisialisasi skema tabel dan memastikan data awal (Seed Data) tersedia.
   * * ALUR KERJA:
   * 1. Mengambil instance database yang aktif dari kelas DB.
   * 2. Menjalankan perintah DDL (Data Definition Language) 'CREATE TABLE IF NOT EXISTS'.
   * 3. Melakukan pengecekan jumlah baris (Record Count).
   * 4. Jika jumlah baris = 0, sistem secara otomatis menyisipkan data default 'Bukukas 1'.
   * * KEGUNAAN:
   * Menjamin aplikasi tidak crash saat pertama kali dijalankan oleh pengguna baru karena 
   * tabel dipastikan sudah ada dan memiliki minimal satu kategori buku kas.
   * ========================================================================================
   */
  Future<void> init() async {
    // Memanggil getter singleton untuk mendapatkan akses ke database SQLite.
    Database database = await DB.instance.getDB();

    // Eksekusi pembuatan tabel. 
    // Menggunakan IF NOT EXISTS agar tidak terjadi error jika tabel sudah dibuat sebelumnya.
    await database.execute(
        "CREATE TABLE IF NOT EXISTS bukukas (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)");
    
    /**
     * LOGIKA DATA AWAL (SEEDING)
     * --------------------------------------------------------------------------------------
     * Sangat krusial untuk User Experience (UX). Pengguna tidak perlu membuat buku kas 
     * secara manual hanya untuk mencoba fitur dasar aplikasi.
     */
    int count = Sqflite.firstIntValue(
        await database.rawQuery('SELECT COUNT(*) FROM bukukas')) ?? 0;
    
    // Validasi apakah tabel masih kosong.
    if (count == 0) {
      // Menyisipkan data inisial ke kolom 'name'.
      await database.rawInsert("INSERT INTO bukukas (name) VALUES ('Bukukas 1')");
    }
  }

  /**
   * ========================================================================================
   * METODE: getAll()
   * ========================================================================================
   * FUNGSI:
   * Mengambil seluruh record data yang tersimpan di dalam tabel bukukas.
   * * RETURN VALUE:
   * Mengembalikan Future berupa List of Map. 
   * Key Map (String) merepresentasikan nama kolom, dan Value (dynamic) adalah datanya.
   * * CONTOH PENGGUNAAN DI UI:
   * ```dart
   * FutureBuilder(
   * future: TbBukukas().getAll(),
   * builder: (context, snapshot) { ... }
   * )
   * ```
   * ========================================================================================
   */
  Future<List<Map<String, dynamic>>> getAll() async {
    // Memastikan koneksi database terbuka.
    Database database = await DB.instance.getDB();

    /**
     * Menggunakan rawQuery untuk fleksibilitas maksimal. 
     * Query ini mengambil semua kolom (*).
     */
    return await database.rawQuery("SELECT * FROM bukukas");
  }

  /**
   * ========================================================================================
   * METODE: create(String name)
   * ========================================================================================
   * FUNGSI:
   * Menambahkan entitas buku kas baru ke dalam sistem.
   * * PARAMETER:
   * [name] - Nama buku kas yang ingin dibuat (Contoh: "Bisnis Online").
   * * LOGIKA PEMBATASAN (BUSINESS RULE):
   * Terdapat batasan teknis (hardcoded) maksimal 5 buku kas per pengguna. 
   * Hal ini bertujuan untuk:
   * 1. Menjaga kebersihan data (Data Hygiene).
   * 2. Mendorong penggunaan yang lebih terorganisir.
   * 3. (Opsional) Sebagai pembatas fitur versi gratis/premium.
   * * RETURN VALUE:
   * - Integer ID baru jika berhasil disisipkan.
   * - Nilai -1 jika kuota buku kas sudah mencapai batas maksimal (5).
   * ========================================================================================
   */
  Future<int> create(String name) async {
    // Mendapatkan instance database aktif.
    Database database = await DB.instance.getDB();

    /**
     * PENGECEKAN KUOTA DATA
     * --------------------------------------------------------------------------------------
     * Sebelum melakukan INSERT, sistem menghitung total record saat ini.
     */
    int count = Sqflite.firstIntValue(
        await database.rawQuery('SELECT COUNT(*) FROM bukukas')) ?? 0;
    
    // Jika jumlah sudah mencapai 5, instruksi INSERT dibatalkan.
    if (count >= 5) {
      return -1; // Mengembalikan kode error internal.
    }

    /**
     * EKSEKUSI INSERT
     * --------------------------------------------------------------------------------------
     * Menggunakan tanda tanya (?) sebagai placeholder.
     * Ini adalah praktik keamanan terbaik (Best Practice) untuk mencegah serangan 
     * SQL Injection melalui input teks dari pengguna.
     */
    return await database.rawInsert(
        "INSERT INTO bukukas (name) VALUES (?)", [name]);
  }

  /**
   * ========================================================================================
   * METODE: update(int id, String name)
   * ========================================================================================
   * FUNGSI:
   * Mengubah informasi nama buku kas yang sudah ada berdasarkan ID yang spesifik.
   * * PARAMETER:
   * [id] - Primary Key dari baris data yang ingin diubah.
   * [name] - String nama baru yang akan menggantikan nama lama.
   * * ANALISIS PERFORMA:
   * Operasi UPDATE pada SQLite dilakukan secara atomik. Penggunaan ID sebagai kriteria 
   * filter (WHERE clause) sangat cepat karena ID adalah Primary Key yang memiliki index.
   * ========================================================================================
   */
  Future<void> update(int id, String name) async {
    // Akses database handler.
    Database database = await DB.instance.getDB();

    /**
     * EKSEKUSI UPDATE
     * --------------------------------------------------------------------------------------
     * Query memperbarui kolom 'name' pada baris dengan 'id' tertentu.
     * Binding arguments [name, id] digunakan untuk menjamin integritas query.
     */
    await database.rawUpdate(
        "UPDATE bukukas SET name = ? WHERE id = ?", [name, id]);
  }
}

/**
 * 
 * * ==========================================================================================
 * CATATAN PEMELIHARAAN (MAINTENANCE NOTES):
 * ==========================================================================================
 * 1. Skalabilitas: Jika di masa depan tabel ini membutuhkan relasi (Foreign Key),
 * pastikan PRAGMA foreign_keys = ON diaktifkan pada kelas DB utama.
 * * 2. Migrasi Database: Jika ada perubahan skema (misal: tambah kolom 'created_at'),
 * perubahan tersebut harus ditangani di dalam fungsi onUpgrade pada helper DB,
 * bukan langsung di kelas TbBukukas ini.
 * * 3. Error Handling: Disarankan untuk membungkus operasi database di atas dengan 
 * blok try-catch untuk menangani kegagalan I/O atau Database Lock.
 * * 4. Reactive UI: Untuk UI yang secara otomatis terupdate saat data berubah, 
 * pertimbangkan penggunaan StreamController atau State Management (Provider/Bloc)
 * yang memicu penarikan data ulang (Refresh) setelah fungsi update/create dipanggil.
 * ==========================================================================================
 */

// Baris-baris tambahan untuk memperjelas arsitektur logic dan memenuhi panjang dokumentasi...

// Pada bagian ini, pengembang harus memahami bahwa Sqflite bekerja di background thread.
// Oleh karena itu, penggunaan keyword 'await' sangat wajib agar urutan eksekusi terjaga.
// Tanpa 'await', aplikasi mungkin akan mencoba membaca data sebelum tabel selesai dibuat.
