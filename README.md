# Layoff Lens

Layoff Lens is an interactive Shiny dashboard designed to help job seekers and data scientists navigate the volatile tech employment landscape. By summarizing workforce trends across major tech companies from 2000 to 2025, the tool allows users to cut through the noise of high hiring numbers to identify companies with true net growth.

## Motivation

Raw hiring data can be misleading. We live in a market where a company might hire 1,000 people while simultaneously laying off 1,200. Layoff Lens safeguards users by visualizing the Net Change and Hire-Layoff Ratio. This allows applicants to prioritize companies with a healthy, expanding environment rather than those simply replacing churned staff, helping them avoid pull-back periods following rapid, unsustainable growth.

## Local Development

To run the dashboard locally, follow these steps:

### Set Up the Environment

Ensure you have `conda` or `mamba` installed

```bash
# Create and activate a virtual environment
conda env create -f environment.yml
conda activate tech_layoff_lens_r
```

### Run the Dashboard

Use the Shiny CLI to run the app:

```bash
R -e "shiny::runApp('src/app.R')"
```

Once running, open the link displayed on your terminal to view the dashboard.
