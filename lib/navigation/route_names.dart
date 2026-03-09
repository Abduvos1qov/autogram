/// Route name constants

abstract class RouteNames {
  // Auth routes
  static const splash = 'splash';
  static const onboarding = 'onboarding';
  static const login = 'login';
  static const register = 'register';
  static const verification = 'verification';
  static const username = 'username';
  static const forgotPassword = 'forgotPassword';

  // Main routes
  static const home = 'home';
  static const reels = 'reels';
  static const search = 'search';
  static const chat = 'chat';
  static const profile = 'profile';

  // Detail routes
  static const listing = 'listing';
  static const seller = 'seller';
  static const chatDetail = 'chatDetail';
  static const filter = 'filter';

  // Profile routes
  static const editProfile = 'editProfile';
  static const settings = 'settings';
  static const saved = 'saved';
  static const notifications = 'notifications';

  // Seller routes
  static const upgrade = 'upgrade';
  static const upgradeBusinessInfo = 'upgradeBusinessInfo';
  static const upgradePlanSelection = 'upgradePlanSelection';
  static const upgradeSuccess = 'upgradeSuccess';
  static const subscription = 'subscription';

  // Team routes
  static const teamMembers = 'teamMembers';
  static const addMember = 'addMember';
  static const memberDetail = 'memberDetail';
  static const activityLog = 'activityLog';
}

abstract class RoutePaths {
  // Auth paths
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const verification = '/verification';
  static const username = '/username';
  static const forgotPassword = '/forgot-password';

  // Main paths (tabs)
  static const home = '/';
  static const reels = '/reels';
  static const search = '/search';
  static const chat = '/chat';
  static const profile = '/profile';

  // Detail paths
  static const listing = '/listing/:id';
  static const seller = '/seller/:id';
  static const chatDetail = '/chat/:id';
  static const filter = '/search/filter';

  // Profile paths
  static const editProfile = '/profile/edit';
  static const settings = '/settings';
  static const saved = '/saved';
  static const notifications = '/notifications';

  // Seller paths
  static const upgrade = '/upgrade';
  static const upgradeBusinessInfo = '/upgrade/business-info';
  static const upgradePlanSelection = '/upgrade/plan-selection';
  static const upgradeSuccess = '/upgrade/success';
  static const subscription = '/subscription';

  // Team paths
  static const teamMembers = '/team';
  static const addMember = '/team/add';
  static const memberDetail = '/team/member/:id';
  static const activityLog = '/team/activity';
}
