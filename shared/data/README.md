# Shared data

All labs in this curriculum are **self-contained**: each `.qmd` file either
simulates the data it needs or uses a built-in R dataset (e.g. `iris`,
`palmerpenguins::penguins`, `survival::lung`, `MASS::Pima.tr`).

No external data files are required to render the site. If you want to
experiment with your own datasets, drop them here. Files placed in
`shared/data/` are ignored by the render pipeline but kept under version
control (adjust `.gitignore` to taste).

Keep file sizes small. For anything larger than ~10 MB, consider storing
a script that downloads or simulates the data instead of the data itself.
