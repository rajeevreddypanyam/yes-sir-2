import fs from "fs";
import path from "path";
import { Octokit } from "@octokit/rest";
import OpenAI from "openai";

const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

async function run() {
  const ev = JSON.parse(fs.readFileSync(process.env.GITHUB_EVENT_PATH, "utf8"));
  const repoFull = process.env.GITHUB_REPOSITORY;
  const [owner, repo] = repoFull.split("/");

  if (!ev.comment || !ev.comment.body || !ev.issue) return;

  const comment = ev.comment.body;
  if (!comment.includes("@codex")) return;
  if (comment.includes("@codex approve")) return; // merge handled by other workflow

  const prNumber = ev.issue.number;
  const { data: pr } = await octokit.rest.pulls.get({ owner, repo, pull_number: prNumber });

  const docsDir = path.join(process.cwd(), "docs");
  const docs = fs.existsSync(docsDir)
    ? fs.readdirSync(docsDir).filter(f => f.endsWith(".md")).slice(0, 12)
      .map(f => `# ${f}\n` + fs.readFileSync(path.join(docsDir, f), "utf8")).join("\n\n---\n\n")
    : "No docs folder.";

  const system = "You are Codex, an expert Flutter engineer. Return clear, minimal diffs or a step-by-step plan.";
  const prompt = `
PR branch: ${pr.head.ref}
User instruction: ${comment}

Project docs:
${docs}

Produce either a minimal unified diff modifying files under apps/app_flutter/** to satisfy the instruction,
or respond with PLAN: followed by precise steps.
`;

  const res = await openai.chat.completions.create({
    model: "gpt-5",
    messages: [{ role: "system", content: system }, { role: "user", content: prompt }],
    temperature: 0.2
  });

  const reply = res.choices[0].message.content ?? "";
  const isPatch = reply.includes("--- ") && reply.includes("+++ ");

  if (isPatch) {
    // store patch artifact for review
    await octokit.rest.repos.createOrUpdateFileContents({
      owner, repo,
      path: ".codex/last_request.diff",
      message: "chore(codex): proposed patch from comment",
      content: Buffer.from(reply, "utf8").toString("base64"),
      branch: pr.head.ref
    });
    await octokit.rest.issues.createComment({
      owner, repo, issue_number: prNumber,
      body: "🧩 Codex produced a patch and saved it to `.codex/last_request.diff`. Review or apply it.\n\n```diff\n" + reply.slice(0, 6000) + "\n```"
    });
  } else {
    await octokit.rest.issues.createComment({
      owner, repo, issue_number: prNumber,
      body: "🧭 Codex plan:\n\n" + reply
    });
  }
}

run().catch(e => { console.error(e); process.exit(1); });
