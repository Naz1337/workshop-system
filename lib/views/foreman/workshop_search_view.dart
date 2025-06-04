import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_system/repositories/workshop_repository.dart';
import 'package:workshop_system/repositories/user_repository.dart'; // Import UserRepository
import 'package:workshop_system/services/firestore_service.dart';
import 'package:workshop_system/viewmodels/foreman/workshop_search_viewmodel.dart';

class WorkshopSearchView extends StatelessWidget {
  const WorkshopSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WorkshopSearchViewModel(
        workshopRepository: WorkshopRepository(
          Provider.of<FirestoreService>(context, listen: false),
          Provider.of<UserRepository>(context, listen: false),
        ),
      ),
      child: Consumer<WorkshopSearchViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Search Workshops'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Search by Workshop Name',
                      suffixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (query) {
                      viewModel.onSearchQueryChanged(query);
                    },
                  ),
                  const SizedBox(height: 16.0),
                  if (viewModel.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (viewModel.errorMessage != null)
                    Center(child: Text('Error: ${viewModel.errorMessage}'))
                  else if (viewModel.workshops.isEmpty && viewModel.searchQuery.isNotEmpty)
                    const Center(child: Text('No workshops found for your search.'))
                  else if (viewModel.workshops.isEmpty && viewModel.searchQuery.isEmpty)
                    const Center(child: Text('Start typing to search for workshops.'))
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: viewModel.workshops.length,
                        itemBuilder: (context, index) {
                          final workshop = viewModel.workshops[index];
                          return InkWell(
                            onTap: () {
                              if (workshop.id != null) {
                                viewModel.selectWorkshop(context, workshop.id!);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Workshop ID is missing, cannot navigate.')),
                                );
                              }
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      workshop.workshopName ?? 'N/A',
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                  const SizedBox(height: 4.0),
                                  Text('Type: ${workshop.typeOfWorkshop}'),
                                  Text('Address: ${workshop.address ?? 'N/A'}'),
                                  Text('Contact: ${workshop.workshopContactNumber ?? 'N/A'}'),
                                  // Add more details as needed
                                ], // This closes the children list
                              ), // This closes the Column widget
                            ), // This closes the Padding widget
                          ), // This closes the Card widget
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
