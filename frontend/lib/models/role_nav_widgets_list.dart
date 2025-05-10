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
        {
          'title': 'Add Booking',
          'icon': 'post_add',
          'destinationPath': '/book_ridev2',
        },
        {'title': 'Users', 'icon': 'people', 'destinationPath': '/users'},
      ],
      //Driver
      2: [
        {
          'title': 'Bookings', // Title displayed in the navigation tile
          'icon': 'history', // Icon identifier used in the UI
          'destinationPath': '/view_bookings', // Route path for the screen
        },
      ],
      //User
      3: [
        {
          'title': 'Book a Ride!',
          'icon': 'post_add',
          'destinationPath': '/book_ridev2',
        },
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
