const { awscdk, javascript, DependencyType } = require("projen");
const project = new awscdk.AwsCdkTypeScriptApp({
  cdkVersion: "2.61.0",
  defaultReleaseBranch: "main",
  name: "coffee",
  packageManager: javascript.NodePackageManager.PNPM,
  githubOptions: {
    mergify: false,
    workflows: false,
    pullRequestLint: false,
  },
  gitignore: ["cdk.context.json", "outputs.json"],
  deps: ["fs-extra"],
  devDeps: ["@types/aws-lambda", "@types/node-fetch", "@types/fs-extra"],
});

project.cdkConfig.json.addOverride("outputsFile", "outputs.json");
project.deps.addDependency("@types/node@^18", DependencyType.DEVENV);
project.synth();
