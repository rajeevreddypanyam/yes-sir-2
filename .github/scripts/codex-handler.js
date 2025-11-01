import fs from "fs";
import path from "path";
import { Octokit } from "@octokit/rest";
import OpenAI from "openai";

const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

async function run() {
  const eventPath = process.env.GITHUB_EVENT_PATH;
  const event = JSON.parse(fs.readFileSync(eventPath, "utf8"));

  const repo = process.env.GITHUB_REPOSITORY;
  const [owner, repoName] = repo.split("/");

  if (event.comment && event.comment.body.includes("@codex")) {
    const instruction = event.comment.body;
    console.log("🧠 Codex instruction:", instruction);

    // Load docs as context
    const docsDir = path.join(process.cwd(), "docs");
    const docs = fs.readdirSync(docsDir)
      .filter(f => f.endsWith(".md"))
      .map(f => fs.readFileSync(path.join(docsDir, f), "utf8"))
      .join("\n\n---\n\n");

    // Ask OpenAI for a code diff suggestion
    const response = await openai.chat.completions.create({
      model: "gpt-5",
      messages: [
        { role: "system", content: "You are Codex, an expert developer assistant for the YES SIR Flutter app." },
        { role: "user", content: `Context:\n${docs}\n\nUser request:\n${instruction}` }
      ]
    });

    const suggestion = response.choices[0].message.content;
    console.log("AI Suggestion:", suggestion);

    // Comment back to GitHub with preview info
    await octokit.issues.createComment({
      owner,
      repo: repoName,
      issue_number: event.issue.number,
      body: `🧠 Codex processed your request:\n\n${suggestion}`
    });
  }
}

run().catch(err => {
  console.error("Codex run failed:", err);
  process.exit(1);
});
