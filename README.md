Igor Pro Graph Converter
========================

Publish your Igor Pro graphs to online Plotly graphs with 1-click!

[![Igor Pro Logo](https://plot.ly/~ukos-plotly/14.png)](https://plot.ly/~ukos-plotly/14)

Click the above graph to fly to plot.ly and see the interactive version.

# Installation Instructions

Igor Pro >= 7 is required.

- Copy or link the files under `src/` to the Igor Pro User Procedure folder.
- Dynamically load Plotly if you need it by adding `#include "Plotly"` to your Experiment.
- Add your Plotly api_key: PlotlySetUser("username", "api_key")
- Export the topmost graph to plot.ly: `Graph2Plotly()`

# Usage

Create some data and a simple graph

```igorpro
Make/N=10 testData={4,2,4,6,4,1,6,1,3,0}
Display testData
```

# Advanced Usage

## send to plotly

Now send the data to plotly by executing the
command:

```igorpro
Graph2Plotly()
```

## export

```igorpro
Graph2Plotly(output = "plotly.json", writeFile = 1, skipSend = 1)
```

This writes a JSON string with the name `plotly.json` to the path where
the Experiment is located (home).

## optional parameters

The following optional parameters are available:


* `graph`         default: Use the top graph
* `output`        default: Use the name of the experiment.
* `skipSend`      default: 1 (Do not send the graph to plot.ly)
* `keepCMD`       default: 0 (Do not keep the CMD output notebook)
* `writeFile`     default: 1 (Write output to a json file in home)

## offline plots

There is a tiny python script in `bin/` that allows conversion to offline html using
the plotly python library.

## Trouble Shooting

### Install

If you can not find your User Procedures folder, go to Help->Show Igor Pro User Files to navigate
quickly to this system-specific folder. Currently, on windows 10 with Igor Pro 8, this folder is named
`%USERPROFILE%\Documents\WaveMetrics\Igor Pro 8 User Files\Igor Procedures`.

### API Communication

API communication is running on a deprecated API version. It may break eventually.

After a successful call to the api, the url is returned. Please watch the output on stdout:

```igorpro
Graph2Plotly()
```
```json
  {"error": "", "warning": "", "message": "", "url": "https://plot.ly/~username/0", "filename": "Untitled"}
```

Report back on github if you see unusual errors like this:

```json
  {"error": "Hm... Plotly had some trouble decoding your 'args'. Are you sure your data or styling object is in the right format? Check out the examples at https://plot.ly/api for guidance.\n\nNeed help
? Please try searching Plotly's <a href='http://stackoverflow.com/questions/tagged/plotly'>Stack Overflow channel</a>.", "warning": "", "message": "", "url": "", "filename": ""}
```
