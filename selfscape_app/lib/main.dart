// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Added provider package

// Import provider and service
import 'features/inventory/providers/acquisition_provider.dart';
import 'features/inventory/data/inventory_api_service.dart';

// Import a placeholder for the inventory overview screen, or create a dummy one.
// For now, we'll keep the dummy home screen and assume InventoryOverviewScreen will use the provider.
import 'features/inventory/screens/inventory_overview_screen.dart'; // Assuming this screen will use the provider


void main() {
  final inventoryApiService = InventoryApiService(); // Create service instance

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AcquisitionProvider(inventoryApiService),
        ),
        // Potentially other providers in the future
      ],
      child: const SelfScapeApp(),
    ),
  );
}

class SelfScapeApp extends StatelessWidget {
  const SelfScapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SelfScape',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Consider defining color schemes for more modern theming
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // useMaterial3: true,
      ),
      // The InventoryOverviewScreen would typically be the entry point for this feature
      // and would use Provider.of<AcquisitionProvider>(context) to interact with the state.
      home: const InventoryOverviewScreen(), // Changed to InventoryOverviewScreen
      // home: Scaffold(
      //   appBar: AppBar(title: const Text('SelfScape Home')),
      //   body: const Center(child: Text('Welcome to SelfScape! Inventory module coming soon.')),
      // ),
    );
  }
}
