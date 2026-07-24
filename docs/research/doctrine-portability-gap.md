# Research — Portabilidad e instalación de la doctrina de Claude (máquina → máquina, y como artefacto de `executable-specs`)

Status: **DONE** — verdict: reframe. Steps 1–2 were committed before opening any source file.
**Follow-up shipped 2026-07-24:** the Capa 2 artifact now exists — `starters/global-standing-rules.md`
(genericized public snapshot of the 5 rules), documented in the README with the `@import`
install, and registered in `PROPAGATION.md`. Remaining: the rule-4/5 rationale wording is
gated on `agent-integrity-lab` TASK-B2 (handoff-cost WHY); memory + `.claude.json` stay out
of scope.
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

Encuadre útil: la "doctrina + config" se parte en **4 capas** y cada una tiene un
estado de portabilidad distinto. Los claims van por capa.

### Capa 1 — Skills (`~/.claude/skills/*`)

```
CLAIM:    Las skills ya se propagan máquina→máquina vía un plugin marketplace de
          Claude Code; NO requieren copiar archivos a mano. El .ps1 NO es el install
          path — es un mirror author-side.
EVIDENCE: sync-skills-to-claude.ps1:3-5 — "THIS IS NOT THE INSTALL PATH. To use these
          skills, install the plugin: /plugin marketplace add MattRosset/executable-specs
          ; /plugin install executable-specs". PROPAGATION.md:11 confirma el mismo
          camino. .claude-plugin/marketplace.json y plugin.json (v0.2.0) existen y
          declaran el plugin con source "./".
VERIFIED: 2026-07-24
RECHECK:  head -6 executable-specs/sync-skills-to-claude.ps1 ; cat
          executable-specs/.claude-plugin/marketplace.json
```

```
CLAIM:    El plugin es realmente instalable desde otra máquina: el repo está pusheado
          a GitHub (origin/main alcanzable) bajo MattRosset/executable-specs.
EVIDENCE: `git log origin/main --oneline -1` → f6004e0 ; `git ls-remote origin`
          resuelve refs/heads/main → f6004e06... (remote alcanzable). local ahead 1
          = solo este doc de research.
VERIFIED: 2026-07-24
RECHECK:  cd executable-specs && git ls-remote origin -h refs/heads/main
```

### Capa 2 — Reglas GLOBALES (`~/.claude/CLAUDE.md`, las 5 reglas anti-reward-hacking)

```
CLAIM:    Las reglas globales verbatim (Stop-at-contradictions / recall-is-a-hypothesis
          / objective-over-proxy / truth-over-approval / red-flags) NO existen como
          artefacto instalable dentro de executable-specs. El repo solo las *cita/estudia*
          en prosa (doctrine) y las instancia point-of-use (SPEC-TEMPLATE, CLAUDE-starter),
          pero no hay un archivo que se instale como el ~/.claude/CLAUDE.md global.
EVIDENCE: grep de la frase distintiva "improvise around" → aparece en doctrine/
          BUILD-FOR-AGENTS.md:209 (prosa doctrinal), SPEC-TEMPLATE.md:19, starters/
          CLAUDE-starter.md:50, examples/… — todas instancias point-of-use, ninguna
          es el set global de 5 reglas como archivo global. BUILD-FOR-AGENTS.md:223
          habla de "my verbatim global standing rules" como objeto de estudio (EVALS),
          no como archivo entregable. PROPAGATION.md ni siquiera lista ~/.claude/CLAUDE.md
          como artefacto propagado: su tabla cubre Doctrine, Skills, Templates, Learnings
          — no las standing rules globales.
VERIFIED: 2026-07-24
RECHECK:  grep -rln "standing rules" executable-specs --include=*.md ; grep -c
          "Objective over proxy" executable-specs/**/*.md  (el set de 5 no está)
```

