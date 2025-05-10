class RoleNavWidgetsList {
  //the outer map represents the roleID and the map for the tile details
  //the inner map maps the wdget component with the widget content

  static Map<int, List<Map<String, String>>> get navItems {
    return {
      //Admin
      1: [
        {
          'title': 'Bookings',
          'icon': 'history',
          'destinationPath': '/view_bookings',
        },
      ],
      //Driver
      2: [],
      //User
      3: [
        {
          'title': 'My Bookings',
          'icon': 'history',
          'destinationPath': '/view_bookings',
        },
        {
          'title': 'Contact Us',
          'icon': 'email',
          'destinationPath': '/contact_us',
        },
      ],
    };
  }
}
