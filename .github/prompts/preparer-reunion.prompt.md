---
name: preparer-reunion
description: Prépare une réunion à venir à partir de l'historique du coffre (participants, projets, actions ouvertes, questions en suspens).
argument-hint: "[titre de la réunion | prochaine | demain]"
agent: agent
---

# Préparer une réunion

Follow [AGENTS.md](../../AGENTS.md). This prompt is **read-only** for the vault and Microsoft 365. It answers in chat and writes no file.

1. **Find the meeting.** If the `workiq` server is available, use `call_function` on `/me/calendarView` (today and the next 7 days) to find the event that matches what the user typed (`prochaine` = the next online meeting). Otherwise, ask for the title and participants.
2. **Gather history from the vault:**
   - the person notes of the participants (context, open actions)
   - the last 3 meeting notes that share participants or a project with this meeting
   - the linked project notes (État actuel, Risques et questions ouvertes)
3. **Reply in French**, in under 20 lines:
   - **Contexte:** where things stand, in 2 or 3 sentences
   - **Actions ouvertes** tied to these participants or projects, flagging the ones that are overdue
   - **Questions en suspens** from earlier meetings
   - **Points à soulever:** 3 to 5 suggested agenda items, each grounded in a link to a note
4. Cite the source note for every claim (`[[note]]`). If the vault has no history on this topic, say so plainly.
