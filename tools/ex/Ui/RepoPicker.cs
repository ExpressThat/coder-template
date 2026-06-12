using System.Collections.ObjectModel;
using Ex.Models;
using Terminal.Gui.App;
using Terminal.Gui.ViewBase;
using Terminal.Gui.Views;

namespace Ex.Ui;

internal static class RepoPicker
{
    public static GitHubRepo? Pick(IReadOnlyList<GitHubRepo> repos, string targetDirectory)
    {
        GitHubRepo? selected = null;

        using IApplication app = Application.Create();
        app.Init();

        using Window window = new()
        {
            Title = "ex - GitHub repo picker"
        };

        Label destinationLabel = new()
        {
            Text = $"Clone into: {targetDirectory}",
            X = 1,
            Y = 1,
            Width = Dim.Fill(1)
        };

        Label hintLabel = new()
        {
            Text = "Select a repo, press Enter or Clone. Esc closes.",
            X = 1,
            Y = 2,
            Width = Dim.Fill(1)
        };

        ObservableCollection<RepoListItem> items = new(
            repos
                .OrderBy(repo => repo.Owner, StringComparer.OrdinalIgnoreCase)
                .ThenBy(repo => repo.Name, StringComparer.OrdinalIgnoreCase)
                .Select(repo => new RepoListItem(repo)));

        ListView listView = new()
        {
            X = 1,
            Y = 4,
            Width = Dim.Fill(1),
            Height = Dim.Fill(4),
            Source = new ListWrapper<RepoListItem>(items)
        };

        Label statusLabel = new()
        {
            Text = $"{items.Count} repositories loaded.",
            X = 1,
            Y = Pos.AnchorEnd(2),
            Width = Dim.Fill(1)
        };

        Button cloneButton = new()
        {
            Text = "Clone",
            X = 1,
            Y = Pos.AnchorEnd(1),
            IsDefault = true
        };

        Button refreshButton = new()
        {
            Text = "Refresh",
            X = Pos.Right(cloneButton) + 2,
            Y = Pos.AnchorEnd(1)
        };

        Button quitButton = new()
        {
            Text = "Quit",
            X = Pos.Right(refreshButton) + 2,
            Y = Pos.AnchorEnd(1)
        };

        void SelectAndClose()
        {
            int? selectedIndex = listView.SelectedItem;
            if (selectedIndex is null || selectedIndex < 0 || selectedIndex >= items.Count)
            {
                statusLabel.Text = "Select a repository first.";
                return;
            }

            selected = items[selectedIndex.Value].Repo;
            window.RequestStop();
        }

        listView.Accepting += (_, e) =>
        {
            e.Handled = true;
            SelectAndClose();
        };
        cloneButton.Accepting += (_, e) =>
        {
            e.Handled = true;
            SelectAndClose();
        };
        refreshButton.Accepting += (_, e) =>
        {
            e.Handled = true;
            statusLabel.Text = "Refresh by restarting ex. Live refresh will come with the next command set.";
        };
        quitButton.Accepting += (_, e) =>
        {
            e.Handled = true;
            window.RequestStop();
        };

        window.Add(destinationLabel, hintLabel, listView, statusLabel, cloneButton, refreshButton, quitButton);
        app.Run(window);

        return selected;
    }
}
