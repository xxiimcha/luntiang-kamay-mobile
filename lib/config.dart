class Config {
  // API Configuration
  static const String apiUrl = 'http://localhost:5000';

  // SMTP Configuration
  static const String smtpHost = 'smtp.gmail.com'; // SMTP host (e.g., Gmail)
  static const int smtpPort = 465; // SMTP port (465 for SSL, 587 for TLS)
  static const String smtpUsername = 'charmaine.l.d.cator@gmail.com'; // SMTP username
  static const String smtpPassword = 'kohdpdenovspvffn'; // SMTP app password
  static const bool smtpUseSsl = true; // Whether to use SSL (true for port 465)
  static const String smtpFromEmail = 'charmaine.l.d.cator@gmail.com'; // Email used as "From"
}
