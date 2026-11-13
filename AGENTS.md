# Instructions pour l'agent

This workspace is a **personal meeting-notes vault** for one consultant working inside a single client organization. It runs on GitHub Copilot (VS Code agent mode or Copilot CLI). The main job: turn Microsoft Teams **Facilitator** notes into well-structured, linked markdown notes that build up over time.

## Golden rules

1. **Write all vault content in French** (français québécois, registre professionnel). This includes note titles, headings, summaries, action items, and person or project pages. Keep product names, acronyms and code identifiers as they are.
2. **Never invent facts.** Only write what the source (Facilitator notes, transcript, or pasted text) says. If an owner, date or decision is unclear, write `à confirmer`. Don't fill gaps with plausible guesses.
3. **Microsoft 365 is read-only.** Through the `workiq` MCP server, only use `fetch`, `fetch_blob`, `call_function`, `retrieve`, `ask`, `list_agents`, `search_paths`, `get_schema`. **Never** call `create_entity`, `update_entity`, `delete_entity` or `do_action`. Never send mail, post in Teams, or modify calendar events.
4. **Stay inside the vault.** Only create or edit files under the folders listed below. Never edit files in `.github/`, `.vscode/`, `templates/` or `AGENTS.md` unless the user explicitly asks.
5. **Read `config/vault.yaml` first** for the user's name, timezone, organization name, and project keywords. If it's missing, copy `config/vault.example.yaml` to `config/vault.yaml` and ask the user to fill it in before going further.

## Vault layout

| Folder | Content | Template |
|---|---|---|
| `reunions/AAAA/MM/` | One note per meeting: `AAAA-MM-JJ-titre-court.md` | `templates/reunion.md` |
| `personnes/` | One note per person: `prenom-nom.md` | `templates/personne.md` |
| `projets/` | One note per project or initiative: `nom-du-projet.md` | `templates/projet.md` |
| `bilans/` | Weekly recaps: `AAAA-Sxx.md` | `templates/bilan.md` |
| `boite-de-reception/` | Raw notes or transcripts the user drops in manually | none |
| `state/` | Processing watermark (`dernier-traitement.md`) | none |

## Conventions

- **File names:** kebab-case, lowercase, no accents (`reunion-comite-donnees.md`, not `Réunion Comité Données.md`). Accents and capitals are fine *inside* notes.
- **Links:** use wikilinks `[[prenom-nom]]` and `[[nom-du-projet]]` so the vault works in Obsidian or VS Code with Foam. Link a person or project only if its note exists or you create it in the same run.
- **Dates:** ISO `AAAA-MM-JJ`. Times in the timezone from `config/vault.yaml`.
- **Action items:** markdown tasks with an owner and due date when known:
  `- [ ] Envoyer le schéma cible · [[prenom-nom]] · échéance : 2026-11-20`
  Use `échéance : à confirmer` if no date was given.
- **Frontmatter:** every note keeps the frontmatter block from its template. Don't drop fields; leave them empty if unknown.
- **Idempotence:** before creating a meeting note, search `reunions/` for the same `id_evenement` in frontmatter. If it exists, update that note instead of creating a duplicate.
- **Preserve user edits:** content below the line `<!-- notes personnelles -->` belongs to the user. Never rewrite or delete it.

## Where the notes come from

Facilitator saves its notes as a `.loop` file in the **Meetings** folder of the OneDrive of whoever turned it on. Teams transcripts are attached to the online meeting. The `/traiter-reunions` prompt describes the exact lookup order. When Work IQ isn't available, the user pastes notes with `/note-reunion`.

## Privacy

This vault holds client information. Never copy vault content into the kit's GitHub repo, a public gist, or any external service. The kit files (`.github/`, `templates/`, `AGENTS.md`, `README.md`) must stay generic: no client names, people, or project details.
