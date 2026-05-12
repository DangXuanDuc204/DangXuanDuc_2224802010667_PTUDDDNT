namespace backend.DTOs;

public record RegisterRequest(string FullName, string Email, string Password);
public record LoginRequest(string Email, string Password);
public record AuthResponse(string Token, UserResponse User);
public record ProfileResponse(UserResponse User);
