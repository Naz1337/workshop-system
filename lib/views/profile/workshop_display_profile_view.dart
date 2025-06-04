import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:workshop_system/viewmodels/profile/workshop_profile_viewmodel.dart';
import 'package:workshop_system/repositories/workshop_repository.dart';
import 'package:workshop_system/services/firestore_service.dart';
import 'package:workshop_system/services/auth_service.dart'; // Import AuthService
import 'package:workshop_system/repositories/user_repository.dart'; // Import UserRepository

class WorkshopDisplayProfileView extends StatelessWidget {
  final String workshopId;

  const WorkshopDisplayProfileView({Key? key, required this.workshopId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workshop Profile'),
      ),
      body: ChangeNotifierProvider(
        create: (context) => WorkshopProfileViewModel(
          workshopRepository: Provider.of<WorkshopRepository>(context, listen: false),
          firestoreService: Provider.of<FirestoreService>(context, listen: false),
          authService: Provider.of<AuthService>(context, listen: false), // Pass AuthService
          userRepository: Provider.of<UserRepository>(context, listen: false), // Pass UserRepository
        )..loadWorkshopProfile(workshopId),
        child: Consumer<WorkshopProfileViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(child: Text('Error: ${viewModel.errorMessage}'));
            }

            if (viewModel.workshop == null) {
              return const Center(child: Text('No workshop profile found.'));
            }

            final workshop = viewModel.workshop!;
            final authService = Provider.of<AuthService>(context, listen: false);
            final currentUser = authService.getCurrentUser();
            final isOwner = currentUser != null && currentUser.uid == workshop.ownerId;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Workshop Name: ${workshop.workshopName ?? 'N/A'}', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Type of Workshop: ${workshop.typeOfWorkshop}', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Services Provided: ${workshop.serviceProvided.join(', ')}', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Payment Terms: ${workshop.paymentTerms}', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Operating Hours: ${workshop.operatingHourStart} - ${workshop.operatingHourEnd}', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Address: ${workshop.address ?? 'N/A'}', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Contact Number: ${workshop.workshopContactNumber ?? 'N/A'}', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Email: ${workshop.workshopEmail ?? 'N/A'}', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Facilities: ${workshop.facilities ?? 'N/A'}', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  if (isOwner)
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/profile/workshop/edit/${workshop.id}');
                        },
                        child: const Text('Edit Profile'),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
