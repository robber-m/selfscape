// lib/features/inventory/screens/acquisition_detail_screen.dart
import 'package:flutter/material.dart';
// import '../models/acquisition_model.dart';

// Placeholder class for AcquisitionDetailScreen
class AcquisitionDetailScreen extends StatelessWidget {
  // final Acquisition acquisition;

  // const AcquisitionDetailScreen({super.key, required this.acquisition});
  const AcquisitionDetailScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(acquisition.name),
        title: const Text('Acquisition Details'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Display acquisition details: image, name, description, date, source, tags
            Text('Acquisition details will be displayed here.'),
            // Example:
            // Image.network(acquisition.imageUrl),
            // SizedBox(height: 8),
            // Text('Name: ${acquisition.name}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            // SizedBox(height: 8),
            // Text('Description: ${acquisition.description}'),
            // SizedBox(height: 8),
            // Text('Date Acquired: ${DateFormat.yMMMd().format(acquisition.dateAcquired)}'),
            // SizedBox(height: 8),
            // Text('Source: ${acquisition.source}'),
            // SizedBox(height: 8),
            // Text('Tags: ${acquisition.tags.join(', ')}'),
          ],
        ),
      ),
    );
  }
}
