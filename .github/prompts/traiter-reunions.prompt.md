---
name: traiter-reunions
description: Récupère les notes Facilitator (Teams) via Work IQ et crée ou met à jour les notes de réunion, personnes et projets du coffre.
argument-hint: "[aujourd'hui | hier | semaine | AAAA-MM-JJ | AAAA-MM-JJ..AAAA-MM-JJ]  (vide = depuis le dernier traitement)"
agent: agent
---

# Traiter les réunions Teams

Follow [AGENTS.md](../../AGENTS.md) for every rule (French output, read-only Microsoft 365, no invented facts, file conventions). This prompt only adds the procedure.

## 0. Préparation

1. Read `config/vault.yaml`. If missing, stop and tell the user to copy `config/vault.example.yaml` and fill it in.
2. Confirm the `workiq` MCP server is available (its tools are listed for you). If it isn't, stop and tell the user (in French) to start it from the MCP servers view, or to use `/note-reunion` and paste the notes instead. Don't try another route.
3. Work out the date range from what the user typed after the command:
   - empty → from the `dernier_traitement` timestamp in `state/dernier-traitement.md` to now. If that file doesn't exist, use the last `reunions.jours_par_defaut` days.
   - `aujourd'hui`, `hier`, `semaine` (Monday to today), a single date, or `début..fin`.
   - Interpret dates in `fuseau_horaire`. Never process more than 14 days in one run; if the range is bigger, ask the user to confirm or narrow it.

## 1. Lister les réunions

Call `call_function` on the calendar view, **one day at a time** (collections are capped at 100 and paging with `$skip` is blocked):

```
/me/calendarView?startDateTime={jour}T00:00:00{offset}&endDateTime={jour}T23:59:59{offset}&$select=id,subject,start,end,organizer,attendees,isOnlineMeeting,onlineMeeting,isCancelled&$orderby=start/dateTime&$top=100
```

Times come back in UTC. Convert them to `fuseau_horaire` before writing anything.

Keep a meeting only if all of these are true:
- `isCancelled` is false
- `isOnlineMeeting` is true (when `reunions.en_ligne_seulement` is true)
- its subject doesn't contain any word from `reunions.ignorer_titres`
- it has already ended

Then search `reunions/` for a note whose frontmatter `id_evenement` matches the event `id`. If one exists with `source: facilitator` or `source: transcription`, skip that meeting. If one exists with `source: aucune`, retry it (the notes may be ready now).

Show the user the list (date, heure, titre, nouvelles / à réessayer / ignorées) before going further. If there are more than 8 meetings, ask for confirmation.

## 2. Récupérer les notes de chaque réunion

Try these sources **in order** and stop at the first that returns real content. Record which one worked in `source`.

**A. Notes Facilitator (`source: facilitator`)**

Facilitator stores its notes as a `.loop` file in the `Meetings` OneDrive folder of the person who turned it on.

1. If you organized the meeting or may have started Facilitator, list your own folder: `fetch` `/me/drive/root:/Meetings:/children?$select=name,webUrl,createdDateTime,lastModifiedDateTime&$top=100` and pick the `.loop` file whose name matches the meeting subject and whose date matches the meeting date.
2. Otherwise, search files shared with you: `call_function` `/me/drive/root/search(q='{subject}')?$select=name,webUrl,lastModifiedDateTime` and keep only `.loop` results dated the same day.
3. If you found a `.loop` file, call `ask` with `fileUrls: ["{webUrl}"]`, `timeZone` set to `fuseau_horaire`, and this question:
   > « Reproduis intégralement et fidèlement les notes de réunion de ce fichier Loop : ordre du jour, points discutés, décisions, actions avec responsables et échéances, questions ouvertes. N'ajoute rien, ne résume pas davantage. Réponds en français. »
4. If no file was found, call `retrieve` restricted to the **Meetings** source with the query `« Notes de la réunion {subject} du {date} »`. Accept the result only if it clearly refers to this meeting (same title and date).

**B. Transcription Teams (`source: transcription`)**

Only if A returned nothing.

1. `fetch` `/me/onlineMeetings?$filter=JoinWebUrl eq '{onlineMeeting.joinUrl}'` to get the online meeting `id`.
2. `fetch` `/me/onlineMeetings/{id}/transcripts`.
3. `fetch_blob` `/me/onlineMeetings/{id}/transcripts/{transcriptId}/content?$format=text/vtt`, then base64-decode `base64Content`.
4. Build the note yourself from the transcript. Attribute statements to speakers only as the transcript labels them.

A `403` or `404` here is normal (for example, when you weren't the organizer or no transcript exists). Move on and don't retry.

**C. Rien trouvé (`source: aucune`)**

Create the meeting note with metadata only (title, date, participants) and this line under **Résumé**:
`> Notes non disponibles. Relancer /traiter-reunions plus tard, ou coller les notes avec /note-reunion.`

If any tool returns an error with a retry delay (throttling), wait as instructed or skip the meeting. Never loop on retries.

## 3. Écrire la note de réunion

- Path: `reunions/{AAAA}/{MM}/{AAAA-MM-JJ}-{titre-court-kebab}.md`, built from [templates/reunion.md](../../templates/reunion.md).
- Fill the frontmatter: `titre`, `date`, `heure`, `duree_min`, `organisateur`, `participants` (as wikilinks), `projets`, `source`, `id_evenement`, `lien_notes`, `statut: brouillon`.
- Write every section in French. Keep the source's substance and wording. Restructure it, but don't paraphrase decisions or commitments into something stronger or weaker.
- **Décisions:** only explicit decisions. **Actions:** one task line per action. Owner as a wikilink when the person is known, otherwise their name as written. Use `échéance : à confirmer` when no date was given.
- If the note already exists, update the generated sections and keep everything below `<!-- notes personnelles -->` untouched.

## 4. Mettre à jour personnes et projets

**Personnes.** For each participant with a real name (skip room accounts and distribution lists):
- Create `personnes/{prenom-nom}.md` from the template if it doesn't exist. Fill in `nom` and `courriel` from the calendar. Leave `titre` and `equipe` empty unless the notes state them.
- Add a line under **Réunions**: `- {date} · [[{note}]] · {une ligne de contexte}`. Update `derniere_reunion`.
- Add their open actions from this meeting under **Actions en cours**.
- Never list the user from `moi.nom` as a separate person. Their actions go in the meeting note only.

**Projets.** Link a meeting to a project when its subject or notes match the project's `mots_cles` in `config/vault.yaml`, or an existing `projets/*.md` note. For each linked project:
- Append to **Historique**: `- {date} · [[{note}]] · ce qui a changé`.
- Append explicit decisions to **Décisions**.
- Rewrite **État actuel** only if the meeting clearly changed it, and update `mis_a_jour`.
- Don't create a new project note on your own. If a recurring topic doesn't match any project, suggest it to the user at the end.

## 5. Terminer

1. Write `state/dernier-traitement.md`:
   ```
   ---
   dernier_traitement: {ISO timestamp, end of processed range}
   ---
   ```
   Move the watermark forward only if every meeting in the range was processed or deliberately skipped.
2. Reply to the user in French, briefly:
   - meeting notes created / updated, with their source
   - meetings without notes (`source: aucune`)
   - person and project notes touched
   - new actions assigned to the user
   - suggested new projects, if any
