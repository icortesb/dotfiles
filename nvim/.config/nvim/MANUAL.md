# Manual de Neovim

> **Leader = `Espacio`.** En este manual, `Esp` significa la barra espaciadora.
> ¿Perdido? Apretá `Esp` y esperá: which-key muestra todo lo que sigue.
> ¿Buscás un atajo? `Esp sk` abre un buscador de **todos** los atajos con su descripción.
> Base: LazyVim. Todo lo marcado 🆕 se agregó en septiembre 2026.

---

## Índice

0. [Modos](#0-modos)
1. [Buffers, ventanas y tabs](#1-buffers-ventanas-y-tabs)
2. [Moverse y encontrar archivos](#2-moverse-y-encontrar-archivos)
3. [Editar texto](#3-editar-texto)
4. [Código: LSP, formateo y completado](#4-código-lsp-formateo-y-completado)
5. [🆕 Tests](#5--tests-neotest)
6. [🆕 Debugger](#6--debugger-dap)
7. [Bases de datos](#7-bases-de-datos-vim-dadbod)
8. [Git y GitHub](#8-git-y-github)
9. [Buscar y reemplazar](#9-buscar-y-reemplazar)
10. [Diagnósticos, TODOs y Trouble](#10-diagnósticos-todos-y-trouble)
11. [Terminal](#11-terminal)
12. [Interruptores (Esp u)](#12-interruptores-esp-u)
13. [Sesiones y salir](#13-sesiones-y-salir)
14. [Archivos de root (sudo)](#14-archivos-de-root-sudo)
15. [Configuración por proyecto](#15-configuración-por-proyecto-lazylua)
16. [Mantenimiento](#16-mantenimiento)
17. [Chuleta diaria](#chuleta-diaria)

---

## 0. Modos

Neovim es modal: siempre estás en uno de estos modos.

| Modo | Cómo entrar | Para qué |
|------|-------------|----------|
| **Normal** | `Esc` | Moverte y ejecutar acciones. Es el modo base. |
| **Insert** | `i` (antes del cursor), `a` (después), `o` (línea nueva abajo), `O` (arriba) | Escribir |
| **Visual** | `v` (caracteres), `V` (líneas), `Ctrl+v` (bloque) | Seleccionar |
| **Comando** | `:` | Comandos de Vim (`:w`, `:q`, `:wq`, `:q!`) |

**Regla:** siempre volvés a Normal con `Esc`. Todo lo demás arranca desde Normal.

Atajos básicos que conviene saber:

| Tecla | Acción |
|-------|--------|
| `Ctrl+s` | Guardar (funciona en Normal, Insert y Visual) |
| `Alt+j` / `Alt+k` | Mover la línea (o la selección) abajo / arriba |
| `Esc` | También limpia el resaltado de la última búsqueda |
| `:q` | Cerrar la ventana (si es la última, sale de nvim) |
| `:wq` / `:q!` | Guardar y salir / salir sin guardar |

---

## 1. Buffers, ventanas y tabs

**Lo más importante de entender:**
- **Buffer** = un archivo abierto en memoria. Lo que ves arriba como "pestañas" (bufferline) son buffers.
- **Ventana** = un panel en pantalla que muestra un buffer. Podés tener varias lado a lado.
- **Tab** = un layout completo de ventanas. Casi nunca hace falta.

### Cambiar de buffer
| Tecla | Acción |
|-------|--------|
| `Shift+h` / `Shift+l` | Buffer anterior / siguiente (izquierda / derecha en la barra) |
| `[b` / `]b` | Lo mismo |
| `Esp ,` o `Esp fb` | Buscar entre los buffers abiertos por nombre |
| `Esp bb` o `` Esp ` `` | Volver al buffer anterior (alterna entre los dos últimos) |
| `Esp bj` | "Pick": aparece una letra sobre cada pestaña y apretás la que querés |
| `[B` / `]B` | Mover la pestaña actual a la izquierda / derecha en la barra |

### Cerrar buffers
| Tecla | Acción |
|-------|--------|
| `Esp bd` | Cerrar el buffer actual (no toca las ventanas) |
| `Esp bw` | Guardar y cerrar el buffer actual |
| `Esp bo` | Cerrar todos los **otros** buffers |
| `Esp bl` / `Esp br` | Cerrar todos los de la izquierda / derecha |
| `Esp bp` | Fijar (pin) el buffer actual |
| `Esp bP` | Cerrar todos los buffers no fijados |
| `Esp bD` | Cerrar el buffer **y** su ventana |

Cerrar un buffer no rompe el layout: la ventana pasa a mostrar otro buffer.

### Ventanas (splits)
| Tecla | Acción |
|-------|--------|
| `Esp \|` | Dividir en vertical (panel nuevo a la derecha) |
| `Esp -` | Dividir en horizontal (panel nuevo abajo) |
| `Esp wd` | Cerrar la ventana actual (el buffer sigue abierto) |
| `Esp wm` o `Esp uZ` | Zoom: maximizar o restaurar la ventana actual |
| `Ctrl+h/j/k/l` | Moverte a la ventana de la izquierda / abajo / arriba / derecha (también entre paneles de tmux) |
| `Alt+h/j/k/l` | Redimensionar la ventana |
| `Esp w` + espera | El resto de los comandos de ventana (`Esp w` equivale a `Ctrl+w`) |

**Flujo para ver dos archivos lado a lado:** abrí el primero, `Esp |`, y en el panel nuevo `Esp ff` para abrir el segundo. Pasás de uno a otro con `Ctrl+h` / `Ctrl+l`.

### Tabs (layouts)
| Tecla | Acción |
|-------|--------|
| `Esp Tab Tab` | Tab nueva |
| `Esp Tab ]` / `Esp Tab [` | Tab siguiente / anterior |
| `Esp Tab d` | Cerrar tab |
| `Esp Tab o` | Cerrar las otras tabs |

---

## 2. Moverse y encontrar archivos

### Flash: saltar a cualquier lugar visible
| Tecla | Acción |
|-------|--------|
| `s` | Escribís 1-2 letras de donde querés ir, aparecen etiquetas y apretás la de tu destino |
| `S` | Seleccionar un nodo de código (función, bloque, tag…) con etiquetas |
| `r` (después de `d`, `y` o `c`) | "Remote": operar sobre un lugar lejano sin mover el cursor. Ej: `yr` + salto + `iw` copia una palabra de otra parte y te deja donde estabas |

Ejemplo: ves `backgroundColor` en la línea 40. Apretás `s`, escribís `ba`, aparece una etiqueta (ej. `j`) y la apretás. Listo.

### Harpoon: tus 3-4 archivos de trabajo
Marcás los archivos con los que estás trabajando y saltás entre ellos sin buscar.

| Tecla | Acción |
|-------|--------|
| `Esp a` | Marcar el archivo actual |
| `Ctrl+e` | Menú de marcas: es un buffer editable, podés reordenar líneas o borrarlas con `dd`, y `Enter` abre |
| `Ctrl+n` / `Ctrl+p` | Siguiente / anterior archivo marcado |
| `Esp fl` | Ver las marcas en el picker, con vista previa |

Las marcas se guardan **por proyecto** (según la carpeta donde abriste nvim).
**Flujo:** abrís el componente, su CSS y su test, y marcás cada uno con `Esp a`. Después `Ctrl+n` / `Ctrl+p` los recorre al instante.

### Buscar archivos
| Tecla | Acción |
|-------|--------|
| `Esp Esp` o `Esp ff` | Buscar archivo por nombre (desde la raíz del proyecto) |
| `Esp fF` | Igual, pero desde la carpeta actual (cwd) |
| `Esp fr` | Archivos recientes |
| `Esp fp` | Cambiar de proyecto (proyectos recientes) |
| `Esp fc` | Buscar entre los archivos de configuración de nvim |
| `Esp fn` | Archivo nuevo |

### Cómo se usa cualquier picker
Todos los buscadores (archivos, grep, buffers…) funcionan igual:

| Tecla | Acción |
|-------|--------|
| escribir | Filtra con búsqueda difusa (fuzzy) |
| `Ctrl+j` / `Ctrl+k` (o flechas) | Bajar / subir en la lista |
| `Enter` | Abrir |
| `Ctrl+v` / `Ctrl+s` | Abrir en split vertical / horizontal |
| `Ctrl+t` | Abrir en una tab nueva |
| `Tab` | Marcar varios resultados (después `Enter` los abre todos) |
| `Ctrl+q` | Mandar los resultados a la lista quickfix |
| `Alt+h` / `Alt+i` | Mostrar u ocultar archivos ocultos / ignorados por git |
| `Alt+p` | Mostrar u ocultar la vista previa |
| `Ctrl+f` / `Ctrl+b` | Scroll de la vista previa |
| `Esc` | Cerrar |

### Explorador de archivos (Snacks)
| Tecla | Acción |
|-------|--------|
| `Esp e` | Abrir / cerrar el explorador (raíz del proyecto) |
| `Esp E` | Abrir / cerrar el explorador (carpeta actual) |

Dentro del explorador:

| Tecla | Acción |
|-------|--------|
| `j` / `k` | Bajar / subir |
| `l` o `Enter` | Abrir archivo / expandir carpeta |
| `h` | Colapsar carpeta |
| `Backspace` | Subir a la carpeta padre |
| `a` | Crear archivo (terminá el nombre en `/` para crear una carpeta) |
| `r` | Renombrar |
| `d` | Borrar |
| `c` | Copiar (pregunta el nombre nuevo) |
| `m` | Mover |
| `y` / `p` | Copiar al portapapeles del explorador / pegar |
| `o` | Abrir con la aplicación del sistema |
| `H` / `I` | Mostrar u ocultar archivos ocultos / ignorados |
| `Z` | Colapsar todo |
| `]g` / `[g` | Siguiente / anterior archivo con cambios de git |
| `]d` / `[d` | Siguiente / anterior archivo con errores |
| escribir | Filtra el árbol |
| `?` | Ver todos los atajos |

---

## 3. Editar texto

### Text objects: qué seleccionar, borrar o cambiar
Se combinan con `v` (seleccionar), `d` (borrar), `c` (cambiar), `y` (copiar). `i` = *inside* (adentro) y `a` = *around* (incluyendo bordes).

| Objeto | Qué agarra |
|--------|------------|
| `if` / `af` | **Función** (el cuerpo / la función completa) |
| `ic` / `ac` | **Clase** |
| `ia` / `aa` | **Argumento** de una función |
| `iq` / `aq` | Contenido entre **comillas** (cualquier tipo) |
| `ib` / `ab` | Contenido entre **paréntesis/corchetes/llaves** |
| `it` / `at` | **Tag HTML** |
| `io` / `ao` | **Bloque** (if, loop, bloque de código) |
| `iu` / `au` | **Llamada a función** ("usage") |
| `ie` / `ae` | Parte de una palabra camelCase o snake_case |
| `id` | Número |
| `ig` | **Todo** el archivo |

Ejemplos:
- `daf`: borra la función entera.
- `ciq`: cambia el texto entre comillas, sin importar si son `'`, `"` o `` ` ``.
- `vat`: selecciona el tag HTML con su contenido.
- `cia`: cambia un argumento.
- `yig`: copia todo el archivo.
- `ci(` / `ci{` / `ci"`: también funcionan los clásicos de Vim.

Agregando `n` o `l` apuntás al objeto **siguiente** o **anterior**: `cinq` cambia lo que hay entre las próximas comillas aunque el cursor no esté adentro.

### Moverse por estructura de código
| Tecla | Acción |
|-------|--------|
| `]f` / `[f` | Inicio de la función siguiente / anterior (`]F` / `[F` = final) |
| `]c` / `[c` | Clase siguiente / anterior |
| `]a` / `[a` | Argumento siguiente / anterior |
| `Ctrl+Espacio` | Selección incremental: cada vez que lo apretás agranda la selección al nodo de código padre |

### 🆕 Surround: rodear texto con comillas, paréntesis o tags
Todo empieza con `gs` (la `s` sola es Flash).

| Tecla | Acción |
|-------|--------|
| `gsa` + objeto + carácter | **Agregar** alrededor |
| `gsd` + carácter | **Borrar** lo que rodea |
| `gsr` + viejo + nuevo | **Reemplazar** lo que rodea |
| `gsa` en visual + carácter | Rodear la selección |
| `gsh` + carácter | Resaltar lo que rodea (para ver qué agarraría) |
| `gsf` / `gsF` | Ir al siguiente / anterior carácter que rodea |

Ejemplos con el cursor sobre `hola`:
- `gsaiw"` → `"hola"` (agregar comillas a la palabra)
- `gsaiw)` → `(hola)` · con `(` en vez de `)` agrega espacios: `( hola )`
- `gsr"'` sobre `"hola"` → `'hola'` (cambiar comillas dobles por simples)
- `gsd"` sobre `"hola"` → `hola` (quitar comillas)
- `gsaiwt` y después escribís `div` → `<div>hola</div>` (rodear con un tag)
- `gsrtt` sobre `<div>hola</div>` y escribís `span` → `<span>hola</span>`
- `gsdf` sobre `console.log(x)` → `x` (quitar la llamada a función)
- En visual: seleccionás varias líneas, `gsa{` → las envuelve en llaves

### 🆕 Dial: Ctrl+a / Ctrl+x con esteroides
Nvim ya sumaba y restaba números con `Ctrl+a` / `Ctrl+x`. Dial lo extiende a muchas más cosas. Ponés el cursor sobre el valor (o antes, en la misma línea) y apretás:

| Tecla | Acción |
|-------|--------|
| `Ctrl+a` | Incrementar / pasar al siguiente valor |
| `Ctrl+x` | Decrementar / pasar al valor anterior |
| `g Ctrl+a` en visual | Incremento progresivo: en varias líneas con `0` quedan `1, 2, 3…` |

Qué alterna:
- **Números:** `9` → `10`, negativos, hexadecimales `0x1f`
- **Booleanos:** `true` ↔ `false`, `True` ↔ `False`
- **Lógicos:** `&&` ↔ `||` (en Lua y Python: `and` ↔ `or`)
- **JS/TS:** `let` ↔ `const`
- **Fechas:** `2026/09/10` (sobre el día, el mes o el año)
- **Días y meses:** `Monday` → `Tuesday`, `January` → `February`
- **Ordinales:** `first` → `second`
- **Colores hex (CSS):** `#ff0000` sobre cada componente
- **Markdown:** `[ ]` ↔ `[x]` y niveles de título `#` → `##`
- **JSON:** versiones semver `1.2.3`

Ejemplo: cursor en `const x = true`, apretás `Ctrl+a` sobre `const` y queda `let`; sobre `true` queda `false`.

### Comentar
| Tecla | Acción |
|-------|--------|
| `gcc` | Comentar / descomentar la línea |
| `gc` + movimiento | Comentar un bloque (`gcip` = el párrafo, `gcaf` = la función) |
| `gc` en visual | Comentar la selección |
| `gco` / `gcO` | Agregar un comentario en una línea nueva abajo / arriba |

### Autopares y tags
- Paréntesis, comillas y llaves se cierran solos. Si escribís el carácter de cierre, lo salta en vez de duplicarlo.
- `Esp up` desactiva o activa los autopares.
- Los tags HTML/JSX/Vue se cierran solos al escribir `>` y, si renombrás el de apertura, se renombra el de cierre.

### Emmet: abreviaturas de HTML/CSS
Escribís la abreviatura y aparece en el menú de completado como sugerencia de emmet; la aceptás con `Enter`. Funciona en HTML, CSS, JSX/TSX, Vue y Astro (no en `.php`).

| Abreviatura | Resultado |
|-------------|-----------|
| `div.container` | `<div class="container"></div>` |
| `ul>li*3` | `<ul>` con 3 `<li>` |
| `a[href=#]` | `<a href="#"></a>` |
| `p.title+span` | `<p class="title"></p><span></span>` |
| `section#hero>h1{Hola}` | `<section id="hero"><h1>Hola</h1></section>` |

### Yanky: historial de lo copiado
Todo lo que copiás (`y`) o borrás (`d`) queda en un historial.

| Tecla | Acción |
|-------|--------|
| `p` / `P` | Pegar después / antes (normal) |
| `[y` / `]y` | **Justo después de pegar**: reemplaza lo pegado por el item anterior / siguiente del historial |
| `Esp p` | Ver todo el historial en un picker y elegir qué pegar |
| `]p` / `[p` | Pegar en línea nueva abajo / arriba, con la indentación correcta |
| `>p` / `<p` | Pegar y aumentar / reducir la indentación |

**Flujo:** copiaste A, después B, después C, pero querías pegar A. Apretás `p` (pega C), después `[y` (cambia a B) y otra vez `[y` (cambia a A).

### Deshacer
| Tecla | Acción |
|-------|--------|
| `u` | Deshacer |
| `Ctrl+r` | Rehacer |
| `Esp U` | **Undotree**: árbol visual de todo el historial de cambios, incluidas las ramas que "perdiste" al deshacer y editar |
| `Esp su` | Lo mismo, pero en un picker con vista previa del diff |

En undotree: `j` / `k` recorren los estados, `Enter` vuelve el archivo a ese estado y `q` cierra. Sirve cuando deshiciste, editaste otra cosa y ya no podés volver con `Ctrl+r`.

### Scratch buffers
| Tecla | Acción |
|-------|--------|
| `Esp .` | Abrir / cerrar un buffer "borrador" para notas rápidas (se guarda solo) |
| `Esp S` | Elegir entre tus borradores |

---

## 4. Código: LSP, formateo y completado

LSP activo para: TypeScript/JavaScript (vtsls), Vue, Astro, **PHP (intelephense)**, Go (gopls), Python (pyright + ruff), Bash, Lua, Docker, JSON, YAML, TOML, SQL, Prisma, Markdown, Tailwind, Emmet y ESLint.

### Navegar
| Tecla | Acción |
|-------|--------|
| `gd` | Ir a la definición |
| `gr` | Ver todas las referencias |
| `gI` | Ir a la implementación |
| `gy` | Ir a la definición del tipo |
| `gD` | Ir a la definición en el código fuente (TS: salta el `.d.ts`) |
| `K` | Documentación / tipo de lo que está bajo el cursor |
| `gK` (normal) / `Ctrl+k` (insert) | Firma de la función (qué parámetros recibe) |
| `]]` / `[[` (o `Alt+n` / `Alt+p`) | Siguiente / anterior uso del símbolo en el archivo |
| `gai` / `gao` | Quién llama a esta función / a quién llama esta función |
| `Esp ss` | Símbolos del archivo (funciones, clases…) en un picker |
| `Esp sS` | Símbolos de todo el proyecto |
| `Ctrl+o` / `Ctrl+i` | Volver atrás / adelante después de un salto (por ejemplo, después de `gd`) |

### Acciones
| Tecla | Acción |
|-------|--------|
| `Esp ca` | Code actions: arreglos rápidos, imports, refactors |
| `Esp cr` | Renombrar el símbolo en todo el proyecto |
| `Esp cR` | Renombrar el **archivo** y actualizar los imports que lo usan |
| `Esp cd` | Ver el diagnóstico completo de la línea |
| `Esp cl` | Info de los LSP activos |
| `Esp cm` | Abrir Mason (instalador de LSPs y herramientas) |

Solo en TS/JS:

| Tecla | Acción |
|-------|--------|
| `Esp co` | Ordenar imports y borrar los que no se usan |
| `Esp cM` | Agregar los imports que faltan |
| `Esp cD` | Arreglar todos los diagnósticos que tengan arreglo automático |
| `Esp cV` | Elegir la versión de TypeScript (la del proyecto o la de nvim) |

### Formateo al guardar
Se formatea solo cada vez que guardás.

| Lenguaje | Formateador |
|----------|-------------|
| JS / TS / Vue / Astro / CSS / HTML / JSON / YAML / Markdown | 🆕 **Prettier** (usa el `.prettierrc` del proyecto si hay; si no, sus defaults) |
| JS / TS / Vue | 🆕 **ESLint**: además arregla lo que se puede arreglar automáticamente (en proyectos con config de ESLint) |
| PHP | php-cs-fixer |
| Go | goimports + gofumpt |
| Python | ruff |
| Lua | stylua |
| Shell | shfmt |

| Tecla | Acción |
|-------|--------|
| `Esp cf` | Formatear a mano (en visual: solo la selección) |
| `Esp uf` | Activar / desactivar el formateo al guardar (global) |
| `Esp uF` | Activar / desactivar el formateo al guardar (solo este buffer) |

> Si un proyecto no usa Prettier y no querés que te reformatee todo, desactivalo con `Esp uF` / `Esp uf`, o poné un `.prettierrc` con el estilo del proyecto.

🆕 **ESLint** además marca los errores de lint en el código (subrayados, igual que los errores de TS), solo en proyectos que tienen `eslint.config.*` o `.eslintrc*`.

### Completado (blink)
El menú aparece solo mientras escribís.

| Tecla | Acción |
|-------|--------|
| `Ctrl+n` / `Ctrl+p` (o flechas) | Bajar / subir en el menú |
| `Enter` | Aceptar la sugerencia seleccionada |
| `Ctrl+y` | Seleccionar y aceptar la primera |
| `Ctrl+e` | Cerrar el menú |
| `Ctrl+Espacio` | Abrir el menú a mano / mostrar la documentación |
| `Ctrl+b` / `Ctrl+f` | Scroll de la documentación |
| `Tab` / `Shift+Tab` | Saltar al siguiente / anterior campo de un snippet |

### 🆕 Contexto fijo (treesitter-context)
Cuando bajás dentro de una función o clase larga, la línea donde empieza (`function foo(...) {`, `class Bar`, `if (...)`) queda fija arriba de la ventana. No hay que hacer nada: es automático.

| Tecla | Acción |
|-------|--------|
| `Esp ut` | Activar / desactivar el contexto fijo |

---

## 5. 🆕 Tests (neotest)

Corrés tests desde nvim y ves el resultado **al lado de cada test**: ✓ pasó, ✗ falló, y el error en línea.

Funciona con:
- **Go** (`go test`)
- **Python** (pytest)
- **PHP** (PHPUnit y Pest)
- **JS/TS**: Vitest (vaportec-v2, coti, APC_Brokers_Astro)

| Tecla | Acción |
|-------|--------|
| `Esp tr` | Correr el test **más cercano** al cursor |
| `Esp tt` | Correr todos los tests del **archivo** |
| `Esp tT` | Correr **todos** los tests del proyecto |
| `Esp tl` | Repetir el último test que corriste |
| `Esp tw` | Modo watch: re-correr el archivo cada vez que guardás |
| `Esp to` | Ver la salida del test bajo el cursor (el error completo) |
| `Esp tO` | Panel con toda la salida |
| `Esp ts` | Panel resumen: árbol de todos los tests del proyecto con su estado |
| `Esp tS` | Detener los tests que están corriendo |
| `Esp td` | **Debuggear** el test más cercano (con breakpoints, ver sección 6) |

Dentro del panel resumen (`Esp ts`):

| Tecla | Acción |
|-------|--------|
| `Enter` | Expandir / colapsar |
| `r` | Correr el test o grupo bajo el cursor |
| `d` | Debuggearlo |
| `o` | Ver su salida |
| `i` | Ir al código del test |
| `m` y después `R` | Marcar varios tests y correr solo los marcados |
| `J` / `K` | Siguiente / anterior test **fallido** |
| `e` | Expandir todo |
| `u` | Detener |

**Flujo típico:**
1. Abrís el archivo de test y ponés el cursor dentro de un `it(...)`, `test(...)` o `func TestX`.
2. `Esp tr`: aparece ✓ o ✗ al lado.
3. Si falló, `Esp to` muestra el error; lo arreglás y `Esp tl` lo repite.
4. Para trabajar tranquilo: `Esp tw` y cada vez que guardás se re-corren solos.

> Otro proyecto JS con **Jest**: hay que agregar el adaptador `neotest-jest` en `lua/plugins/testing.lua`, igual que está vitest.

---

## 6. 🆕 Debugger (dap)

Ponés **breakpoints**, corrés el programa y cuando llega ahí se pausa: ves las variables, avanzás línea por línea y evaluás expresiones. Al empezar a debuggear se abre sola la **interfaz de debug**: variables, pila de llamadas, breakpoints y consola.

### Teclas
| Tecla | Acción |
|-------|--------|
| `Esp db` | Poner / sacar un **breakpoint** en la línea |
| `Esp dB` | Breakpoint **condicional** (solo para cuando se cumple, por ejemplo `i == 5`) |
| `Esp dc` | **Empezar** a debuggear / **continuar** hasta el próximo breakpoint |
| `Esp da` | Empezar pasándole argumentos |
| `Esp dO` | **Step over**: ejecutar la línea y pasar a la siguiente |
| `Esp di` | **Step into**: entrar en la función de esta línea |
| `Esp do` | **Step out**: terminar la función actual y volver a quien la llamó |
| `Esp dC` | Correr hasta la línea del cursor |
| `Esp dl` | Repetir la última sesión de debug |
| `Esp de` | **Evaluar** la expresión bajo el cursor o seleccionada (ver su valor) |
| `Esp dw` | Ver el valor de lo que está bajo el cursor en una ventanita |
| `Esp du` | Abrir / cerrar la interfaz de debug |
| `Esp dr` | Consola (REPL): escribís expresiones y ves el resultado |
| `Esp dj` / `Esp dk` | Bajar / subir en la pila de llamadas |
| `Esp dP` | Pausar |
| `Esp dt` | **Terminar** la sesión |
| `Esp td` | Debuggear el test más cercano (atajo desde neotest) |

### Flujo general
1. Cursor en la línea sospechosa → `Esp db` (aparece un punto rojo).
2. `Esp dc` → elegís una configuración del menú (ver cada lenguaje abajo).
3. Se pausa en el breakpoint: mirás las variables en el panel izquierdo, `Esp dO` avanza línea por línea y `Esp de` sobre una variable muestra su valor.
4. `Esp dc` sigue hasta el próximo breakpoint; `Esp dt` termina.

Mientras está pausado, los valores de las variables también aparecen **en gris al lado del código**.

### Go
Listo para usar (delve instalado). En `Esp dc` elegís:
- **Debug**: corre el archivo actual (`main`).
- **Debug Package**: el paquete entero.
- **Debug test** / **Debug test (go.mod)**: los tests.
- **Debug (Arguments)**: te pide argumentos de línea de comandos.

Lo más cómodo: breakpoint dentro de la función y `Esp td` sobre su test.

### Python
Listo para usar (debugpy). `Esp dc` → **Launch file** para el archivo actual. Si tenés un venv, elegilo antes con `Esp cv` (en un archivo `.py`).

### JavaScript / TypeScript (Node)
Listo para usar (js-debug-adapter). `Esp dc` y elegís:
- **Launch file**: ejecuta el archivo actual con Node.
- **Attach**: te conectás a un proceso Node ya corriendo, arrancado con `node --inspect` (o `--inspect-brk` para que espere). Por ejemplo: `node --inspect-brk dist/server.js`, `npx tsx --inspect src/index.ts` o `NODE_OPTIONS=--inspect npm run dev`.

Con Vitest también podés usar `Esp td` sobre un test.

### PHP (necesita Xdebug, todavía no instalado)
El adaptador y la configuración **"PHP: Listen for Xdebug"** (puerto 9003) ya están. Falta Xdebug en PHP:

```bash
sudo pacman -S xdebug
# Editar /etc/php/conf.d/xdebug.ini y dejar:
#   zend_extension=xdebug.so
#   xdebug.mode=debug
#   xdebug.start_with_request=yes
#   xdebug.client_port=9003
php -m | grep -i xdebug   # tiene que aparecer "xdebug"
```

Uso:
1. En nvim: `Esp db` en la línea que te interesa, `Esp dc` → **PHP: Listen for Xdebug**. nvim queda escuchando.
2. Ejecutás el PHP como siempre: `php script.php`, cargando la página en el navegador (con `php -S localhost:8000`) o corriendo un comando de artisan.
3. Cuando llega al breakpoint, se pausa en nvim.

> Con Docker, `xdebug.client_host` tiene que apuntar a tu máquina (`host.docker.internal`).

### Si un proyecto necesita otra configuración
nvim lee `.vscode/launch.json` si existe en el proyecto. Las configuraciones de VS Code aparecen en el menú de `Esp dc`.

---

## 7. Bases de datos (vim-dadbod)

Un cliente de SQL completo dentro de nvim (tipo DBeaver o TablePlus): te conectás a Postgres, MySQL, SQLite, etc., navegás tablas, escribís queries con autocompletado de tablas y columnas, y ves los resultados.

### Abrir
| Tecla | Acción |
|-------|--------|
| `Esp D` | Abrir / cerrar el panel de bases de datos (DBUI) |

### Agregar una conexión
**Opción 1: desde el panel.** Adentro de `Esp D` apretás `A`, pegás la URL de conexión y le ponés un nombre. Queda guardada para la próxima.

**Formatos de URL:**
```
postgresql://usuario:clave@localhost:5432/nombre_db
mysql://usuario:clave@localhost:3306/nombre_db
sqlite:/ruta/absoluta/al/archivo.db
redis://localhost:6379
```

> Si el cliente de línea de comandos no está instalado (`psql`, `mysql` o `sqlite3`), la conexión falla: dadbod los usa por detrás.

**Opción 2: por proyecto**, con un `.lazy.lua` en la raíz del proyecto (**agregalo al `.gitignore`**, tiene claves):
```lua
vim.g.dbs = {
  { name = "dev", url = "postgresql://postgres:postgres@localhost:5432/app" },
  { name = "test", url = "postgresql://postgres:postgres@localhost:5432/app_test" },
}
return {}
```

**Opción 3: variables de entorno.** DBUI toma cualquier variable que empiece con `DB_UI_`, por ejemplo `export DB_UI_DEV="postgresql://..."`.

### Dentro del panel
| Tecla | Acción |
|-------|--------|
| `o` o `Enter` | Abrir / expandir (conexión, esquema, tabla) |
| `A` | Agregar conexión |
| `r` | Renombrar |
| `d` | Borrar (una conexión o una query guardada) |
| `R` | Refrescar |
| `H` | Mostrar / ocultar detalles |
| `S` | Abrir en split vertical |
| `q` | Cerrar |

Al expandir una **tabla** aparecen consultas listas que se ejecutan con `Enter`:
- **List**: `SELECT * FROM tabla LIMIT 200`
- **Columns**: columnas y tipos
- **Indexes**, **Foreign Keys**, **Primary Keys**
- **Count**: cantidad de filas

### Escribir y ejecutar queries
1. En el panel, sobre una conexión: expandís → **New query**. Se abre un buffer SQL conectado a esa base.
2. Escribís la query; el completado sugiere tablas y columnas reales.
3. Ejecutás:

| Tecla (en el buffer SQL) | Acción |
|--------------------------|--------|
| `Esp S` | **Ejecutar** la query (todo el buffer) |
| `Esp S` en visual | Ejecutar **solo lo seleccionado** (útil si tenés varias queries en el archivo) |
| `Esp W` | Guardar la query con nombre (aparece en "Saved queries" del panel) |
| `Esp E` | Editar parámetros (si la query tiene `:param` o `?`) |

> Estos atajos existen solo dentro de un buffer SQL de DBUI y ahí le ganan a los globales (`Esp S` = scratch, `Esp E` = explorador). Guardar con `:w` **no** ejecuta la query.

### Ventana de resultados
| Tecla | Acción |
|-------|--------|
| `Esp R` | Alternar la vista de la tabla (horizontal ↔ expandida, útil con muchas columnas) |
| `vic` | Copiar el valor de la celda bajo el cursor |
| `yh` | Copiar el encabezado |
| `Ctrl+]` | Saltar a la fila relacionada por foreign key |

**Flujo típico:** `Esp D` → `o` sobre tu conexión → `o` en Tables → `Enter` en **List** de `users` y ya ves datos. Para algo más complejo: **New query**, escribís el `SELECT … JOIN …`, lo seleccionás con `V` y `Esp S`.

---

## 8. Git y GitHub

### En el archivo (gitsigns)
Un *hunk* es un bloque de líneas cambiadas; se marcan en el margen izquierdo.

| Tecla | Acción |
|-------|--------|
| `]h` / `[h` | Siguiente / anterior hunk |
| `]H` / `[H` | Último / primer hunk |
| `Esp ghp` | Ver el diff del hunk en línea |
| `Esp ghs` | **Stagear** el hunk (en visual: solo las líneas seleccionadas) |
| `Esp ghu` | Deshacer el último stage |
| `Esp ghr` | **Descartar** el hunk (vuelve a como estaba en git) |
| `Esp ghS` / `Esp ghR` | Stagear / descartar **todo** el archivo |
| `Esp ghb` | Blame de la línea: quién la escribió, cuándo y en qué commit |
| `Esp ghB` | Blame de todo el archivo |
| `Esp ghd` | Diff del archivo contra el índice |
| `Esp ghD` | Diff contra el commit anterior |
| `ih` | Text object del hunk (`vih` lo selecciona, `dih` lo borra) |

### Lazygit
| Tecla | Acción |
|-------|--------|
| `Esp gg` | Lazygit (raíz del repo) |
| `Esp gG` | Lazygit (carpeta actual) |

Dentro de lazygit:

| Tecla | Acción |
|-------|--------|
| `Espacio` | Stagear / sacar del stage el archivo |
| `a` | Stagear todo |
| `c` | Commit |
| `P` / `p` | Push / pull |
| `b` | Ramas |
| `Enter` | Ver el diff del archivo (y stagear líneas sueltas con `Espacio`) |
| `?` | Todos los atajos |
| `q` | Cerrar |

### Pickers de git
| Tecla | Acción |
|-------|--------|
| `Esp gs` | Estado (archivos modificados) con vista previa del diff |
| `Esp gd` | Todos los hunks cambiados del repo, para saltar entre ellos |
| `Esp gl` / `Esp gL` | Log de commits (raíz / carpeta actual) |
| `Esp gf` | Historial del archivo actual |
| `Esp gS` | Stash |
| `Esp gb` | Blame de la línea |
| `Esp gD` | Diff contra origin |
| `Esp gB` | Abrir el archivo o la línea en GitHub (en el navegador) |
| `Esp gY` | Copiar el link de GitHub de la línea |

### GitHub (usa el `gh` que ya tenés instalado)
| Tecla | Acción |
|-------|--------|
| `Esp gi` / `Esp gI` | Issues abiertas / todas |
| `Esp gp` / `Esp gP` | Pull requests abiertos / todos |

---

## 9. Buscar y reemplazar

### Buscar
| Tecla | Acción |
|-------|--------|
| `Esp /` o `Esp sg` | Buscar texto en todo el proyecto (grep) |
| `Esp fg` | Lo mismo (live grep) |
| `Esp sG` | Grep desde la carpeta actual |
| `Esp sw` | Buscar la palabra bajo el cursor (o la selección) en el proyecto |
| `Esp sb` | Buscar líneas dentro del archivo actual |
| `Esp sB` | Grep solo en los buffers abiertos |
| `Esp sR` | Reabrir el último picker con la misma búsqueda |
| `/` + texto | Buscar en el archivo; `n` / `N` = siguiente / anterior |
| `*` / `#` | Buscar la palabra bajo el cursor hacia adelante / atrás |

Otros buscadores útiles: `Esp sk` (atajos), `Esp sh` (ayuda), `Esp sc` (comandos usados), `Esp sm` (marks), `Esp sj` (saltos), `Esp s"` (registros), `Esp sq` (quickfix).

### Reemplazar en todo el proyecto (grug-far)
`Esp sr` abre un buffer con campos editables. En visual, precarga lo seleccionado.

1. **Search:** qué buscar (acepta regex).
2. **Replace:** por qué reemplazarlo. Se ve el resultado en vivo.
3. **Files Filter** (opcional): por ejemplo `*.vue` o `src/**`.
4. Revisás la lista de cambios (podés borrar líneas de resultados para excluirlas).
5. `\r` **reemplaza todo**.

| Tecla (en grug-far) | Acción |
|---------------------|--------|
| `\r` | Aplicar el reemplazo |
| `Enter` sobre un resultado | Ir a ese lugar |
| `\s` | Sincronizar: aplica a los archivos las ediciones que hiciste a mano en los resultados |
| `\q` | Mandar los resultados a quickfix |
| `\t` | Historial de búsquedas |
| `\c` | Cerrar |
| `g?` | Ayuda |

### Reemplazar en el archivo actual
`:%s/viejo/nuevo/g` (agregá `c` al final, `/gc`, para que pregunte en cada uno).

---

## 10. Diagnósticos, TODOs y Trouble

| Tecla | Acción |
|-------|--------|
| `]d` / `[d` | Siguiente / anterior diagnóstico (errores y warnings) |
| `]e` / `[e` | Siguiente / anterior **error** |
| `]w` / `[w` | Siguiente / anterior **warning** |
| `Esp cd` | Ver el mensaje completo del diagnóstico |
| `Esp xx` | **Trouble**: panel con los diagnósticos de todo el proyecto |
| `Esp xX` | Trouble: solo los del archivo actual |
| `Esp cs` | Trouble: símbolos del archivo (outline) |
| `Esp cS` | Trouble: referencias y definiciones del símbolo bajo el cursor |
| `Esp sd` / `Esp sD` | Diagnósticos en un picker (proyecto / archivo) |
| `Esp xq` / `Esp xQ` | Lista quickfix (normal / en Trouble) |
| `Esp xl` / `Esp xL` | Location list (normal / en Trouble) |
| `]q` / `[q` | Siguiente / anterior item de Trouble o de quickfix |

### Comentarios TODO
Si escribís `TODO:`, `FIXME:`, `HACK:`, `NOTE:`, `WARN:` o `PERF:` en un comentario, se resalta.

| Tecla | Acción |
|-------|--------|
| `]t` / `[t` | Siguiente / anterior TODO |
| `Esp st` | Todos los TODOs del proyecto (picker) |
| `Esp sT` | Solo TODO, FIX y FIXME |
| `Esp xt` / `Esp xT` | Lo mismo, en Trouble |

---

## 11. Terminal

| Tecla | Acción |
|-------|--------|
| `Ctrl+/` | Abrir / esconder la terminal flotante (raíz del proyecto). Funciona también desde adentro de la terminal |
| `Esp ft` | Terminal (raíz del proyecto) |
| `Esp fT` | Terminal (carpeta actual) |

Dentro de la terminal, `Ctrl+\` y después `Ctrl+n` pasa a modo normal (para scrollear o copiar). `i` vuelve a escribir. Con `exit` la cerrás.

---

## 12. Interruptores (Esp u)

Todo lo que se prende o se apaga está bajo `Esp u`:

| Tecla | Activa / desactiva |
|-------|--------------------|
| `Esp uf` / `Esp uF` | Formateo al guardar (global / buffer) |
| `Esp ud` | Diagnósticos |
| `Esp uh` | Inlay hints (los tipos en gris dentro del código) |
| `Esp ut` | 🆕 Contexto fijo arriba |
| `Esp uw` | Ajuste de línea (wrap) |
| `Esp us` | Corrector ortográfico |
| `Esp ul` / `Esp uL` | Números de línea / números relativos |
| `Esp ug` | Guías de indentación |
| `Esp up` | Autopares |
| `Esp uz` | Modo zen (solo el código, sin distracciones) |
| `Esp uZ` | Zoom de la ventana |
| `Esp uD` | Atenuar todo menos el bloque actual |
| `Esp uC` | Cambiar el colorscheme (con vista previa) |
| `Esp ub` | Fondo claro / oscuro |
| `Esp un` | Borrar las notificaciones en pantalla (`Esp n` = historial de notificaciones) |

---

## 13. Sesiones y salir

nvim guarda automáticamente qué archivos tenías abiertos en cada carpeta.

| Tecla | Acción |
|-------|--------|
| `Esp qs` | Restaurar la sesión de esta carpeta (los archivos que tenías abiertos) |
| `Esp ql` | Restaurar la última sesión, sea de donde sea |
| `Esp qS` | Elegir una sesión |
| `Esp qd` | No guardar la sesión actual al salir |
| `Esp qq` | Salir de nvim (cierra todo) |

También desde la pantalla de inicio: `s` restaura la sesión.

---

## 14. Archivos de root (sudo)

Abrís un archivo sin permiso de escritura (por ejemplo `nvim /etc/hosts`) y, al guardar con `:w`, **pide la contraseña de sudo sola** (vim-suda en modo automático).
Manual: `:SudaWrite` guarda como root y `:SudaRead` reabre como root.

---

## 15. Configuración por proyecto (`.lazy.lua`)

Si creás un archivo `.lazy.lua` en la raíz de un proyecto, nvim lo carga cuando lo abrís **desde esa carpeta**. La primera vez te pide confirmar que confiás en él. Sirve para:
- **Conexiones de base de datos** (ver sección 7).
- **Repo TS con tsconfig roto** que cuelga el LSP: activar el modo solo-sintaxis únicamente ahí. El snippet está en `lua/plugins/webdev.lua`.

Agregá `.lazy.lua` al `.gitignore` si tiene claves.

---

## 16. Mantenimiento

| Comando / tecla | Qué hace |
|-----------------|----------|
| `Esp l` o `:Lazy` | Gestor de plugins: `U` actualizar, `S` sync, `X` limpiar |
| `:LazyExtras` | Activar o desactivar extras de LazyVim (`x` sobre uno) |
| `Esp cm` o `:Mason` | Instalar o actualizar LSPs, formateadores y debuggers (`U` actualiza todo) |
| `:TSUpdate` | Actualizar los parsers de treesitter |
| `:checkhealth` | Diagnosticar problemas de la instalación |
| `Esp L` | Novedades de LazyVim |
| `Esp sp` | Buscar dónde está configurado un plugin |

Las versiones de los plugins quedan fijadas en `lazy-lock.json` (en el repo de dotfiles). Después de actualizar con `:Lazy`, commitealo.

---

## Chuleta diaria

```
MODOS           i / a / o    insertar          Esc        volver a normal
                Ctrl+s       guardar           :q         cerrar ventana

BUFFERS         Shift+h/l    anterior/siguiente   Esp ,    buscar buffer
                Esp bd       cerrar            Esp bw     guardar y cerrar

ARCHIVOS        Esp Esp      buscar archivo    Esp fr     recientes
                Esp /        grep proyecto     Esp fp     proyectos
                Esp e        explorador

HARPOON         Esp a        marcar            Ctrl+e     menú
                Ctrl+n/p     siguiente/anterior marca

SALTAR          s            flash             gd         definición
                gr           referencias       K          documentación
                Ctrl+o       volver atrás

EDITAR          Esp ca       code action       Esp cr     renombrar
                gcc          comentar          daf        borrar función
                ciq          cambiar entre comillas
                gsaiw"       rodear con "      gsd"       quitar "
                gsr"'        " → '             Ctrl+a     true→false, let→const, +1

TESTS           Esp tr       test cercano      Esp tt     archivo
                Esp to       ver error         Esp tw     modo watch

DEBUG           Esp db       breakpoint        Esp dc     empezar/continuar
                Esp dO       siguiente línea   Esp di     entrar en función
                Esp de       evaluar           Esp dt     terminar

GIT             Esp gg       lazygit           ]h / [h    hunks
                Esp ghs      stage hunk        Esp ghb    blame

BASE DE DATOS   Esp D        panel DBUI        Esp S      ejecutar query

SPLITS          Esp |        vertical          Esp -      horizontal
                Ctrl+h/j/k/l moverse           Esp wd     cerrar ventana

AYUDA           Esp          esperar = which-key
                Esp sk       buscar cualquier atajo
```
