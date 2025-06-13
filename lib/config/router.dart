import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:workshop_system/views/inventory/inventory_details_view.dart';
import 'package:workshop_system/models/foreman_model.dart';
import 'package:workshop_system/repositories/payroll_repository.dart';
import 'package:workshop_system/services/payment_api_service.dart';
import 'package:workshop_system/viewmodels/manage_payroll/pending_payroll_viewmodel.dart';

import '../services/auth_service.dart';
import '../views/auth/welcome_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/foreman_register_view.dart';
import '../views/auth/workshop_register_view.dart';
import '../views/main_menu_view.dart'; // Import MainMenuView
import '../views/profile/edit_foreman_profile_view.dart'; // Import EditForemanProfileView
import '../views/profile/edit_workshop_profile_view.dart'; // Import EditWorkshopProfileView
import '../views/profile/foreman_display_profile_view.dart'; // Import ForemanDisplayProfileView
import '../views/profile/workshop_display_profile_view.dart'; // Import WorkshopDisplayProfileView
import '../views/foreman/workshop_search_view.dart'; // Import WorkshopSearchView
import '../views/manage_payroll/pending_payroll_view.dart'; // Import PendingPayrollView
import '../views/manage_payroll/salary_detail_view.dart'; // Import SalaryDetailView
import '../models/payroll_model.dart'; // For Payroll type
import '../views/inventory/inventory_list_owner_view.dart';
import '../models/inventory_item.dart';
import '../views/inventory/inventory_add_view.dart';
import '../views/inventory/inventory_edit_view.dart';
import '../views/inventory/inventory_usage_history_view.dart';
import '../views/inventory/inventory_requests_view.dart';
import 'package:workshop_system/views/manage_schedule/create_schedule_page.dart';
import 'package:workshop_system/views/manage_schedule/my_schedule_page.dart';
import 'package:workshop_system/views/manage_schedule/schedule_overview_page.dart';
import 'package:workshop_system/views/manage_schedule/slot_selection_page.dart';
// Import Rating Screens
import '../views/manage_rating/user_rating_screen.dart';
import '../views/manage_rating/all_ratings_screen.dart';

class DemoHomePage extends StatelessWidget {
  const DemoHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workshop Management System'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select User Role',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            
            // Workshop Owner Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Workshop Owner',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push('/overview/demo-workshop-123'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Manage Schedules'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Foreman Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Foreman',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.push('/select-slot/demo-foreman-123'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Book Slots'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.push('/my-schedule/demo-foreman-123'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('My Schedule'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            const Text(
              'Note: This demo uses test IDs for demonstration purposes',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

final GoRouter router = GoRouter(
  
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      redirect: (BuildContext context, GoRouterState state) {
        final authService = Provider.of<AuthService>(context, listen: false);
        // If user is not logged in, redirect to welcome. Otherwise, redirect to main menu.
        return authService.getCurrentUser() == null ? '/welcome' : '/home';
      },
    ),
 
