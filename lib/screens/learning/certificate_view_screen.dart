import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/certificate_model.dart';
import '../../theme/app_colors.dart';

class CertificateViewScreen extends StatelessWidget {
  final Certificate certificate;

  const CertificateViewScreen({super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text("Digital Credential", style: GoogleFonts.orbitron(fontSize: 14)),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCertificateGraphic(context),
              const SizedBox(height: 40),
              _buildShareButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertificateGraphic(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.4,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 20)],
        ),
        child: Stack(
          children: [
            // Border Frame
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.cranberry, width: 2),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png', height: 50, errorBuilder: (c, e, s) => const Icon(Icons.verified, size: 50, color: AppColors.cranberry)),
                  const SizedBox(height: 20),
                  Text("AL JAZARI INNOVATION HUB", style: GoogleFonts.orbitron(fontSize: 10, letterSpacing: 2, color: AppColors.taupe)),
                  const SizedBox(height: 10),
                  Text("CERTIFICATE", style: GoogleFonts.orbitron(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.cranberry)),
                  Text("OF ACHIEVEMENT", style: GoogleFonts.orbitron(fontSize: 14, letterSpacing: 4, color: AppColors.plum)),
                  const SizedBox(height: 30),
                  Text("PROUDLY PRESENTED TO", style: GoogleFonts.exo2(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Text(certificate.userName.toUpperCase(), style: GoogleFonts.exo2(fontSize: 24, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                  const SizedBox(height: 20),
                  Text("For successfully architecting and completing the technical module", style: GoogleFonts.exo2(fontSize: 11, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 8),
                  Text(certificate.courseTitle, style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.plum)),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Signature(label: "Hub Director"),
                      Text("Issued: ${certificate.issuedAt.day}/${certificate.issuedAt.month}/${certificate.issuedAt.year}", style: GoogleFonts.exo2(fontSize: 9)),
                      _Signature(label: "Technical Lead"),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return ElevatedButton.icon(
      onPressed: () {},
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.cranberry, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
      icon: const Icon(Icons.share, color: Colors.white),
      label: const Text("SHARE CREDENTIAL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}

class _Signature extends StatelessWidget {
  final String label;
  const _Signature({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(width: 80, child: Divider(color: Colors.black)),
        Text(label, style: GoogleFonts.exo2(fontSize: 8, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
