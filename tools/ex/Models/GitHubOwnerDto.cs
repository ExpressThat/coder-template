using System.Text.Json.Serialization;

namespace Ex.Models;

internal sealed class GitHubOwnerDto
{
    [JsonPropertyName("login")]
    public string? Login { get; set; }
}