    GoRoute(
      path: '/foreman/search-workshops',
      builder: (BuildContext context, GoRouterState state) {
        return const WorkshopSearchView();
      },
    ),
    GoRoute(
      path: '/welcome',
      builder: (BuildContext context, GoRouterState state) {
        return const WelcomeView();
      },
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginView();
      },
    ),
    GoRoute(
      path: '/register/foreman',
      builder: (BuildContext context, GoRouterState state) {
        return const ForemanRegisterView();
      },
    ),
    GoRoute(
      path: '/register/workshop',
      builder: (BuildContext context, GoRouterState state) {
        return const WorkshopRegisterView();
      },
    ),
    GoRoute(
      path: '/home', // This will now be the main menu
      builder: (BuildContext context, GoRouterState state) {
        return const MainMenuView();
      },
    ),
    //inventory routes
    GoRoute(
      path: '/inventory',
      builder: (context, state) => const InventoryListOwnerView(),
    ),
    // ➕ Add Inventory Item
    GoRoute(
      path: '/inventory/add',
      builder: (context, state) => const InventoryAddView(),
    ),

    GoRoute(
      path: '/inventory/details/:id',
      builder: (context, state) {
        final itemId = state.pathParameters['id']!;
        return InventoryDetailsView(itemId: itemId);
      },
    ),

    // 📝 Edit Inventory Item
    GoRoute(
      path: '/inventory/edit/:id',
      builder: (context, state) {
        final itemId = state.pathParameters['id']!;
        return InventoryEditView(itemId: itemId);
      },
    ),

    // 📜 View Usage History
    GoRoute(
      path: '/inventory/history',
      builder: (context, state) => const InventoryUsageHistoryView(itemId: ''),
    ),

    // ✅ Approve Item Requests
    GoRoute(
      path: '/inventory/requests',
      builder: (context, state) => const InventoryRequestsView(),
    ),
    // Rating Routes
    GoRoute(
      path: '/customer-rating',
      name: 'customerRating',
      builder: (BuildContext context, GoRouterState state) {
        return const UserRatingScreen();
      },
    ),
    GoRoute(
      path: '/my-ratings',
      name: 'myRatings',
      builder: (BuildContext context, GoRouterState state) {
        // This will show ratings filtered for the current foreman
        return const AllRatingsScreen();
      },
    ),
    GoRoute(
      path: '/all-ratings',
      name: 'allRatings',
      builder: (BuildContext context, GoRouterState state) {
        // This will show all ratings for workshop owners
        return const AllRatingsScreen();
      },
    ),
    // New Payroll Routes
     GoRoute(
      path: '/pending-payroll',
      builder: (context, state) => ChangeNotifierProvider(
        create: (context) => PendingPayrollViewModel(
          Provider.of<PayrollRepository>(context, listen: false),
          Provider.of<PaymentServiceFactory>(context, listen: false),
        ),
        child: PendingPayrollView(),
      ),
    ),
    GoRoute(
     path: '/salary-detail',
     builder: (context, state) {
        final foreman = state.extra as Foreman;
        return SalaryDetailView(foreman: foreman); 
      },  
    ),
    
    GoRoute(
      path: '/profile/foreman/:foremanId',
      builder: (BuildContext context, GoRouterState state) {
        final foremanId = state.pathParameters['foremanId']!;
        return ForemanDisplayProfileView(foremanId: foremanId);
      },
    ),
    GoRoute(
      path: '/profile/foreman/edit/:foremanId', // New route for editing
      builder: (BuildContext context, GoRouterState state) {
        final foremanId = state.pathParameters['foremanId']!;
        return EditForemanProfileView(
          foremanId: foremanId,
        ); // Points to the renamed form
      },
    ),
    GoRoute(
      path: '/profile/workshop/:workshopId',
      builder: (BuildContext context, GoRouterState state) {
        final workshopId = state.pathParameters['workshopId']!;
        return WorkshopDisplayProfileView(workshopId: workshopId);
      },
    ),
    GoRoute(
      path: '/profile/workshop/edit/:workshopId', // New route for editing
      builder: (BuildContext context, GoRouterState state) {
        final workshopId = state.pathParameters['workshopId']!;
        return EditWorkshopProfileView(
          workshopId: workshopId,
        ); // Points to the renamed form
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (BuildContext context, GoRouterState state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Profile Page')),
          body: const Center(child: Text('Profile Page Content')),
        );
      },
    ),
    GoRoute(
      path: '/workshops',
      builder: (BuildContext context, GoRouterState state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Browse Workshops')),
          body: const Center(child: Text('Browse Workshops Content')),
        );
      },
    ),
    GoRoute(
      path: '/workshops/available',
      builder: (BuildContext context, GoRouterState state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Available Workshops')),
          body: const Center(child: Text('Available Workshops Content')),
        );
      },
    ),
    GoRoute(
      path: '/foreman/applications/pending',
      builder: (BuildContext context, GoRouterState state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Pending Applications')),
          body: const Center(child: Text('Pending Applications Content')),
        );
      },
    ),
    GoRoute(
      path: '/workshop/foremen/requests',
      builder: (BuildContext context, GoRouterState state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Foreman Requests')),
          body: const Center(child: Text('Foreman Requests Content')),
        );
      },
    ),
    GoRoute(
      path: '/workshop/foremen/whitelisted',
      builder: (BuildContext context, GoRouterState state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Whitelisted Foremen')),
          body: const Center(child: Text('Whitelisted Foremen Content')),
        );
      },
    ),
    GoRoute(
      path: '/workshop/schedule/manage',
      builder: (BuildContext context, GoRouterState state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Manage Schedule')),
          body: const Center(child: Text('Manage Schedule Content')),
        );
      },
    ),
     GoRoute(
      path: '/demo',
      builder: (context, state) => const DemoHomePage(),
    ),
    // Workshop Owner Routes
    GoRoute(
      path: '/overview/:workshopId',
      builder: (context, state) => ScheduleOverviewPage(
        workshopId: state.pathParameters['workshopId']!,
      ),
    ),
    GoRoute(
      path: '/create-schedule/:workshopId',
      builder: (context, state) => CreateSchedulePage(
        workshopId: state.pathParameters['workshopId']!,
      ),
    ),
    // Foreman Routes  
    GoRoute(
      path: '/select-slot/:foremanId',
      builder: (context, state) => SlotSelectionPage(
        foremanId: state.pathParameters['foremanId']!,
      ),
    ),
    GoRoute(
      path: '/my-schedule/:foremanId',
      builder: (context, state) => MySchedulePage(
        foremanId: state.pathParameters['foremanId']!,
      ),
    ),
  ],
);
