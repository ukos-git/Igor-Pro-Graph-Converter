Igor Pro Graph Converter
========================

Publish your Igor Pro graphs to online Plotly graphs with 1-click!

[![Contour subplots in Igor Pro](http://i.imgur.com/9QKmUQb.png)](https://plot.ly/~test-runner/10)

# Installation Instructions

1. Install the easyHTTP XOP as an Igor extension (downloaded from Igor exchange)
  
  Follow the instrucions for MAC/PC in the easyHTTP install.txt file. Bascially, the 
easyHTTP.xop file, or a shortcut to it, needs to end up Igor’s extension folder 
(WaveMetrics\Igor Pro Folder\Igor Extensions). The extension will then load 
automatically every time Igor starts

2. Install the PlotlyFunctions.ipf Igor procedure file
  - It is possible just to load this with File->Open File->Procedure for each new 
experiment
  - It is easier to place the PlotlyFunctions.ipr or a shortcut to PlotlyFunctions.ipf in 
the directory `\Documents\WaveMetrics\Igor Pro 6 User Files\Igor Procedures` or 
`Program Files (x86)\WaveMetrics\Igor Pro Folder\User Procedures`. This makes the 
procedure file load every time Igor starts.

3. Tell Igor who is using plotly
  - From the command line, run the function PlotlySetUser with the parameters set 
correctly:
`plotlySetUser(user="your_plotly_username",key="your_api_key")`
  - I recommend writing a function similar to my `plotlyUser` function and adding the 
function to the Plotly procedure or some other procedure that always loads when 
Igor starts. Then, to set the user, it is only necessary to run the function:

    ```
    Function jbmUser()
        string user, key
        NewDataFolder/O root:Packages
        NewDataFolder/O root:Packages:Plotly // This line just makes sure this data folder exists.
        string/G root:Packages:Plotly:userName = "your_plotly_username"
        string/G root:Packages:Plotly:userKey = "your_plotly_apikey"
    end
    ```

# Usage

Create some data and a simple graph

```
make/N=10 testData={4,2,4,6,4,1,6,1,3,0}
display testData
```

Now send the data to plotly by either pressing ctrl-1, or executing the 
command:

```
Graph2plotly()
```

Which a JSON string with a URL of an online version of your graph:

`{"url": "http://plot.ly/~jbmiller/119", "message": "", 
"warning": "", "filename": "Demo Experiment #1Demo Experiment #1/Graph0",
"error": ""}`


# Advanced Usage for Developers

You can view the converted JSON with the following command: 

```
Graph2plotly(keepCMD=1)
```

This displays a text file with Plotly's JSON format, which you can edit by hand.

If you want to send the text file, just use the “command” to plotly command, 
but you have to supply the name of the text window, e.g
`CMD2Plotly("Graph0_CMD")`


`Graph2Plotly` also takes an optional parameter for a graph window name, 
so you don’t have to send the “top” graph (although I always send the top graph)

```
graph2plotly(graph=”graph0”)
```

You can also make a text window, but not send it to Plotly:
```
graph2plotly(skipsend=1)
```

You can also choose the name of the graph in Plotly. 
If you don’t choose, the name is the same as the name in Igor. 
Also, by default, the Plotly folder is the same as the experiment name, but can 
also be specified:

```
graph2plotly(plotlyGraph=”MyName”,plotlyFolder=”MyFolder”)
```
