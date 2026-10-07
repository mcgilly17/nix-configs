---
name: One By One
description: Walk a list of findings, decisions or TODOs one item at a time, each with plain-English context, a diagram, and an AskUserQuestion
---

# One By One

Michael just got a wall of prose: a list of findings, open questions, review
comments, TODOs, decisions to make. It is unreadable as a block and undecidable
as a block. Break it into one item at a time and get a ruling on each.

## The list

The list is whatever was produced immediately before `/obo` was typed: the
previous message, the report, the draft, the file just written. Do not ask which
list unless there genuinely is no list in view, and do not re-derive it or go
looking for more items. If an argument was passed to `/obo`, that names the list
or the subset to walk.

Split it so each segment is **one thing Michael can decide in one answer**. Two
decisions in one segment is the failure this exists to prevent. A finding that
is purely informational and needs no input is not a segment: fold it into the
closest one as context, or drop it.

## First message: the index

Before any questions, a numbered one-line-each index of the segments, so he
knows the shape and how many are coming. Titles only, no detail. Nothing else
in that message.

## Then, per segment, in its own message

1. **Context, plain English.** What the thing is, what is wrong or undecided,
   and what it costs either way. No jargon, no type names, no file paths, no
   code. Write it for someone who has never opened the repo. A few sentences,
   not paragraphs.
2. **A diagram.** ASCII box-and-arrow, rendered in a fenced block. It shows the
   mechanism: what flows where, where the thing being decided sits, what
   changes between the options. Mermaid does not render in a terminal, so do not
   use it. Skip the diagram only when the segment has no structure to draw, and
   then say nothing about skipping it.
3. **An AskUserQuestion call.** Real options with real trade-offs, the
   recommended one first and labelled so, each description saying what it rules
   out. Never a question whose answer is already obvious from the context.

```
     context          diagram              question
   ┌──────────┐    ┌────────────┐    ┌──────────────────┐
   │ what and │ -> │  where it  │ -> │ A (recommended)  │
   │ what it  │    │  sits, and │    │ B                │
   │  costs   │    │ what moves │    │ C                │
   └──────────┘    └────────────┘    └──────────────────┘
                                              │
                                              v
                                        ruling recorded,
                                        next segment
```

## Rules

- One segment per message. Never batch two segments into one AskUserQuestion
  call, even when they look related.
- Stop at each question and wait. Do not run ahead, do not pre-answer, do not
  guess what he will pick and carry on.
- An answer can change later segments. Re-split what is left when it does, and
  say so in one line.
- `/obo` decides. It does not build. No edits, no commands, no Linear writes
  while walking the list, however obvious the fix looks.
- At the end: one consolidated list of what was ruled, one line each, ready to
  act on. Then stop and wait for go-ahead.
