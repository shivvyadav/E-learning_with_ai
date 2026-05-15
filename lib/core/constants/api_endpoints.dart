class ApiEndpoints {
  static const String login = "/auth/login";
  static const String register = "/auth/register";
  static const String forgotPassword = "/auth/forgotpassword";
  static const String verifyOtp = "/auth/verifyotp";
  static const String resetPassword = "/auth/resetpassword";

  /// Courses
  static const String courses = "/courses";
  static String courseDetail(String id) => "/course/$id";
  static String courseLessons(String id) => "/course/$id/lessons";

  /// Enrollment / Progress
  static const String enroll = "/enroll";
  static const String myEnrollments = "/my-enrollments";
  static const String updateProgress = "/updateprogress";
  static String getProgress(String courseId) => "/updateprogress/$courseId";

  /// Payment / Course selection
  static const String courseSelect = "/courseSelect";
  static const String payment = "/payment";
  static const String verify = "/verify";
}
