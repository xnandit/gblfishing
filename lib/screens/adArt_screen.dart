import 'package:flutter/material.dart';
import 'dart:async';

class AdArtScreen extends StatelessWidget {
  const AdArtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AD/ART GBL FISHING MANIA'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ..._buildAdArtSections(),
            const SizedBox(height: 30),
            const Text(
              'AD/ART ini disusun sebagai panduan dasar untuk memperlancar kegiatan dan interaksi dalam grup GBL FISHING MANIA. Anggaran ini akan dievaluasi dan diperbaharui sesuai kebutuhan.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAdArtSections() {
    return [
      _buildAnimatedAdArtCard(
        'Pasal 1: Nama dan Tujuan',
        [
          'Nama grup ini adalah GBL FISHING MANIA.',
          'Tujuan utama grup adalah:',
        ],
        [
          'Menjalin silaturahmi antar anggota.',
          'Mengadakan kegiatan memancing rutin dan acara santai bersama.',
          'Menyediakan informasi dan tips seputar teknik memancing dan lokasi mancing terbaik.',
        ],
      ),
      _buildAnimatedAdArtCard(
        'Pasal 2: Keanggotaan',
        [],
        [
          'Anggota terbuka bagi siapa saja yang berminat dan cinta memancing.',
          'Setiap anggota diwajibkan membayar iuran perkegiatan sebesar Rp 20.000 untuk biaya kegiatan grup.',
          'Anggota baru wajib mengikuti aturan dan tata tertib yang berlaku dalam grup.',
        ],
      ),
      _buildAnimatedAdArtCard(
        'Pasal 3: Struktur Organisasi',
        [],
        [
          'Ketua: Bertanggung jawab atas keseluruhan kegiatan grup.',
          'Sekretaris: Mengelola data keanggotaan dan menyusun laporan kegiatan.',
          'Bendahara: Mengelola dana grup, termasuk iuran tahunan dan laporan keuangan.',
        ],
      ),
      _buildAnimatedAdArtCard(
        'Pasal 4: Kegiatan',
        [],
        [
          'Acara Rutin: Mengadakan kegiatan memancing bersama setiap minggu.',
          'Lomba Memancing: Dilaksanakan perkegiatan, dengan hadiah ditraktir makan dari yang kalah.',
          'Sharing Session: Diadakan saat kumpul untuk berbagi tips, pengalaman, dan lokasi memancing.',
        ],
      ),
      _buildAnimatedAdArtCard(
        'Pasal 5: Dana',
        [],
        [
          'Dana diperoleh dari iuran anggota setiap kegiatan berlangsung.',
          'Dana akan digunakan untuk biaya operasional kegiatan dan pembelian alat atau perlengkapan grup jika dibutuhkan.',
        ],
      ),
      _buildAnimatedAdArtCard(
        'Pasal 6: Aturan Tambahan',
        [],
        [
          'Setiap anggota wajib menjaga kebersihan lokasi memancing.',
          'Saling menghormati antar anggota.',
          'Tidak diperkenankan membawa alkohol atau minuman keras saat kegiatan.',
        ],
      ),
      _buildAnimatedAdArtCard(
        'Pasal 7: Perhitungan Poin Leaderboard',
        [],
        [
          'Dihitung perkegiatan bersama dengan anggota.',
          '2 poin untuk ikan yang pertama dapat perkegiatan.',
          '1 poin untuk setiap ikan yang didapat di kolam lomba perkegiatan.',
          '1/2 poin untuk setiap ikan berukuran kecil yang didapat di kolam lomba perkegiatan.',
          '1/4 poin untuk setiap ikan yang didapat di luar jenis ikan kolam lomba perkegiatan.',
          'Rentang waktu lomba perkegiatan adalah mulai dari kedatangan di tempat sampai pukul 7 pm.',
        ],
      ),
    ];
  }

  Widget _buildAnimatedAdArtCard(
      String title, List<String> content, List<String> bulletPoints) {
    return AnimatedAdArtCard(
      title: title,
      content: content,
      bulletPoints: bulletPoints,
    );
  }
}

class AnimatedAdArtCard extends StatefulWidget {
  final String title;
  final List<String> content;
  final List<String> bulletPoints;

  const AnimatedAdArtCard(
      {super.key,
      required this.title,
      required this.content,
      required this.bulletPoints});

  @override
  _AnimatedAdArtCardState createState() => _AnimatedAdArtCardState();
}

class _AnimatedAdArtCardState extends State<AnimatedAdArtCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    Timer(const Duration(milliseconds: 300), () {
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blueAccent, Colors.lightBlueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              for (var text in widget.content)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.justify,
                  ),
                ),
              if (widget.bulletPoints.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.bulletPoints
                      .map((point) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("• ",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black87)),
                                Expanded(
                                  child: Text(
                                    point,
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black87),
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
