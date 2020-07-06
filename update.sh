#!/bin/bash


# Whichever one you want to be the home page output as index.html
Rscript -e 'rmarkdown::render("dashboard2.Rmd", output_file = "index.html", params = list(lang = "EN"))'
Rscript -e 'rmarkdown::render("dashboard2.Rmd", output_file = "dashboard_FR.html", params = list(lang = "FR"))'
Rscript -e 'rmarkdown::render("dashboard2.Rmd", output_file = "dashboard_MG.html", params = list(lang = "MG"))'

# Stage files to be committed
git add \*.md \*.Rmd \*.html

# Commit with date
git commit -m "`date`"

# Push to remote
git push