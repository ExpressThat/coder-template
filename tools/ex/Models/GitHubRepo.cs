namespace Ex.Models;

internal sealed record GitHubRepo(
    string Name,
    string Owner,
    string Description,
    string CloneUrl,
    bool Private,
    bool Fork);
