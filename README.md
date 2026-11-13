# copilot-meeting-vault

A starter kit that turns Microsoft Teams **Facilitator** notes into a linked markdown vault, using **GitHub Copilot** (VS Code agent mode or Copilot CLI) and Microsoft's **Work IQ MCP** server. All vault content is written in **French**.

It's built for a single consultant working inside one client organization: one vault, one Microsoft 365 tenant, no multi-account setup. The vault lives in your OneDrive. This repo only holds the kit: instructions, prompts and templates. No meeting content is ever committed.

## What you get

| Command | What it does |
|---|---|
| `/traiter-reunions` | Pulls the Facilitator notes (or the Teams transcript as a fallback) for your recent meetings, then creates or updates meeting, person and project notes |
| `/note-reunion` | Same result from pasted text or a file in `boite-de-reception/`, for when Work IQ isn't available |
| `/actions-ouvertes` | Lists open action items by owner and due date, and can close them |
| `/bilan-semaine` | Writes the weekly recap: decisions, progress by project, actions |
| `/preparer-reunion` | Briefs you for an upcoming meeting from what the vault already knows |

Each run builds on the last. Person notes collect meeting history and open actions. Project notes collect decisions and status. Wikilinks connect everything, so the vault also works in Obsidian or VS Code with Foam.

## Layout

```
AGENTS.md                      rules every prompt follows (French, read-only M365, no invented facts)
.github/prompts/*.prompt.md    the slash commands
.github/instructions/          style rules applied when editing notes
.vscode/mcp.json, .mcp.json    Work IQ MCP server config (both VS Code formats)
templates/                     reunion, personne, projet, bilan
config/vault.example.yaml      copy to config/vault.yaml (gitignored)
reunions/AAAA/MM/              meeting notes          ┐
personnes/                     one note per person    │ private,
projets/                       one note per project   │ gitignored
bilans/                        weekly recaps          │
boite-de-reception/            raw notes to process   │
state/                         processing watermark   ┘
```

## Requirements

- VS Code with GitHub Copilot Chat (agent mode), **or** GitHub Copilot CLI
- A Microsoft 365 account with a **Microsoft 365 Copilot** license (Facilitator needs one)
- Work IQ MCP allowed in your tenant. If your admin has blocked it, use `/note-reunion` with pasted notes. Everything else still works.
- Facilitator turned on in your Teams meetings, with the meeting language set to French

## Setup

1. **Get the kit.** Download this repo as a ZIP (Code → Download ZIP) and extract it into a folder in your OneDrive, for example `OneDrive/coffre-reunions/`. If git is available, `git clone` works too.
2. **Open the folder in VS Code.**
3. **Configure.** Copy `config/vault.example.yaml` to `config/vault.yaml` and fill in your name, email, organization and project keywords.
4. **Connect Work IQ.**
   - *VS Code:* the server is predefined in `.vscode/mcp.json` (and `.mcp.json` for newer builds). Open the MCP servers view, start `workiq`, and sign in with your Microsoft 365 account when the browser opens.
   - *Copilot CLI:* run `copilot`, then `/plugin marketplace add microsoft/work-iq` and `/plugin install workiq@work-iq`, then restart. See [Microsoft's quickstart](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/work-iq/mcp/quickstart/github-copilot-cli).
5. **First run.** In Copilot Chat (agent mode), type `/traiter-reunions hier`. Approve the Work IQ read calls when VS Code asks. You can allow them for the session.

## Daily use

- After your meetings, or each morning: `/traiter-reunions` (with no argument, it picks up from the last run).
- Meetings show up as `source: aucune` when the Facilitator notes weren't ready yet. The next run retries them.
- Review each note and change `statut: brouillon` to `statut: revu`. Write your own thoughts below `<!-- notes personnelles -->`. The prompts never touch that part.
- Fridays: `/bilan-semaine`. Before a meeting: `/preparer-reunion prochaine`.

## How notes are found

For each finished online meeting in the date range, `/traiter-reunions` tries these sources in order:

1. **Facilitator.** The `.loop` notes file in the `Meetings` OneDrive folder, read through Copilot (`ask` with the file URL). If no file is found, it falls back to a Meetings-scoped `retrieve`.
2. **Transcript.** The Teams transcript (VTT), from which Copilot writes the note itself.
3. **Nothing.** A metadata-only note that gets retried on the next run.

Microsoft 365 access is **read-only**. `AGENTS.md` forbids all write tools, `.mcp.json` only exposes the read tools, and Work IQ blocks mutations by default at the tenant level.

## Privacy

- Everything under `reunions/`, `personnes/`, `projets/`, `bilans/`, `boite-de-reception/`, `state/`, plus `config/vault.yaml`, is gitignored.
- The `garde-confidentialite` GitHub Action fails if vault content ever lands in the repo. Install `scripts/verifier-avant-commit.sh` as a pre-commit hook if you use git locally.
- The kit itself must stay generic. Never add client names, people or project details to the prompts, templates or this README.

## Updating the kit

Download the new version and copy over `AGENTS.md`, `.github/`, `.vscode/`, `.mcp.json` and `templates/`. Your notes, `config/vault.yaml` and `state/` are left alone.

## Known limits

- Facilitator notes only exist for meetings where someone turned Facilitator on. It isn't supported in 1:1 chats, group chats or external meetings.
- Facilitator only takes notes in the meeting language selected when it started. Bilingual meetings get partial notes.
- Transcripts are often only accessible to the organizer. A `403` on the transcript step is expected, and the prompt moves on.
- Graph collections are capped at 100 items per call and paging is blocked, so the calendar is read one day at a time and runs are limited to 14 days.
- Copilot reads the `.loop` file through Microsoft 365 Copilot, so the note is a faithful restructuring, not a byte-for-byte copy. The link to the original is kept in `lien_notes`.

## License

MIT
