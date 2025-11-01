import fs from "fs";
import path from "path";
import { Octokit } from "@octokit/rest";
import OpenAI from "openai";
import { execSync } from "child_process";

const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

async function run() {
  const ev = JSON.parse(fs.readFileSync(process.env.GITHUB_EVENT_PATH, "utf8"));
  if (!ev.comment || !ev.comment.body || !ev.issue) return;

  const comment = ev.comment.body;
  if (!comment.includes("@codex")) return;
  if (comment.includes("@codex approve")) return;

  const repoFull = process.env.GITHUB_REPOSITORY;
  const [owner, repo] = repoFull.split("/");
  const prNumber = ev.issue.number;

  const { data: pr } = await octokit.rest.pulls.get({ owner, repo, pull_number: prNumber });
  const branch = pr.head.ref;

  const docsDir = path.join(process.cwd(), "docs");
  const docs = fs.existsSync(docsDir)
    ? fs.readdirSync(docsDir).filter(f => f.endsWith(".md"))
        .map(f => `# ${f}\n` + fs.readFileSync(path.join(docsDir, f), "utf8")).join("\n\n---\n\n")
    : "No docs available.";

  const prompt = `
You are Codex, an autonomous Flutter engineer. The user requested:
${comment}

Use the following documentation for context:
${docs}

Modify the project under apps/app_flutter/** or lib/** as necessary.
Then output ONLY the raw updated files (overwrite content).
`;

  const res = await openai.chat.completions.create({
    model: "gpt-5",
    messages: [{ role: "user", content: prompt }],
    temperature: 0.2
  });

  const reply = res.choices[0].message.content || "";
  if (!reply) return;

  // Expect the reply to contain code blocks with filenames
  const fileMatches = [...reply.matchAll(/```([\s\S]*?)```/g)];
  if (fileMatches.length === 0) return;

  for (const block of fileMatches) {
    const lines = block[1].split("\n");
    const firstLine = lines[0].trim();
    const filePath = firstLine.startsWith("apps/") || firstLine.startsWith("lib/") ? firstLine : null;
    if (!filePath) continue;

    const content = lines.slice(1).join("\n");
    fs.mkdirSync(path.dirname(filePath), { recursive: true });
    fs.writeFileSync(filePath, content, "utf8");

    execSync(`git config user.name "Codex Bot"`);
    execSync(`git config user.email "codex-bot@neoglobalindustries.com"`);
    execSync(`git add "${filePath}"`);
  }

  execSync(`git commit -m "🤖 Codex: applied changes from '${comment.substring(0, 50)}...'" || echo "nothing to commit"`);
  execSync(`git push origin ${branch}`);

  await octokit.rest.issues.createComment({
    owner, repo, issue_number: prNumber,
    body: "✅ Codex auto-applied the requested changes and pushed to branch `" + branch + "`."
  });
}

run().catch(e => { console.error(e); process.exit(1); });
