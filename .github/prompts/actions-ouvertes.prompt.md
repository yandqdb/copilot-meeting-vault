---
name: actions-ouvertes
description: Liste les actions ouvertes du coffre, regroupées par responsable et échéance.
argument-hint: "[moi | prenom-nom | projet:nom-du-projet]  (vide = toutes)"
agent: agent
---

# Actions ouvertes

Follow [AGENTS.md](../../AGENTS.md). This prompt is **read-only**: don't edit any file unless the user asks to close an action.

1. Search `reunions/` for unchecked tasks (`- [ ]`). For each one, keep the text, the owner, the due date and the meeting note it comes from.
2. Filter by what the user typed after the command:
   - `moi`: actions whose owner is `moi.nom` from `config/vault.yaml`, or that have no owner
   - a person: actions owned by `[[prenom-nom]]`
   - `projet:nom`: actions from meetings whose `projets` includes that project
3. Reply in French, grouped like this:
   - **En retard** (due date before today)
   - **Cette semaine**
   - **Plus tard**
   - **Sans échéance** (`à confirmer`)

   Each line: `- action · responsable · échéance · [[note-reunion]]`.
4. If the user asks to close actions ("ferme 2 et 5"), check those boxes (`- [x]`) in the source meeting notes and remove the matching lines from **Actions en cours** in the person notes.
