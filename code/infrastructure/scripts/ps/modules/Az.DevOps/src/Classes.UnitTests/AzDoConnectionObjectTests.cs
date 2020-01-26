using FluentAssertions;
using NUnit.Framework;
using Az.DevOps;

namespace Tests
{
  public class AzDoConnectionObjectTests
  {
    [SetUp]
    public void Setup()
    {
    }

    [Test]
    public void ValidClassicOrganizationUrlParseTest()
    {
      var conn = AzDoConnectObject.CreateFromUrl("https://qpublic.visualstudio.com");

      conn.OrganizationName.Should().BeEquivalentTo("qpublic");
      conn.ProjectName.Should().BeNullOrEmpty();
      conn.OrganizationUrl.Should().BeEquivalentTo("https://dev.azure.com/qpublic");
      conn.ProjectUrl.Should().BeNullOrEmpty();
    }

    [Test]
    public void InValidClassicOrganizationUrlParseTest()
    {
      var conn = AzDoConnectObject.CreateFromUrl("https://visualstudio.com/qpublic/OpenDevOps");

      conn.OrganizationName.Should().BeNullOrEmpty();
      conn.ProjectName.Should().BeNullOrEmpty();
      conn.OrganizationUrl.Should().BeNullOrEmpty();
      conn.ProjectUrl.Should().BeNullOrEmpty();
    }

    [Test]
    public void ValidClassicProjectUrlParseTest()
    {
      var conn = AzDoConnectObject.CreateFromUrl("https://qpublic.visualstudio.com/OpenDevOps");

      conn.OrganizationName.Should().BeEquivalentTo("qpublic");
      conn.ProjectName.Should().BeEquivalentTo("OpenDevOps");
      conn.OrganizationUrl.Should().BeEquivalentTo("https://dev.azure.com/qpublic");
      conn.ProjectUrl.Should().BeEquivalentTo("https://dev.azure.com/qpublic/OpenDevOps");
    }

    [Test]
    public void ValidOrganizationUrlParseTest()
    {
      var conn = AzDoConnectObject.CreateFromUrl("https://dev.azure.com/qpublic/");

      conn.OrganizationName.Should().BeEquivalentTo("qpublic");
      conn.ProjectName.Should().BeNullOrEmpty();
      conn.OrganizationUrl.Should().BeEquivalentTo("https://dev.azure.com/qpublic");
      conn.ProjectUrl.Should().BeNullOrEmpty();
    }

    [Test]
    public void ValidProjectUrlParseTest()
    {
      var conn = AzDoConnectObject.CreateFromUrl("https://dev.azure.com/qpublic/OpenDevOps");

      conn.OrganizationName.Should().BeEquivalentTo("qpublic");
      conn.ProjectName.Should().BeEquivalentTo("OpenDevOps");
      conn.OrganizationUrl.Should().BeEquivalentTo("https://dev.azure.com/qpublic");
      conn.ProjectUrl.Should().BeEquivalentTo("https://dev.azure.com/qpublic/OpenDevOps");
    }
  }
}