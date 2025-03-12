class RoleNavWidgetsList {
  //the outer map represents the roleID and the map for the tile details
  //the inner map maps the wdget component with the widget content

  static Map<int, List<Map<String, String>>> get navItems {
    return {
      1: [
        {
          'title': 'Upcoming Bookings',
          'icon': 'edit_calendar',
          'destinationPath': '/upcoming_bookings_driver',
        },
        {
          'title': 'Bookings',
          'icon': 'history',
          'destinationPath': '/view_bookings',
        },
      ],
      2: [
        {
          'title': 'Bookings',
          'icon': 'history',
          'destinationPath': '/view_bookings',
        },
        {
          'title': 'Add Booking',
          'icon': 'post_add',
          'destinationPath': '/book_ride',
        },
        {'title': 'Users', 'icon': 'people', 'destinationPath': '/users'},
      ],
      3: [
        {
          'title': 'Book a Ride!',
          'icon': 'post_add',
          'destinationPath': '/book_ride',
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
