namespace Ex.Models;

internal sealed record RepoListItem(GitHubRepo Repo)
{
    public override string ToString()
    {
        string flags = Repo.Fork ? " fork" : string.Empty;
        string description = string.IsNullOrWhiteSpace(Repo.Description) ? string.Empty : $" - {Repo.Description}";
        return $"{Repo.Owner}/{Repo.Name}{flags}{description}";
    }
}
