using backend.Models;

namespace backend.DTOs;

public record UserResponse(
    int Id,
    string FullName,
    string Email,
    string Role,
    bool IsActive,
    DateTime CreatedAt);

public record CreateUserRequest(
    string FullName,
    string Email,
    string Password,
    string Role,
    bool IsActive);

public record UpdateUserRequest(
    string FullName,
    string Email,
    string Role,
    bool IsActive);

public record ChangePasswordRequest(string CurrentPassword, string NewPassword);

public static class UserDtoExtensions
{
    public static UserResponse ToResponse(this AppUser user) =>
        new(user.Id, user.FullName, user.Email, user.Role, user.IsActive, user.CreatedAt);
}
