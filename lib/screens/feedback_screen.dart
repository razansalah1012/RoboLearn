import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/rating_stars.dart';
import '../models/feedback_model.dart';
import '../services/auth_service.dart';

class FeedbackScreen extends StatefulWidget {
  final String? workshopId;
  final String? workshopName;

  const FeedbackScreen({
    super.key,
    this.workshopId,
    this.workshopName,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  String? _selectedWorkshopId;
  String? _selectedWorkshopName;
  List<QueryDocumentSnapshot> _workshops = [];

  @override
  void initState() {
    super.initState();
    _loadWorkshops();
    if (widget.workshopId != null) {
      _selectedWorkshopId = widget.workshopId;
      _selectedWorkshopName = widget.workshopName;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkshops() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('workshops')
          .where('date', isLessThanOrEqualTo: DateTime.now())
          .orderBy('date', descending: true)
          .get();
      
      setState(() {
        _workshops = querySnapshot.docs;
      });
    } catch (e) {
      debugPrint('Error loading workshops: $e');
    }
  }

  Future<void> _submitFeedback() async {
    if (_selectedWorkshopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a workshop')),
      );
      return;
    }

    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please rate the workshop')),
      );
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please leave a comment')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final userData = await AuthService().getUserData(user.uid);
      final userName = userData?.name ?? user.email ?? 'Anonymous';

      final feedback = FeedbackModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        workshopId: _selectedWorkshopId!,
        workshopName: _selectedWorkshopName!,
        userId: user.uid,
        userName: userName,
        rating: _selectedRating,
        comment: _commentController.text.trim(),
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('feedback')
          .doc(feedback.id)
          .set(feedback.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear form
        setState(() {
          _selectedRating = 0;
          _commentController.clear();
        });
        
        // Optional: go back after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting feedback: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workshop Feedback'),
        backgroundColor: const Color(0xFF8B3A3A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rate Your Workshop Experience',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your feedback helps us improve future workshops',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            // Workshop Selection
            const Text(
              'Select Workshop',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Choose a workshop'),
                  value: _selectedWorkshopId,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Select workshop')),
                    ..._workshops.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(data['title'] ?? 'Unknown Workshop'),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedWorkshopId = value;
                      final workshop = _workshops.firstWhere(
                        (doc) => doc.id == value,
                        orElse: () => throw Exception('Workshop not found'),
                      );
                      final data = workshop.data() as Map<String, dynamic>;
                      _selectedWorkshopName = data['title'] ?? 'Workshop';
                    });
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Rating Stars
            const Text(
              'Your Rating',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Center(
              child: RatingStars(
                rating: _selectedRating,
                interactive: true,
                size: 48,
                onRatingChanged: (rating) {
                  setState(() {
                    _selectedRating = rating;
                  });
                },
              ),
            ),
            if (_selectedRating > 0)
              Center(
                child: Text(
                  _getRatingText(_selectedRating),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Comment Field
            const Text(
              'Your Feedback',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Share your thoughts about the workshop...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B3A3A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Feedback',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1: return 'Very Poor';
      case 2: return 'Poor';
      case 3: return 'Average';
      case 4: return 'Good';
      case 5: return 'Excellent!';
      default: return '';
    }
  }
}