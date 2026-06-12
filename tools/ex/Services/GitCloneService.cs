using CliWrap;
using Ex.Models;

namespace Ex.Services;

internal sealed class GitCloneService
{
    public async Task<int> CloneAsync(GitHubRepo repo, string targetDirectory)
    {
        Console.WriteLine($"Cloning {repo.Owner}/{repo.Name} into {targetDirectory}");

        CommandResult result = await Cli.Wrap("git")
            .WithArguments(["clone", repo.CloneUrl])
            .WithWorkingDirectory(targetDirectory)
            .WithValidation(CommandResultValidation.None)
            .ExecuteAsync();

        return result.ExitCode;
    }
}
