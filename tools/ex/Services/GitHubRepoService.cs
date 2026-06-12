using System.Net.Http.Headers;
using System.Net.Http.Json;
using Ex.Models;

namespace Ex.Services;

internal sealed class GitHubRepoService
{
    public async Task<IReadOnlyList<GitHubRepo>> ListPublicReposAsync(IEnumerable<string> owners)
    {
        using HttpClient http = new();
        http.DefaultRequestHeaders.UserAgent.Add(new ProductInfoHeaderValue("ex", "1.0"));
        http.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/vnd.github+json"));

        List<GitHubRepo> repos = [];
        foreach (string owner in owners)
        {
            string kind = owner.Equals("ExpressThat", StringComparison.OrdinalIgnoreCase) ? "orgs" : "users";
            string url = $"https://api.github.com/{kind}/{Uri.EscapeDataString(owner)}/repos?per_page=100&type=all&sort=updated";
            GitHubRepoDto[]? ownerRepos = await http.GetFromJsonAsync(url, ExJsonContext.Default.GitHubRepoDtoArray);

            if (ownerRepos is null)
            {
                continue;
            }

            foreach (GitHubRepoDto repo in ownerRepos)
            {
                if (string.IsNullOrWhiteSpace(repo.Name) || string.IsNullOrWhiteSpace(repo.CloneUrl))
                {
                    continue;
                }

                repos.Add(new GitHubRepo(
                    repo.Name,
                    repo.Owner?.Login ?? owner,
                    repo.Description ?? string.Empty,
                    repo.CloneUrl,
                    repo.Private,
                    repo.Fork));
            }
        }

        return repos;
    }
}
