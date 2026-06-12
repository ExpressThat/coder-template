using Terminal.Gui.App;
using Terminal.Gui.ViewBase;
using Terminal.Gui.Views;

namespace Ex.Ui;

internal static class MainMenu
{
    public static MainMenuAction Show(string currentDirectory)
    {
        MainMenuAction selected = MainMenuAction.Quit;

        using IApplication app = Application.Create();
        app.Init();

        using Window window = new()
        {
            Title = "ex"
        };

        Label titleLabel = new()
        {
            Text = "ex",
            X = 2,
            Y = 1,
            Width = Dim.Fill(2)
        };

        Label pathLabel = new()
        {
            Text = $"Current path: {currentDirectory}",
            X = 2,
            Y = 3,
            Width = Dim.Fill(2)
        };

        Label hintLabel = new()
        {
            Text = "Choose a tool to run.",
            X = 2,
            Y = 5,
            Width = Dim.Fill(2)
        };

        Button cloneButton = new()
        {
            Text = "Clone GitHub repository",
            X = 2,
            Y = 7,
            IsDefault = true
        };

        Button quitButton = new()
        {
            Text = "Quit",
            X = 2,
            Y = 9
        };

        cloneButton.Accepting += (_, e) =>
        {
            e.Handled = true;
            selected = MainMenuAction.CloneGitHubRepo;
            window.RequestStop();
        };

        quitButton.Accepting += (_, e) =>
        {
            e.Handled = true;
            selected = MainMenuAction.Quit;
            window.RequestStop();
        };

        window.Add(titleLabel, pathLabel, hintLabel, cloneButton, quitButton);
        app.Run(window);

        return selected;
    }
}
