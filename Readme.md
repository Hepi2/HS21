Anleitung für Admins
================

## Allgemeines

### Distill

Im Kurs Research Methods verwenden wir seit einigen Jahren RMarkdown um
die R Unterlagen für die Studenten bereit zu stellen. Bis und mit HS2020
haben wir dafür [`bookdown`](https://bookdown.org/yihui/blogdown/)
verwendet, im HS2021 wollen wir zu
[`distill`](https://rstudio.github.io/distill/) wechseln.

-   Vorteil: Mit Bookdown müssen bei Änderungen jeweils *alle*
    .Rmd-Files neu kompiliert werden, was unter umständen sehr lange
    dauern kann. Mit `distill` ist jedes .Rmd File wie ein eigenes
    kleines Projekt und kann eigenständig kompiliert werden.
-   Nachteile:
    -   Werden files in mehreren .Rmd Files benutzt müssen diese für
        jedes .Rmd file abgespeichert werden
    -   ein PDF wird nicht ohne weiteres generiert

### Renv

Im Unterricht werden sehr viele RPackages verwendet. Um sicher zu
stellen, das wir alle mit der gleichen Version dieser Packages arbeiten
verwenden wir das RPackage [`renv`](https://rstudio.github.io/renv/).
Das arbeiten mit `renv` bringt folgende Änderungen mit sich:

-   Packages werden alle im Projektfolder installiert (`renv/library`)
    statt wie üblich in `C:/Users/xyz/Documents/R/win-library/3.6` bzw.
    `C:/Program Files/R/R-3.6.1/library`
    -   Dies wird durch `.Rprofile` sichergestellt (`.Rprofile` wird
        automatisch beim Laden des Projektes ausgeführt)
    -   Der Folder `renv/library` wird *nicht* via github geteilt (dies
        wird mit `renv/.gitignore` sichergestellt)
-   Die Liste der Packages wird in `renv.lock` festgehalten (mit dem
    Befehl `renv::snapshot()`, mehr dazu später)
-   Die Packages werden mit `renv::restore()` lokal installiert

## Anleitung: Software Aufsetzen

### R, RStudio und Git installieren

*(wer dies bereits gemacht hat, kann diesen Schritt überspringen)*

Wer Lokal auf seinem eingenen PC arbeiten will, muss eine aktuell
version von R, RStudio und Git installieren. Siehe dazu folgende
Anleitungen:

-   [Install or upgrade R and
    RStudio](https://happygitwithr.com/install-r-rstudio.html)
-   [Install Git](https://happygitwithr.com/install-git.html)

### RStudio Konfigurieren

Ich empfehle folgende Konfiguration in RStudio
(`Global Options -> R Markdown`):

-   Show document outline by default: checked *(Stellt ein
    Inhaltsverzeichnis rechts von .Rmd files dar)*
-   Soft-wrap R Markdown files: checken *(macht autmatische
    Zeilenumbrüche bei .Rmd files)*
-   Show in document outline: Sections Only *(zeigt nur “Sections” im
    Inhaltsverzeichnis)*
-   Show output preview in: Window *(beim kopilieren von Rmd Files wird
    im Anschluss ein Popup mit dem Resultat dargestellt)*
-   Show equation an impage previews: In a popup
-   Evaluate chunks in directory: Document

### Git konfigurieren

*(wer dies bereits gemacht hat, kann diesen Schritt überspringen)*

Nach der Installation muss git konfiguriert werden. Siehe dazu folgende
Kapitel:

-   [Introduce yourself to
    Git](https://happygitwithr.com/hello-git.html)
-   [Cache credentials for
    HTTPS](https://happygitwithr.com/credential-caching.html)

## Anleitung: Projekt aufsetzen

### Repo Klonen

Um die ganzen \*.Rmd Files lokal bearbeiten zu können, muss das
Repository geklont werden. Mit RStudio ist dies sehr einfach, siehe dazu
nachstehende Anleitung. Als Repo-URL folgendes einfügen:
`https://github.zhaw.ch/ModulResearchMethods/Unterrichtsunterlagen_HS20.git`

-   [New RStudio Project via git
    clone](https://happygitwithr.com/new-github-first.html#new-rstudio-project-via-git)

### “Upstream” setzen

Um das Github repo als standart “upstream” zu setzen muss man im
Terminal nachstehenden Befehl eingeben. Danach RStudio neu starten und
das entsprechende Projekt laden. Nun sollte im “Git” fenster der “Push”
button nicht mehr inaktiv sein.

    git branch -u origin/main

### Notwendige Packages installieren

Wie bereits erwähnt, verwenden wir im Projekt `renv`.

-   Installiert dieses Package mit `install.packages("renv")`
-   Installiert alle notwendigen Packages mit `renv::restore()`

## Anleitung: Inhalte Editieren und veröffentlichen

Eine `distill` Webseite besteht aus einzelnen .Rmd Files, pro Rmd-File
exisitert ein eigener Ordner im Projekt. Diese Rmd fiels werden beim
Kompilieren (`knìt`) in .html-Files konvertiert. Um daraus eine
zusammenhängende Website zu machen ist das File `_site.yml`
verantwortlich. Die Einstiegsseite wird in `index.Rmd` definiert.

### Rmd Editieren

Um Inhalte zu editieren, öffnet ihr das entsprechende .Rmd file in einem
der Ordner \_infovis, \_prepro, \_rauman, \_statistik,
\_statistik-konsolidierung. Ihr könnt dies wie ein reguläres,
eigenständiges .Rmd File handhaben. Alle Pfade im Dokument sind
*relativ* zum .Rmd File zu verstehen: **Das Working directory ist der
Folder des entsprechenden Rmd Files!!**.

### Rmd Kompilieren

Um das Rmd in Html zu konvertieren (“Kompilieren”) klickt ihr auf “Knit”
oder nutzt die Tastenkombination `Ctr + Shift + K`.

### Änderungen veröffentlichen

Um die Änderungen zu veröffentlichen (für die Studenten sichtbar zu
machen) müsst ihr diese via git auf das Repository “pushen”. Vorher aber
müsst ihr die Änderungen `stage`-en und `commit`-en. Ich empfehle, dass
ihr zumindest zu beginn mit dem RStudio “Git” Fenster arbeitet.

-   `stage`: Setzen eines Häckchens bei “Staged”
-   `commit`: Klick auf den Button “commit”
-   `push`: Click auf den button “Push”

*Achtung*: Um Änderungen, die ihr am .Rmd gemacht habt, sichtbar zu
machen müsst ihr das .Rmd File zuerst kompilieren!

## Anleitung: Listings editieren und veröffentlichen

*(dieser Teil ist eher Advanced und nicht für alle Interessant)*

`distill` verfügt über die Möglichkeit, sogenannte “Collections” zu
machen. Eine *collection* ist eine Sammlung von .Rmd files zu einem
bestimmten Thema, für welche automatisch eine Übersichtsseite (sog.
“Listing”) erstellt wird.

Um eine *collection* zu erstellen:

1.  neuer Ordner mit entsprechendem Namen und vorangestelltem Underscore
    (`_`) im Projektordner erstellen (z.b. \_infovis)

2.  neues Rmd-File mit einem passenden Namen im Projektordner erstellen
    (z.B. `infoVis.Rmd`)

3.  das neue Rmd File mit einem Rmd-YAML Header verstehen mit mindestens
    folgendem Inhalt: `title` und `listing` (siehe unten)

         ---
         title: "InfoVis"      # <- Egal
         listing: infovis      # <- ordnername der collection ohne Underscore
         ---

4.  die Listing in `_site.yml` zugänglich machen:

         navbar:
           right:
             - text: "InfoVis1"     # <- Egal
               href: InfoVis.html   # <- Name des Rmd files mit der Endung .html
