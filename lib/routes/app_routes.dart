import 'package:flutter/material.dart';

import '../screens/admin/buildings/admin_buildings.dart';
import '../screens/admin/events/admin_events.dart';
import '../screens/admin/admin_feedbacks.dart';
import '../screens/admin/admin_saveLocations.dart';
// Admin
import '../screens/admin/dashboard/admin_screen.dart';
import '../screens/admin/users/admin_userAccounts.dart';
import '../screens/guest/bazaars_guest.dart';
import '../screens/guest/building_list_guest.dart';
import '../screens/guest/campus_map_guest.dart';
import '../screens/guest/events_guest.dart';
// Guest
import '../screens/guest/home_guest.dart';
import '../screens/guest/profile_guest.dart';
import '../screens/initial/auth/forgot_password.dart';
// Auth
import '../screens/initial/auth/login.dart';
import '../screens/dashboard/settings/resetpassword.dart';
import '../screens/initial/auth/signup.dart';
import '../screens/initial/onboarding/intro1.dart';
import '../screens/initial/onboarding/intro2.dart';
import '../screens/initial/onboarding/intro3.dart';
// Onboarding
import '../screens/initial/onboarding/splash_screen.dart';
// Dashboard
import '../screens/dashboard/home/home.dart';
import '../screens/dashboard/buildings/building_list.dart';
import '../screens/dashboard/map/main_building_details.dart';
import '../screens/dashboard/map/campus_map.dart';
import '../screens/dashboard/map/charlie_building_details_screen.dart';
import '../screens/dashboard/map/interactive_map.dart';
import '../screens/dashboard/map/library_building_details_screen.dart';
import '../screens/dashboard/profile/profile.dart';
import '../screens/dashboard/settings/settings.dart';
import '../screens/dashboard/services/bazaars.dart';
import '../screens/dashboard/events/events.dart';
import '../screens/dashboard/profile/my_joined_events.dart';
import '../screens/dashboard/services/view_events.dart';
import '../screens/dashboard/events/create_event_screen.dart';
import '../screens/dashboard/profile/verify_account_screen.dart';
import '../screens/dashboard/settings/user_manual_screen.dart';
import '../screens/dashboard/about/about_us_screen.dart';




class AppRoutes {
  static const splash = '/splash';

  static const onboarding1 = '/onboarding1';
  static const onboarding2 = '/onboarding2';
  static const onboarding3 = '/onboarding3';

  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgotPassword';
  static const resetPassword = '/resetPassword';

  // Dashboard
  static const home = '/home'; // 
  static const navigateMapDetail = '/navigateMapDetail';
  static const directionGuide = '/directionGuide';
  static const campusMap = '/campusMap';
  static const interactiveMap = '/interactiveMap';
  static const mainBuildingDetails = '/mainBuildingDetails';
  static const charlieBuildingDetails = '/charlieBuildingDetails';
  static const libraryBuildingDetails = '/libraryBuildingDetails';
  static const buildings = '/buildings';
  static const events = '/events';
  static const viewEvent = '/viewEvent';
  static const myJoinedEvents = '/myJoinedEvents';
  static const foodBazaars = '/foodBazaars';
  static const profile = '/profile';
  static const createEvent = '/createEvent';
  static const verifyAccount = '/verifyAccount';
  static const aboutUs = '/about_us';
  static const settings = '/settings';
  static const userManual = '/userManual';


  // Admin
  static const admin = '/admin';
  static const adminUser = '/adminUser';
  static const adminBuildings = '/adminBuildings';
  static const adminEvents = '/adminEvents';
  static const adminFeedbacks = '/adminFeedbacks';
  static const adminSavelocations = '/adminSavelocations';

  // Guest
  static const guestHome = '/guestHome';
  static const guestCampusMap = '/guestCampusMap';
  static const guestBuildings = '/guestBuildings';
  static const guestEvents = '/guestEvents';
  static const guestBazaars = '/guestBazaars';
  static const guestProfile = '/guestProfile';



  static Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),

    onboarding1: (_) => const Intro1(),
    onboarding2: (_) => const Intro2(),
    onboarding3: (_) => const Intro3(),

    login: (_) => const LoginScreen(),
    signup: (_) => const SignupScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    resetPassword: (_) => const ResetPasswordScreen(),

    // Dashboard
    home: (_) => const HomeScreen(),
    campusMap: (_) => const CampusMapScreen(),
    interactiveMap: (_) => const InteractiveMapScreen(),
    mainBuildingDetails: (_) => const MainBuildingDetailsScreen(),
    charlieBuildingDetails: (_) => const CharlieBuildingDetailsScreen(),
    libraryBuildingDetails: (_) => const LibraryBuildingDetailsScreen(),
    profile: (_) => const ProfileScreen(),
    events: (_) => const EventsScreen(),
    myJoinedEvents: (_) => const MyJoinedEventsScreen(),
    foodBazaars: (_) => const FoodBazaarsScreen(),
    viewEvent: (_) => const ViewEventScreen(),
    settings: (_) => const SettingsScreen(),
    userManual: (_) => const UserManualScreen(),
    createEvent: (_) => const CreateEventScreen(),
    buildings: (_) => const BuildingListScreen(),
    verifyAccount: (_) => const VerifyAccountScreen(),
    aboutUs: (_) => const AboutUsScreen(),
    

    // Admin
    admin: (_) => const AdminScreen(),
    adminUser: (_) => const AdminUserAccountScreen(),
    adminBuildings: (_) => const AdminBuildingsScreen(),
    adminEvents: (_) => const AdminEventsScreen(),
    adminFeedbacks: (_) => const AdminFeedbacksScreen(),
    adminSavelocations: (_) => const AdminSavedLocationsScreen(),

    // Guest
    guestHome: (_) => const GuestHomeScreen(),
    guestCampusMap: (_) => const CampusMapGuestScreen(),
    guestBuildings: (_) => const GuestBuildingListScreen(),
    guestEvents: (_) => const GuestEventsScreen(),
    guestBazaars: (_) => const GuestFoodBazaarsScreen(),
    guestProfile: (_) => const GuestProfileScreen(),
  };
}
