using System.Text.Json.Serialization;

namespace Ex.Models;

internal sealed class GitHubRepoDto
{
    [JsonPropertyName("name")]
    public string? Name { get; set; }

    [JsonPropertyName("description")]
    public string? Description { get; set; }

    [JsonPropertyName("clone_url")]
    public string? CloneUrl { get; set; }

    [JsonPropertyName("private")]
    public bool Private { get; set; }

    [JsonPropertyName("fork")]
    public bool Fork { get; set; }

    [JsonPropertyName("owner")]
    public GitHubOwnerDto? Owner { get; set; }
}
