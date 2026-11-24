/// One demo account a tester can log in with. All details are made up.
class DemoAccount {
  const DemoAccount({
    required this.id,
    required this.email,
    required this.name,
    required this.note,
  });

  /// Short key used to pick the account's sample farm data.
  final String id;

  final String email;

  /// Full name, for example "Rahim Uddin".
  final String name;

  /// The short line shown next to the account in the demo accounts box.
  final String note;

  /// First name only, used in the greeting.
  String get firstName => name.split(' ').first;
}

/// The three demo accounts. There is no backend, so these are the only logins.
class DemoAccounts {
  const DemoAccounts._();

  /// The password for every demo account. Case-sensitive.
  static const String password = 'Farm@123';

  static const DemoAccount farmer = DemoAccount(
    id: 'farmer',
    email: 'farmer@harvestly.test',
    name: 'Rahim Uddin',
    note: 'Full farm with sample data',
  );

  static const DemoAccount poultry = DemoAccount(
    id: 'poultry',
    email: 'poultry@harvestly.test',
    name: 'Nadia Akter',
    note: 'Hens only, no fields',
  );

  static const DemoAccount newFarm = DemoAccount(
    id: 'new',
    email: 'new@harvestly.test',
    name: 'Sam Hossain',
    note: 'Empty farm, first-time setup',
  );

  static const List<DemoAccount> all = <DemoAccount>[farmer, poultry, newFarm];

  /// Finds an account by email. Case and outer spaces are ignored.
  static DemoAccount? findByEmail(String email) {
    final String cleaned = email.trim().toLowerCase();
    for (final DemoAccount account in all) {
      if (account.email == cleaned) return account;
    }
    return null;
  }

  /// True when the email matches an account and the password is exactly right.
  static DemoAccount? signIn(String email, String password) {
    final DemoAccount? account = findByEmail(email);
    if (account == null) return null;
    return password == DemoAccounts.password ? account : null;
  }
}
