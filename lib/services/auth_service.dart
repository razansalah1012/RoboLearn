class AuthService {
  String mockLogin(String email) {
    if (email == "admin@gmail.com") {
      return "admin";
    } else {
      return "member";
    }
  }
}