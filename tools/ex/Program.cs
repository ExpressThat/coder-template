using Ex.Models;
using Ex.Services;
using Ex.Ui;

const string appName = "ex";
string[] owners = ["ross-s", "ExpressThat"];

try
{
    string currentDirectory = Environment.CurrentDirectory;
    MainMenuAction action = MainMenu.Show(currentDirectory);

    if (action is MainMenuAction.Quit)
    {
        return 0;
    }

    if (action is MainMenuAction.CloneGitHubRepo)
    {
        GitHubRepoService repoService = new();
        IReadOnlyList<GitHubRepo> repos = await repoService.ListPublicReposAsync(owners);

        if (repos.Count == 0)
        {
            Console.Error.WriteLine("No public repositories were found for ross-s or ExpressThat.");
            return 1;
        }

        GitHubRepo? selected = RepoPicker.Pick(repos, currentDirectory);
        if (selected is null)
        {
            Console.WriteLine("No repository selected.");
            return 0;
        }

        GitCloneService cloneService = new();
        return await cloneService.CloneAsync(selected, currentDirectory);
    }

    return 0;
}
catch (Exception ex)
{
    Console.Error.WriteLine($"{appName}: {ex.Message}");
    return 1;
}
