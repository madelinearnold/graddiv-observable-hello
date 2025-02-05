# Framework - Google Cloud Integration

This is a project integrating Observable Framework with Google Cloud using Google App Engine. 

Several files in this repository are used for the integration, while the remaining files are part of the Hello Framework template from Observable.
1. The deploy.sh file assists in setting up the Google Cloud project for hosting. This includes initiating the Google App Engine on Google Cloud, and setting permissions.
2. The app.yaml, main.py, and requirements.txt files are required in generating the Google App Engine app.

To deploy the app you will need to install Google SDK to access to Google Cloud via the terminal. 

Here are step-by-step instructions for setting up the integration:

1) Alter the deploy.sh file as needed to include the name of the Google Cloud project where you want to store the files for the Framework app, and email addresses for project owners.
2) Run the deploy.sh script using `sh deploy.sh` from the terminal (make sure you are in the directory where the script is located). This should result in a project and app engine set up on Google Cloud with necessary permissions.
3) Build your Framework site using `npm run build`, then deploy the app to Google Cloud using `gcloud app deploy`. You can see the app in the browser using `gcloud app browse` or going to the URL.

## Hello Framework

This is an [Observable Framework](https://observablehq.com/framework) project. To start the local preview server, run:

```
npm run dev
```

Then visit <http://localhost:3000> to preview your project.

For more, see <https://observablehq.com/framework/getting-started>.

## Project structure

A typical Framework project looks like this:

```ini
.
├─ src
│  ├─ components
│  │  └─ timeline.js           # an importable module
│  ├─ data
│  │  ├─ launches.csv.js       # a data loader
│  │  └─ events.json           # a static data file
│  ├─ example-dashboard.md     # a page
│  ├─ example-report.md        # another page
│  └─ index.md                 # the home page
├─ .gitignore
├─ observablehq.config.js      # the project config file
├─ package.json
└─ README.md
```

**`src`** - This is the “source root” — where your source files live. Pages go here. Each page is a Markdown file. Observable Framework uses [file-based routing](https://observablehq.com/framework/routing), which means that the name of the file controls where the page is served. You can create as many pages as you like. Use folders to organize your pages.

**`src/index.md`** - This is the home page for your site. You can have as many additional pages as you’d like, but you should always have a home page, too.

**`src/data`** - You can put [data loaders](https://observablehq.com/framework/loaders) or static data files anywhere in your source root, but we recommend putting them here.

**`src/components`** - You can put shared [JavaScript modules](https://observablehq.com/framework/javascript/imports) anywhere in your source root, but we recommend putting them here. This helps you pull code out of Markdown files and into JavaScript modules, making it easier to reuse code across pages, write tests and run linters, and even share code with vanilla web applications.

**`observablehq.config.js`** - This is the [project configuration](https://observablehq.com/framework/config) file, such as the pages and sections in the sidebar navigation, and the project’s title.

## Command reference

| Command           | Description                                              |
| ----------------- | -------------------------------------------------------- |
| `npm install`            | Install or reinstall dependencies                        |
| `npm run dev`        | Start local preview server                               |
| `npm run build`      | Build your static site, generating `./dist`              |
| `npm run deploy`     | Deploy your project to Observable                        |
| `npm run clean`      | Clear the local data loader cache                        |
| `npm run observable` | Run commands like `observable help`                      |
