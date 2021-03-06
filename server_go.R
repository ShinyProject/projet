go <- function(input, output, session, org, orgDb, pvalues, logF, minGS, maxGS, nPerm, pvAdjustMethod)
{
  ########################################################
  ##########                GO                  ##########
  ########################################################
  source(file = "GO_term.R")
  
  ########################## GO SEA #######################################
  observe({SEA_GO()})
  SEA_GO <- eventReactive(input$pv.GO,{
    withProgress(message = 'GO ... ', value = 1, {
      incProgress(2/5, detail = "SEA analysis...")
      
      SEA_result <- SEAanalysis(pvalues, input$pv.GO, org, minGSSize = minGS, maxGSSize = maxGS, pAdjustMethod = pvAdjustMethod)
      #### Plots ####
      incProgress(3/5, detail = "SEA plots...")
      
      ## BP plot
      bp <- bp_SEA_Plot(SEA_result)
      output$SEA_bp <- renderPlot({ bp })
      ## DOWNLOAD PLOT
      output$dl.SEAGO_BP_hist <- downloadHandler(
        filename = "SEA_GO_BP.pdf",
        content = function(file) 
        {
          ggsave(file, plot=bp)
        }
      )
      
      ## MF plot
      mf <- mf_SEA_Plot(SEA_result)
      output$SEA_mf <- renderPlot({ mf })
      ## DOWNLOAD PLOT
      output$dl.SEAGO_MF_hist <- downloadHandler(
        filename = "SEA_GO_MF.pdf",
        content = function(file) 
        {
          ggsave(file, plot=mf)
        }
      )

      ## MF plot
      cc <- cc_SEA_Plot(SEA_result)
      output$SEA_cc <- renderPlot({ cc })
      ## DOWNLOAD PLOT
      output$dl.SEAGO_CC_hist <- downloadHandler(
        filename = "SEA_GO_CC.pdf",
        content = function(file) 
        {
          ggsave(file, plot=cc)
        }
      )
      
      
      ## BP TABLE ##
      GO_BP.SEA_description = SEA_result$BP
      GO_BP.SEA_description$GO_term= paste0("<a href=http://amigo.geneontology.org/amigo/term/", GO_BP.SEA_description$GO_term," target='_blank'>",GO_BP.SEA_description$GO_term, "</a>")
      GO_BP.SEA_description$pval = GO_BP.SEA_description$pval %>% round(3)
      output$GO_BP.SEA.Table = DT::renderDataTable({
        GO_BP.SEA_description
      }, escape = F) # escape FALSE t
      ## DOWNLOAD
      output$dl.SEAGO_BP <- downloadHandler(
        filename = "SEA_GO_BP.csv",
        content = function(filename) {
          write.csv(GO_BP.SEA_description, filename, row.names = T)
        }
      )
      ## CC TABLE ##
      GO_CC.SEA_description = SEA_result$CC
      GO_CC.SEA_description$GO_term= paste0("<a href=http://amigo.geneontology.org/amigo/term/", GO_CC.SEA_description$GO_term," target='_blank'>",GO_CC.SEA_description$GO_term, "</a>")
      GO_CC.SEA_description$pval = GO_CC.SEA_description$pval %>% round(3)
      output$GO_CC.SEA.Table = DT::renderDataTable({
        GO_CC.SEA_description
      }, escape = F) # escape FALSE t   
      ## DOWNLOAD
      output$dl.SEAGO_CC <- downloadHandler(
        filename = "SEA_GO_CC.csv",
        content = function(filename) {
          write.csv(GO_CC.SEA_description, filename, row.names = T)
        }
      )
      ## MF TABLE ##
      GO_MF.SEA_description = SEA_result$MF
      GO_MF.SEA_description$GO_term= paste0("<a href=http://amigo.geneontology.org/amigo/term/", GO_MF.SEA_description$GO_term," target='_blank'>",GO_MF.SEA_description$GO_term, "</a>")
      GO_MF.SEA_description$pval = GO_MF.SEA_description$pval %>% round(3)
      
      output$GO_MF.SEA.Table = DT::renderDataTable({
        GO_MF.SEA_description
      }, escape = F) # escape FALSE to make url
      
      ## DOWNLOAD
      output$dl.SEAGO_MF <- downloadHandler(
        filename = "SEA_GO_MF.csv",
        content = function(filename) {
          write.csv(GO_MF.SEA_description, filename, row.names = T)
        }
      )
    }) # end GO reactive
    
    
    
    ########################## GO GSEA #######################################
    incProgress(4/5, detail = "GSEA analysis...")
    GSEA_result <- GSEAanalysis(logF, orgDb, minGS, maxGS, nPerm, pvAdjustMethod)
    
    #### Plots ####
    incProgress(5/5, detail = "GSEA Plots...")
    
    ## GSEA BP plot
    bp_gsea <- bp_GSEA_Plot(GSEA_result)
    output$GSEA_bp <- renderPlot({  bp_gsea })
    ## DOWNLOAD PLOT
    output$dl.GSEAGO_BP_hist <- downloadHandler(
      filename = "GSEA_GO_BP.pdf",
      content = function(file) 
      {
        ggsave(file, plot=bp_gsea)
      }
    )
    
    # GSEA MF plot
    mf_gsea <-mf_GSEA_Plot(GSEA_result) 
    output$GSEA_mf <- renderPlot({ mf_gsea })
    ## DOWNLOAD PLOT
    output$dl.GSEAGO_MF_hist <- downloadHandler(
      filename = "GSEA_GO_MF.pdf",
      content = function(file) 
      {
        ggsave(file, plot=mf_gsea)
      }
    )
    
    ## GSEA CC plot
    cc_gsea <- cc_GSEA_Plot(GSEA_result)
    output$GSEA_cc <- renderPlot({ cc_gsea  })
    ## DOWNLOAD PLOT
    output$dl.GSEAGO_CC_hist <- downloadHandler(
      filename = "GSEA_GO_CC.pdf",
      content = function(file) 
      {
        ggsave(file, plot=cc_gsea)
      }
    )
    
    
    ## TABLE - Biological Processes ##
    GO.GSEA_description = GSEA_result[["BP"]]@result
    GO.GSEA_description = dplyr::select(GSEA_result[["BP"]]@result, ID, Description)
    GO.GSEA_description$ID = paste0("<a href=http://amigo.geneontology.org/amigo/term/", GO.GSEA_description$ID," target='_blank'>",GO.GSEA_description$ID,"</a>")
    GO.GSEA_value = dplyr::select(GSEA_result[["BP"]]@result, setSize:p.adjust, -NES) %>% round(3)
    GO.GSEA_BP = cbind(GO.GSEA_description, GO.GSEA_value)
    
    output$GO_BP.GSEA.Table = DT::renderDataTable({
      GO.GSEA_BP
    }, escape = F) # escape FALSE to make url
    
    ## DOWNLOAD
    output$dl.GSEAGO_BP <- downloadHandler(
      filename = "GSEA_GO_BP.csv",
      content = function(filename) {
        write.csv(GSEA_result[["BP"]]@resul, filename, row.names = T)
      }
    )
    
    ## TABLE - Molecular Functions ##
    GO.GSEA_description = GSEA_result[["MF"]]@result
    GO.GSEA_description = dplyr::select(GSEA_result[["MF"]]@result, ID, Description)
    GO.GSEA_description$ID = paste0("<a href=http://amigo.geneontology.org/amigo/term/", GO.GSEA_description$ID," target='_blank'>",GO.GSEA_description$ID,"</a>")
    GO.GSEA_value = dplyr::select(GSEA_result[["MF"]]@result, setSize:p.adjust, -NES) %>% round(3)
    GO.GSEA_MF = cbind(GO.GSEA_description, GO.GSEA_value)
    
    output$GO_MF.GSEA.Table = DT::renderDataTable({
      GO.GSEA_MF
    }, escape = F) # escape FALSE to make url
    
    ## DOWNLOAD
    output$dl.GSEAGO_MF <- downloadHandler(
      filename = "GSEA_GO_MF.csv",
      content = function(filename) {
        write.csv(GSEA_result[["MF"]]@resul, filename, row.names = T)
      }
    )
    
    ## TABLE - Cellular Components ##
    GO.GSEA_description = GSEA_result[["CC"]]@result
    GO.GSEA_description = dplyr::select(GSEA_result[["CC"]]@result, ID, Description)
    GO.GSEA_description$ID = paste0("<a href=http://amigo.geneontology.org/amigo/term/", GO.GSEA_description$ID," target='_blank'>",GO.GSEA_description$ID,"</a>")
    GO.GSEA_value = dplyr::select(GSEA_result[["CC"]]@result, setSize:p.adjust, -NES) %>% round(3)
    GO.GSEA_CC = cbind(GO.GSEA_description, GO.GSEA_value)
    
    output$GO_CC.GSEA.Table = DT::renderDataTable({
      GO.GSEA_CC
    }, escape = F) # escape FALSE to make url
    
    ## DOWNLOAD
    output$dl.GSEAGO_CC <- downloadHandler(
      filename = "GSEA_GO_CC.csv",
      content = function(filename) {
        write.csv(GSEA_result[["CC"]]@resul, filename, row.names = T)
      }
    )
  })
}