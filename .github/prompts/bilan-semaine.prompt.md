---
name: bilan-semaine
description: Rédige le bilan hebdomadaire (décisions, avancement par projet, actions) à partir des notes de réunion de la semaine.
argument-hint: "[AAAA-Sxx | AAAA-MM-JJ]  (vide = semaine en cours)"
agent: agent
---

# Bilan de la semaine

Follow [AGENTS.md](../../AGENTS.md).

1. Pick the week: the ISO week the user gave, the week containing the date they gave, or the current week (Monday to Sunday, in `fuseau_horaire`).
2. Read every note in `reunions/` dated in that week, plus the project notes they link to.
3. Write `bilans/{AAAA}-S{xx}.md` from [templates/bilan.md](../../templates/bilan.md), in French:
   - **En bref:** 3 to 5 bullets, the facts that matter most. No filler.
   - **Par projet:** one short paragraph per project that had activity, with links to the meetings.
   - **Décisions de la semaine:** copied faithfully from the meeting notes, each with its link.
   - **Actions ouvertes:** split into the user's own (`moi.nom`) and other people's.
   - **À préparer:** upcoming due dates and open questions that need follow-up.
4. Only use what's in the notes. If a week has no meetings, say so and don't create the file.
5. If the file already exists, regenerate the sections and keep everything below `<!-- notes personnelles -->`.
6. Reply with the file path and the **En bref** section.
