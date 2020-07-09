#!/bin/bash


# Whichever one you want to be the home page output as index.html
Rscript -e 'rmarkdown::render("dashboard2.Rmd", output_file = "dashboard_EN.html", params = list(lang = "ENG"))'
Rscript -e 'rmarkdown::render("dashboard2.Rmd", output_file = "dashboard_FR.html", params = list(lang = "FRA"))'
Rscript -e 'rmarkdown::render("dashboard2.Rmd", output_file = "index.html", params = list(lang = "MDG"))'

# Stage files to be committed
git add \*.md \*.Rmd \*.html

# Commit with date
git commit -m "`date`"

# Push to remote
git push