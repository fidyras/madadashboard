# COVID-19 | Madagascar
This is the code repository for [covid19mg.org](covid19mg.org)

Data are obtained from daily press briefings presented by the Coronavirus Operational Task force of the government of Madagascar.

*The details and accuracy of the figures presented here are contingent upon the publicly available information communicated by the Government of Madagascar through the press.*

The data on the coronavirus cases presented on this dashboard are updated daily and are available [here](https://docs.google.com/spreadsheets/d/1oQJl4HiTviKAAhCjMmg0ipGcO79cZg6gSHrdTuQID_w/edit?usp=sharing)for download. 

## Workflow
We use `Rmarkdown` and `flexdashboard` to create html outputs and host the dashboard on github pages. Instructions for hosting static html pages without are Jekyll are [here](https://bookdown.org/yihui/blogdown/github-pages.html#fn39). 

The two key ingredients:
- A hidden file [.nojekyll](.nojekyll) at the top level of your repository.
- A landing html page called [index.html](index.html). You can link to other html files using 
relative paths (i.e. works the same as in [readmes](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/about-readmes#relative-links-and-image-paths-in-readme-files)). See the navbar in the yaml of [dashboard2.Rmd](dashboard2.Rmd) for an example.

Data and translations are pulled in daily using the `googlesheets4` package.

The bash script [update.sh](update.sh) renders the html outputs using `Rmarkdown` and pushes to this repository. This script is run approximately once per day.

## Contributors
* [Fidisoa Rasambainarivo](https://twitter.com/Fidydvm)
* [Tanjona Ramiadantsoa](https://twitter.com/TRamiadantsoa) 
* [Santatriniaina Randrianarisoa](https://twitter.com/SantatraRandri2)
* [Malavika Rajeev](https://github.com/mrajeev08)
* [Benjamin Rice](https://twitter.com/bennyvary)
* [C. Jessica Metcalf](https://twitter.com/CJEMetcalf) 

## Support from
* The Center for Health and Wellbeing 
* [Metcalf Lab](https://metcalflab.princeton.edu) at Princeton University
* [Mahaliana Labs](http://www.mahaliana.org)

## To do
- [ ] Automate using github actions & docker. 
- [ ] Integrate R<sub>t</sub>  estimation into this (code is currently [here]())
- [ ] Fix R<sub>t</sub> colors & write function to pull and plot regional results. 
- [ ] Document/clean-up dependencies