---
name: note-reunion
description: Crée une note de réunion à partir de notes Facilitator, d'une transcription ou de notes collées (sans Work IQ).
argument-hint: "Collez les notes ou la transcription, ou indiquez un fichier de boite-de-reception/"
agent: agent
---

# Note de réunion à partir de texte collé

Follow [AGENTS.md](../../AGENTS.md). Use this prompt when Work IQ isn't available, or for a meeting the user captured some other way.

1. **Source text.** Use, in order:
   - the text the user pasted with the command,
   - a file they named in `boite-de-reception/`,
   - otherwise, list the files in `boite-de-reception/` and ask which one.
2. **Metadata.** Pull the title, date, time and participants from the text. If the title or date is missing, ask the user once for both. Don't guess them. If the `workiq` server is available and the user agrees, you may look up the matching calendar event (read-only `call_function` on `/me/calendarView` for that day) to fill in participants and `id_evenement`.
3. **Duplicates.** Search `reunions/` for the same `id_evenement`, or the same date and a similar title. If you find a match, update that note instead of creating a new one.
4. **Write** the meeting note from [templates/reunion.md](../../templates/reunion.md), in French, with `source: colle` (or `transcription` if the text is a transcript with speaker labels). Same rules as `/traiter-reunions` step 3.
5. **People and projects.** Apply step 4 of [traiter-reunions](traiter-reunions.prompt.md).
6. **Inbox.** If the source was a file in `boite-de-reception/`, move it to `boite-de-reception/traite/` once the note is written.
7. **Reply** in French: the path of the note, the people and projects updated, and the new actions assigned to the user.

Don't update `state/dernier-traitement.md`.