```
CLAIM:    Un plugin de Claude Code NO instala ni sincroniza el ~/.claude/CLAUDE.md
          global del usuario (provee skills/commands/agents/hooks/MCP, no el memory
          file global). El ~/.claude/CLAUDE.md actual del usuario no está marcado como
          generado/synced por ninguna herramienta.
EVIDENCE: plugin.json no tiene ningún campo para un CLAUDE.md/memory global.
          PROPAGATION.md trata las standing rules globales como original SEPARADO ("my
          private playbook repo" / "my global standing rules"), no como algo que el
          plugin propague. — Segunda mitad (qué instala un plugin nativamente) NO
          verificada contra la doc oficial; ver Beliefs.
VERIFIED: 2026-07-24 (parcial)
RECHECK:  cat executable-specs/.claude-plugin/plugin.json ; + consultar doc oficial
          de plugins (claude-code-guide)
```

### Capa 3 — Memoria (`~/.claude/projects/<slug>/memory/`)

```
CLAIM:    La memoria está atada a la ruta absoluta del proyecto vía el slug de la
          carpeta, por lo que NO es portable máquina→máquina sin renombrar: el mismo
          proyecto en la Mac genera un slug distinto y Claude no encuentra la memoria
          de Windows.
EVIDENCE: la carpeta es ~/.claude/projects/C--dev-Projects-cosmos/memory ; la ruta
          real del proyecto es C:\dev\Projects\cosmos → el slug es la ruta con
          separadores convertidos a "-". En Mac /Users/<u>/dev/Projects/cosmos
          codificaría como -Users-<u>-dev-Projects-cosmos (slug distinto).
VERIFIED: 2026-07-24
RECHECK:  ls ~/.claude/projects/  (el nombre de carpeta = ruta del proyecto slugificada)
```

```
CLAIM:    La memoria NO es un artefacto que executable-specs propague ni pretenda
          propagar: no aparece en la tabla de PROPAGATION.md.
EVIDENCE: PROPAGATION.md tabla (líneas 7-13) cubre Doctrine / Skills / Templates /
          Learnings; "memory" no figura.
VERIFIED: 2026-07-24
RECHECK:  grep -in "memory" executable-specs/PROPAGATION.md  (sin match)
```

### Capa 4 — Config de máquina (`~/.claude.json`)

```
CLAIM:    ~/.claude.json es config machine-specific (rutas absolutas Windows, MCP
          servers, estado de sesión) — copiarlo entero a la Mac es lo que rompería el
          arranque, no lo que lo salva.
EVIDENCE: ~/.claude.json pesa 39K y contiene entradas con prefijo "C:\\" (grep -c
          '"C:\\\\' → ≥1) y config de mcpServers. Es estado por-instalación.
VERIFIED: 2026-07-24
RECHECK:  grep -c '"C:\\\\' ~/.claude.json
```

## Belief RESUELTO → claim (via claude-code-guide sobre docs oficiales, 2026-07-24)

```
CLAIM:    Un plugin de Claude Code NO puede escribir/mergear el ~/.claude/CLAUDE.md
          global — un CLAUDE.md en la raíz del plugin no se carga. Los plugins aportan
          skills/agents/hooks/MCP (+ settings solo con keys agent/subagentStatusLine).
          NO existe sync nativo del CLAUDE.md/memoria global entre máquinas (la memoria
          es machine-local por diseño). PERO CLAUDE.md soporta `@path` import (rutas
          relativas y absolutas), así que un archivo de reglas versionado en el repo se
          carga con una sola línea @import por máquina.
EVIDENCE: claude-code-guide citando code.claude.com/docs/en/plugins-reference.md
          ("A CLAUDE.md file at the plugin root is not loaded as project context…
          put them in a skill"), memory.md ("Files are not shared across machines"),
          y memory.md (sintaxis @path de import en CLAUDE.md).
VERIFIED: 2026-07-24 (reportado de docs; recheck trivial abajo)
RECHECK:  poner una línea `@~/.claude/standing-rules.md` en un CLAUDE.md y confirmar
          que el contenido importado carga en contexto; + revisar
          code.claude.com/docs/en/plugins-reference.md y /memory.md
```

