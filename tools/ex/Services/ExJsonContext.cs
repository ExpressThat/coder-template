using System.Text.Json.Serialization;
using Ex.Models;

namespace Ex.Services;

[JsonSerializable(typeof(GitHubRepoDto[]))]
internal sealed partial class ExJsonContext : JsonSerializerContext;
