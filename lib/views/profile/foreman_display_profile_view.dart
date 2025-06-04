import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:workshop_system/viewmodels/profile/foreman_profile_viewmodel.dart';
import 'package:workshop_system/repositories/foreman_repository.dart';
import 'package:workshop_system/services/firestore_service.dart';
import 'package:workshop_system/services/auth_service.dart'; // Import AuthService

class ForemanDisplayProfileView extends StatelessWidget {
  final String foremanId;

  const ForemanDisplayProfileView({Key? key, required this.foremanId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foreman Profile'),
      ),
      body: ChangeNotifierProvider(
        create: (context) => ForemanProfileViewModel(
          foremanRepository: Provider.of<ForemanRepository>(context, listen: false),
          firestoreService: Provider.of<FirestoreService>(context, listen: false),
        )..loadForemanProfile(foremanId),
        child: Consumer<ForemanProfileViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(child: Text('Error: ${viewModel.errorMessage}'));
            }

            if (viewModel.foreman == null) {
              return const Center(child: Text('No foreman profile found.'));
            }

            final foreman = viewModel.foreman!;
            final authService = Provider.of<AuthService>(context, listen: false);
            final currentUser = authService.getCurrentUser();
            final isOwner = currentUser != null && currentUser.uid == foreman.userId;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${foreman.foremanName}', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Email: ${foreman.foremanEmail}', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Bank Account No.: ${foreman.foremanBankAccountNo}', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Years of Experience: ${foreman.yearsOfExperience}', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Past Experience Details: ${foreman.pastExperienceDetails ?? 'N/A'}', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Skills: ${foreman.skills ?? 'N/A'}', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  if (isOwner)
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/profile/foreman/edit/${foreman.id}');
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
