########################################################
##########  organism choice  ##########
########################################################
userChoices<- function(input, output, session)
{
  results=list()
  
  organismsDbChoices = c("Human (org.Hs.eg.db)"="org.Hs.eg.db","Mouse (org.Mm.eg.db)"="org.Mm.eg.db","Rat (org.Rn.eg.db)"="org.Rn.eg.db",
                         "Yeast (org.Sc.sgd.db)"="org.Sc.sgd.db","Fly (org.Dm.eg.db)"="org.Dm.eg.db","Arabidopsis (org.At.tair.db)"="org.At.tair.db",
                         "Zebrafish (org.Dr.eg.db)"="org.Dr.eg.db","Bovine (org.Bt.eg.db)"="org.Bt.eg.db","Worm (org.Ce.eg.db)"="org.Ce.eg.db",
                         "Chicken (org.Gg.eg.db)"="org.Gg.eg.db","Canine (org.Cf.eg.db)"="org.Cf.eg.db","Pig (org.Ss.eg.db)"="org.Ss.eg.db",
                         "Rhesus (org.Mmu.eg.db)"="org.Mmu.eg.db","E coli strain K12 (org.EcK12.eg.db)"="org.EcK12.eg.db","Xenopus (org.Xl.eg.db)"="org.Xl.eg.db",
                         "Chimp (org.Pt.eg.db)"="org.Pt.eg.db","Anopheles (org.Ag.eg.db)"="org.Ag.eg.db","Malaria (org.Pf.plasmo.db)"="org.Pf.plasmo.db",
                         "E coli strain Sakai (org.EcSakai.eg.db)"="org.EcSakai.eg.db")
  
  # geneidDbChoices = c("ensembl" = "ENSEMBL", "ncbi" = "ENTREZID")
  geneidDbChoices = keytypes(org.Dr.eg.db)
  
  pv.adjustMethods = c("holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none")
  
  updateSelectInput(session, "organismDb", choices = organismsDbChoices, selected = "org.Dr.eg.db")
  updateSelectInput(session, "geneidDb", choices = geneidDbChoices, selected = "ENSEMBL")
  updateNumericInput(session, "minGSSize", value = 10)
  updateNumericInput(session, "maxGSSize", value = 800)
  updateNumericInput(session, "nPerm", value = 10000)
  updateSelectInput(session, "pvAdjust", choices = pv.adjustMethods, selected = "BH")
  
  observe({
    orgDBdownload()
  })
  orgDBdownload <-eventReactive(input$organismDb,{
    if(input$organismDb == "")
      return(NULL)
    anyLib::anyLib(input$organismDb, autoUpdate = T) 
    library(input$organismDb, character.only = T)
    orgDb <- eval(parse(text = input$organismDb, keep.source=FALSE))
    updateSelectInput(session, "geneidDb", choices = keytypes(orgDb), selected = "ENSEMBL")
  })
  
  observe({
    res()
  })
  res <-eventReactive(c(input$organismDb, input$geneidDb, input$minGSSize, input$maxGSSize, input$nPerm, input$pvAdjust),{
    # print(list(org = input$organismDb, idDb = input$geneidDb))
    list(org = input$organismDb, idDb = input$geneidDb, minGS = input$minGSSize, maxGS = input$maxGSSize, nPerm = input$nPerm, pvAdjust = input$pvAdjust) 
  })
}

