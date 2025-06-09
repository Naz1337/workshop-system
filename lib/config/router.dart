import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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

final GoRouter router = GoRouter(
  initialLocation: '/pending-payroll', // Temporary direct start to test payroll
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
    // New Payroll Routes
     GoRoute(
      path: '/pending-payroll',
      builder: (context, state) => PendingPayrollView(),
    ),
    GoRoute(
      path: '/salary-detail',
      builder: (context, state) {
        final payroll = state.extra as Payroll;
        return SalaryDetailView(payroll: payroll);
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
        return EditForemanProfileView(foremanId: foremanId); // Points to the renamed form
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
        return EditWorkshopProfileView(workshopId: workshopId); // Points to the renamed form
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (BuildContext context, GoRouterState state) {
        return Scaffold(appBar: AppBar(title: const Text('Profile Page')), body: const Center(child: Text('Profile Page Content')));
      },
    ),
    GoRoute(
      path: '/workshops',
      builder: (BuildContext context, GoRouterState state) {
        return Scaffold(appBar: AppBar(title: const Text('Browse Workshops')), body: const Center(child: Text('Browse Workshops Content')));
      },
    ),
    GoRoute(
      path: '/workshops/available',
      builder: (BuildContext context, GoRouterState state) {
        return Scaffold(appBar: AppBar(title: const Text('Available Workshops')), body: const Center(child: Text('Available Workshops Content')));
      },
    ),
    GoRoute(
      path: '/foreman/applications/pending',
      builder: (BuildContext context, GoRouterState state) {
        return Scaffold(appBar: AppBar(title: const Text('Pending Applications')), body: const Center(child: Text('Pending Applications Content')));
      },
    ),
    GoRoute(
      path: '/workshop/foremen/requests',
      builder: (BuildContext context, GoRouterState state) {
        return Scaffold(appBar: AppBar(title: const Text('Foreman Requests')), body: const Center(child: Text('Foreman Requests Content')));
      },
    ),
    GoRoute(
      path: '/workshop/foremen/whitelisted',
      builder: (BuildContext context, GoRouterState state) {
        return Scaffold(appBar: AppBar(title: const Text('Whitelisted Foremen')), body: const Center(child: Text('Whitelisted Foremen Content')));
      },
    ),
    GoRoute(
      path: '/workshop/schedule/manage',
      builder: (BuildContext context, GoRouterState state) {
        return Scaffold(appBar: AppBar(title: const Text('Manage Schedule')), body: const Center(child: Text('Manage Schedule Content')));
      },
    ),
    
  ],
  
);

