# Read data
summary = tabItem(tabName = "summary",
  
  h1("Summary"),
  
  ## FILE INPUT
  fileInput("data", label = NULL,
    buttonLabel = "Browse...",
    placeholder = "No file selected"),
  
  ## pvalue
  sliderInput("pv", label = h3("p-value threshold : "), min = 0, 
    max = 0.1, value = 0.05),
  textOutput("text"),  
  
  h1("Clickable Volcano Plots!"),
  sliderInput('logFcCut', label="log(CPM) cutoff",0,10,2, width="200px"), # S�lection du seuil pour le foldchange
  sliderInput('padjCut', label="padj cutoff",0,1,0.05, width="200px"),  # S�lection du seuil de la pvalue ajust�
  plotOutput('volcanoPlot',click='plot_click.Volcano'), #VolcanoPlot
  tableOutput('clickedPoints.Volcano'), # Tableau correspondant � la zone cliqu� du VolcanoPlot
  plotOutput('maPlot',click='plot_click.MA'), # MA plot
  tableOutput('clickedPoints.MA') # Tableau correspondant � la zone cliqu� du MA plot
)

         