**Decisión de diseño de la Capa 2 (desbloqueada por el claim):** las 5 reglas globales
NO van dentro del plugin como CLAUDE.md (no cargaría). Van como archivo versionado en el
repo (`starters/global-standing-rules.md`) + **una línea `@import`** que el usuario
agrega una vez por máquina a su `~/.claude/CLAUDE.md`. Fuente única versionada; `git pull`
propaga cambios. Supera a la copia manual (que se desincroniza).
- **`/plugin marketplace add MattRosset/executable-specs` funciona desde la Mac.**
  El repo está pusheado y el remote resuelve, pero la instalación por marketplace
  típicamente requiere repo **público**; no confirmé visibilidad pública vía API.
  RECHECK: correr el propio comando en la Mac, o `gh repo view MattRosset/executable-specs --json visibility`.

## Step 4/5 — Lo que busqué y NO encontré

- **No hay** un archivo en executable-specs que sea el set global de 5 reglas listo
  para instalar como `~/.claude/CLAUDE.md`. Busqué: `grep -rn "improvise around"` y
  `grep -rln "standing rules"` → solo instancias point-of-use y prosa doctrinal, nunca
  el archivo global. (Este es EL hallazgo: la capa "push global" es justo la que falta.)
- **No hay** ninguna mención de "memory" en PROPAGATION.md → la memoria nunca fue
  pensada como asset propagable. Confirmada su ausencia, no inferida.
- **No hay** un install script cross-plataforma: `sync-skills-to-claude.ps1` es
  PowerShell (author-side) y no corre en la Mac; el install real es el plugin, así que
  esto no bloquea la Mac — pero tampoco cubre la Capa 2.
- **No encontré** ningún `settings.json` global ni `.claude/settings.json` de usuario
  (find sobre ~/.claude no devolvió settings*.json) → no hay hoy una capa de settings
  que sincronizar; el gap es doctrina, no settings.

## Step 6 — Verdict: **REFRAME**

La premisa entrante — *"no tenemos manera de transferir la doctrina ni la config sin
empezar de 0"* — es **falsa para las skills y verdadera solo para una capa angosta**.
Desglose:

- **Capa 1 (skills): ya resuelta.** Dos comandos en la Mac
  (`/plugin marketplace add MattRosset/executable-specs` + `/plugin install
  executable-specs`) traen las 6 skills. No hay que construir nada. (Claims Capa 1.)
- **Capa 3 (memoria): no es un gap del producto, es per-máquina por diseño.** El slug
  ata la carpeta a la ruta; a lo sumo es un export/import manual con renombrado, fuera
  del alcance de executable-specs. La sub-idea "sincronizar la memoria" queda **matada**
  como feature de producto. (Claims Capa 3.)
- **Capa 4 (`~/.claude.json`): no copiar.** Es lo que arruinaría la Mac. (Claim Capa 4.)

**El gap real, único y accionable es la Capa 2:** las **reglas globales**
(`~/.claude/CLAUDE.md`, las 5 anti-reward-hacking) no tienen artefacto público ni
install path en executable-specs — viven solo en el playbook privado y en la máquina
del usuario. Es exactamente "la doctrina que quiero transferir a Claude" en sentido
fuerte, y es la capa *push* (en contexto cada sesión, la de mayor efecto medido según
EVALS/CLAUDE-starter). Hoy no cruza a otra máquina por ningún canal.

**Qué levantaría un spec-writer como Step 0 (claims que sostienen el trabajo):**
1. Las skills ya cruzan vía plugin → el spec NO debe re-resolverlas (Claim Capa 1).
2. La Capa 2 es el único faltante; existe `starters/CLAUDE-starter.md` como precedente
   de "regla lista para copiar", pero es **per-repo**, no el set **global** de 5 reglas.
   El spec debe decidir: ¿publicar las 5 reglas globales como
   `starters/GLOBAL-RULES-starter.md` (copia manual a `~/.claude/CLAUDE.md`), o
   empaquetarlas en el plugin si el canal nativo lo permite (Belief a verificar)?
3. La memoria y `.claude.json` quedan **fuera de alcance** explícito (Claims Capa 3/4).

Antes de spec: cerrar el Belief "¿un plugin puede entregar un archivo a
`~/.claude/CLAUDE.md`?" con claude-code-guide — decide entre "starter de copia manual"
vs "capa del plugin".
