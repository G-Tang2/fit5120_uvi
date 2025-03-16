import 'package:flutter/material.dart';

class SmallCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtext;
  final String? extraText;

  const SmallCard({
    super.key,
    required this.label,
    required this.value,
    required this.subtext,
    this.extraText,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              // icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 210, 210, 210),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  label,
                  style: TextStyle(color: const Color.fromARGB(255, 128, 128, 128)),
                ),
              ),
              const SizedBox(height: 8),
              // content
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (extraText != null)
                Text(extraText!,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),

              Text(subtext, style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }
}
