import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/certificate_model.dart';
import '../../services/certificate_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import 'certificate_view_screen.dart';

class CertificateListScreen extends StatelessWidget {
  const CertificateListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _certService = CertificateService();
    final _authService = AuthService();
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text('Technical Credentials', style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.cranberry,
      ),
      body: user == null 
        ? const Center(child: Text("Please login to access credentials"))
        : StreamBuilder<List<Certificate>>(
            stream: _certService.getUserCertificates(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.cranberry));
              }
              final certs = snapshot.data ?? [];
              if (certs.isEmpty) {
                return _buildEmptyCertState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: certs.length,
                itemBuilder: (context, index) {
                  final cert = certs[index];
                  return _CertificateCard(
                    certificate: cert,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CertificateViewScreen(certificate: cert)),
                    ),
                  );
                },
              );
            },
          ),
    );
  }

  Widget _buildEmptyCertState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: AppColors.cranberry.withOpacity(0.05), shape: BoxShape.circle),
            child: const Icon(Icons.workspace_premium_outlined, size: 64, color: AppColors.taupe),
          ),
          const SizedBox(height: 24),
          Text("No Certificates Earned", style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: AppColors.cranberry)),
          const SizedBox(height: 8),
          Text("Complete a course path to unlock your credentials.", style: GoogleFonts.exo2(color: AppColors.taupe)),
        ],
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  final Certificate certificate;
  final VoidCallback onTap;

  const _CertificateCard({required this.certificate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.orange.shade50.withOpacity(0.3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.orange.shade200.withOpacity(0.5), width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified, color: Colors.orange, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      certificate.courseTitle,
                      style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.plum),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Issued: ${certificate.issuedAt.day}/${certificate.issuedAt.month}/${certificate.issuedAt.year}",
                      style: GoogleFonts.exo2(fontSize: 12, color: AppColors.taupe),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.taupe),
            ],
          ),
        ),
      ),
    );
  }
}
