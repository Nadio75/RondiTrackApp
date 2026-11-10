class DemoUser {
  const DemoUser({required this.id, required this.name, required this.email});

  final String id;
  final String name;
  final String email;
}

const demoPassword = 'testpassword123';

const demoUsers = [
  DemoUser(id: 'user-1', name: 'Lerato', email: 'lerato@example.com'),
  DemoUser(id: 'user-2', name: 'Thabo', email: 'thabo@example.com'),
  DemoUser(id: 'user-3', name: 'Naledi', email: 'naledi@example.com'),
];

DemoUser? authenticateDemoUser(String email, String password) {
  if (password != demoPassword) return null;

  for (final user in demoUsers) {
    if (user.email.toLowerCase() == email.trim().toLowerCase()) {
      return user;
    }
  }

  return null;
}
