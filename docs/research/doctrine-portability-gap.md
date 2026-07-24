# Research — Portabilidad e instalación de la doctrina de Claude (máquina → máquina, y como artefacto de `executable-specs`)

Status: **IN PROGRESS** — Steps 1–2 committed before opening any source file.
Started: 2026-07-24

## Contexto / disparador

El usuario empezó a usar Claude Code en una Mac (venía de Windows) y notó que no
tiene forma de **transferir la doctrina** (reglas globales + skills + memoria) ni
esta config de `~/.claude` a otra máquina sin empezar de cero. Premisa entrante,
textual: *"no tenemos manera de transferir la doctrina a Claude ni de transferir
esta config sin empezar de 0 — ahí tenemos un gap."*

Observación cruda ya hecha (solo `ls`, sin abrir contenido): `executable-specs/`
contiene `.claude-plugin/`, `sync-skills-to-claude.ps1`, `PROPAGATION.md`,
`doctrine/`, `skills/`, `starters/`, `templates/`. Eso ya pone en duda la premisa.

## Step 1 — Preguntas falsables

**Q1.** ¿`executable-specs` ya provee un mecanismo de instalación/propagación de la
doctrina a un Claude nuevo (plugin manifest + script de sync), o realmente no existe
ninguno?

**Q2.** Si existe, ¿qué capas cubre? Las tres candidatas son: (a) reglas globales
(`~/.claude/CLAUDE.md`), (b) skills (`~/.claude/skills/`), (c) memoria
(`~/.claude/projects/<slug>/memory/`). ¿Cubre las tres, o solo un subconjunto?

**Q3.** ¿La **memoria** es transferible entre máquinas, dado que la carpeta se
nombra con un slug derivado de la ruta absoluta del proyecto
(`C--dev-Projects-cosmos` ← `C:\dev\Projects\cosmos`)? ¿O el slug la ata a la ruta
y por lo tanto la memoria NO es un asset que un plugin cross-máquina deba propagar?

**Q4.** ¿Qué mecanismo nativo de Claude Code aplica realmente aquí — plugin,
marketplace, settings sync — y cuál de las tres capas puede transportar cada uno?
(No responder de memoria: verificar contra el manifest real del plugin y la doc.)

## Step 2 — Condiciones de kill / reframe (escritas ANTES de investigar)

- **Q1 mata la premisa entrante si:** el plugin + `sync-skills-to-claude.ps1` ya
  instalan al menos las skills en un Claude nuevo. Entonces "no hay mecanismo" es
  **FALSO**, y el research se **reframe** de "construir el mecanismo" a "¿qué le
  falta al mecanismo que ya existe?".

- **Q2 redirige el trabajo si:** el mecanismo cubre solo skills (y no reglas
  globales ni memoria). Entonces el gap real y accionable es **propagar
  `~/.claude/CLAUDE.md` (reglas globales)** — no las skills, que ya estarían
  resueltas.

- **Q3 mata la sub-idea "sincronizar la memoria" si:** el slug ata la carpeta a la
  ruta absoluta y no hay override. Entonces la memoria es **per-máquina/per-ruta por
  diseño**, no un asset propagable por un plugin genérico; a lo sumo es un
  "export/import" manual con renombrado, fuera del alcance del producto.

- **Q4 reframe si:** un mecanismo nativo (p.ej. plugin marketplace o settings)
  ya transporta una capa que hoy el script `.ps1` copia a mano — en ese caso el
  gap no es "construir sync" sino "adoptar el mecanismo nativo correcto",
  y además el `.ps1` (PowerShell) sería no-portable a la Mac por sí mismo.

Kill / reframe / enable se deciden con la evidencia de Steps 3–5.

## Step 3 — Findings (claims)

_(pendiente — se completa tras commitear este archivo)_

## Step 4/5 — Lo que busqué y NO encontré

_(pendiente)_

## Step 6 — Verdict

_(pendiente)_
