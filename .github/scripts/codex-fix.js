import fs from "fs";
import path from "path";
import { Octokit } from "@octokit/rest";
import OpenAI from "openai";

const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

async function run() {
  const ev = JSON.parse(fs.readFileSync(process.env.GITHUB_EVENT_PATH, "utf8"));
  const { owner, name: repo } = ev.repository;
  const runId = ev.workflow_run?.id;

  // Find head SHA & PR
  const headSha = ev.workflow_run?.head_sha;
  const prs = await octokit.rest.repos.listPullRequestsAssociatedWithCommit({ owner, repo, commit_sha: headSha });
  const pr = prs.data[0];
  if (!pr) {
    console.log("No PR associated with failed run. Exiting.");
    return;
  }

  // Summarize failing jobs/steps
  const { data: jobs } = await octokit.rest.actions.listJobsForWorkflowRun({ owner, repo, run_id: runId });
  const failing = jobs.jobs
    .filter(j => j.conclusion !== "success")
    .map(j => ({
      name: j.name,
      conclusion: j.conclusion,
      steps: j.steps?.filter(s => s.conclusion !== "success").map(s => ({ name: s.name, conclusion: s.conclusion }))
    }));

  const docsDir = path.join(process.cwd(), "docs");
  const docs = fs.existsSync(docsDir)
    ? fs.readdirSync(docsDir).filter(f => f.endsWith(".md")).slice(0, 12)
      .map(f => `# ${f}\n` + fs.readFileSync(path.join(docsDir, f), "utf8")).join("\n\n---\n\n")
    : "No docs folder.";

  const prompt = `
You are Codex, an autonomous engineer for a Flutter (web+mobile) app.
A CI workflow failed. Based on the failing jobs/steps and the project docs,
produce either:
1) A minimal patch (unified diff) to fix the failure; or
2) A clear step-by-step plan if code cannot be safely changed.

Rules:
- Prefer changes under apps/app_flutter/** .
- If the issue is formatting/lints, include direct fixes.
- If you propose a patch, output ONLY a unified diff that applies cleanly with 'git apply -p0'.
- If unsure, output a plan prefixed with PLAN:\n

Failing summary:
${JSON.stringify(failing, null, 2)}

Relevant docs:
${docs}
`;

  const res = await openai.chat.completions.create({
    model: "gpt-5",
    messages: [{ role: "user", content: prompt }],
    temperature: 0.2
  });

  const answer = res.choices[0].message.content || "";
  const isPlan = answer.trim().startsWith("PLAN:");

  if (!isPlan && answer.includes("--- ") && answer.includes("+++ ")) {
    // Try to apply patch into a branch
    const branch = pr.head.ref;
    // Fetch latest tree
    await octokit.rest.repos.createOrUpdateFileContents({
      owner, repo,
      path: ".codex/last_patch.diff",
      message: "chore(codex): store last auto patch",
      content: Buffer.from(answer, "utf8").toString("base64"),
      branch
    });

    await octokit.rest.issues.createComment({
      owner, repo, issue_number: pr.number,
      body: "🛠️ Codex generated a patch and saved it to `.codex/last_patch.diff`. Please apply & review:\n\n" +
            "```diff\n" + answer.slice(0, 6000) + "\n```"
    });
  } else {
    await octokit.rest.issues.createComment({
      owner, repo, issue_number: pr.number,
      body: "🧠 Codex analysis of CI failure:\n\n" + answer.slice(0, 65000)
    });
  }
}

run().catch(e => {
  console.error(e);
  process.exit(1);
});
