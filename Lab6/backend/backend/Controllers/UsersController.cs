using System.Security.Claims;
using backend.Data;
using backend.DTOs;
using backend.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace backend.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class UsersController(AppDbContext db, PasswordHasher<AppUser> passwordHasher) : ControllerBase
{
    [HttpGet]
    [Authorize(Roles = $"{AppRoles.Admin},{AppRoles.Manager}")]
    public async Task<ActionResult<IEnumerable<UserResponse>>> GetUsers()
    {
        var current = await CurrentUser();
        if (current is null)
        {
            return Unauthorized();
        }

        var query = db.Users.AsNoTracking();
        if (current.Role == AppRoles.Manager)
        {
            query = query.Where(u => u.Role != AppRoles.Admin);
        }

        return Ok(await query
            .OrderByDescending(u => u.CreatedAt)
            .Select(u => new UserResponse(u.Id, u.FullName, u.Email, u.Role, u.IsActive, u.CreatedAt))
            .ToListAsync());
    }

    [HttpGet("{id:int}")]
    [Authorize(Roles = $"{AppRoles.Admin},{AppRoles.Manager}")]
    public async Task<ActionResult<UserResponse>> GetUser(int id)
    {
        var current = await CurrentUser();
        var target = await db.Users.AsNoTracking().FirstOrDefaultAsync(u => u.Id == id);
        if (current is null)
        {
            return Unauthorized();
        }

        return target is null
            ? NotFound()
            : CanAccessTarget(current, target)
                ? Ok(target.ToResponse())
                : Forbid();
    }

    [HttpPost]
    [Authorize(Roles = $"{AppRoles.Admin},{AppRoles.Manager}")]
    public async Task<ActionResult<UserResponse>> CreateUser(CreateUserRequest request)
    {
        var current = await CurrentUser();
        if (current is null)
        {
            return Unauthorized();
        }

        var role = NormalizeRole(request.Role);
        if (role is null)
        {
            return BadRequest(new { message = "Role không hợp lệ." });
        }

        if (current.Role == AppRoles.Manager && role is AppRoles.Admin or AppRoles.Manager)
        {
            return Forbid();
        }

        var email = request.Email.Trim().ToLowerInvariant();
        if (await db.Users.AnyAsync(u => u.Email == email))
        {
            return BadRequest(new { message = "Email đã tồn tại." });
        }

        var user = new AppUser
        {
            FullName = request.FullName.Trim(),
            Email = email,
            Role = role,
            IsActive = request.IsActive,
            CreatedAt = DateTime.UtcNow
        };
        user.PasswordHash = passwordHasher.HashPassword(user, request.Password);

        db.Users.Add(user);
        await db.SaveChangesAsync();

        return CreatedAtAction(nameof(GetUser), new { id = user.Id }, user.ToResponse());
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = $"{AppRoles.Admin},{AppRoles.Manager}")]
    public async Task<ActionResult<UserResponse>> UpdateUser(int id, UpdateUserRequest request)
    {
        var current = await CurrentUser();
        var target = await db.Users.FirstOrDefaultAsync(u => u.Id == id);
        if (current is null)
        {
            return Unauthorized();
        }

        if (target is null)
        {
            return NotFound();
        }

        if (!CanModifyTarget(current, target))
        {
            return Forbid();
        }

        var role = NormalizeRole(request.Role);
        if (role is null)
        {
            return BadRequest(new { message = "Role không hợp lệ." });
        }

        if (current.Role == AppRoles.Manager && role is AppRoles.Admin or AppRoles.Manager)
        {
            return Forbid();
        }

        var email = request.Email.Trim().ToLowerInvariant();
        if (await db.Users.AnyAsync(u => u.Email == email && u.Id != id))
        {
            return BadRequest(new { message = "Email đã tồn tại." });
        }

        target.FullName = request.FullName.Trim();
        target.Email = email;
        target.Role = role;
        target.IsActive = request.IsActive;
        await db.SaveChangesAsync();

        return Ok(target.ToResponse());
    }

    [HttpDelete("{id:int}")]
    [Authorize(Roles = AppRoles.Admin)]
    public async Task<IActionResult> DeleteUser(int id)
    {
        var target = await db.Users.FirstOrDefaultAsync(u => u.Id == id);
        if (target is null)
        {
            return NotFound();
        }

        target.IsActive = false;
        await db.SaveChangesAsync();
        return NoContent();
    }

    [HttpPut("{id:int}/activate")]
    [Authorize(Roles = AppRoles.Admin)]
    public async Task<ActionResult<UserResponse>> ActivateUser(int id)
    {
        var target = await db.Users.FirstOrDefaultAsync(u => u.Id == id);
        if (target is null)
        {
            return NotFound();
        }

        target.IsActive = true;
        await db.SaveChangesAsync();
        return Ok(target.ToResponse());
    }

    [HttpGet("me")]
    public async Task<ActionResult<UserResponse>> Me()
    {
        var user = await CurrentUser();
        return user is null ? Unauthorized() : Ok(user.ToResponse());
    }

    [HttpPut("me/change-password")]
    public async Task<IActionResult> ChangePassword(ChangePasswordRequest request)
    {
        var user = await CurrentUser();
        if (user is null)
        {
            return Unauthorized();
        }

        var result = passwordHasher.VerifyHashedPassword(user, user.PasswordHash, request.CurrentPassword);
        if (result == PasswordVerificationResult.Failed)
        {
            return BadRequest(new { message = "Mật khẩu hiện tại không đúng." });
        }

        user.PasswordHash = passwordHasher.HashPassword(user, request.NewPassword);
        await db.SaveChangesAsync();
        return NoContent();
    }

    private Task<AppUser?> CurrentUser()
    {
        var id = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return int.TryParse(id, out var userId)
            ? db.Users.FirstOrDefaultAsync(u => u.Id == userId && u.IsActive)
            : Task.FromResult<AppUser?>(null);
    }

    private static bool CanAccessTarget(AppUser current, AppUser target) =>
        current.Role == AppRoles.Admin || target.Role != AppRoles.Admin;

    private static bool CanModifyTarget(AppUser current, AppUser target) =>
        current.Role == AppRoles.Admin ||
        (current.Role == AppRoles.Manager && target.Role is AppRoles.Staff or AppRoles.User);

    private static string? NormalizeRole(string role) =>
        AppRoles.All.FirstOrDefault(r => string.Equals(r, role.Trim(), StringComparison.OrdinalIgnoreCase));
}
