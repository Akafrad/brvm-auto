library(BRVM)
library(openxlsx)

chemin_fichier <- "BRVM_Cours_Quotidiens.xlsx"
tickers <- unique(toupper(BRVM_ticker_desc()$Ticker))
date_du_jour <- Sys.Date() - 1

if (file.exists(chemin_fichier)) {
  wb <- loadWorkbook(chemin_fichier)
} else {
  wb <- createWorkbook()
}

for (ticker in tickers) {
  cat("📥 Ticker :", ticker, "\n")
  data <- tryCatch({
    BRVM_get(ticker, .from = date_du_jour, .to = date_du_jour)
  }, error = function(e) {
    cat("❌ Erreur pour", ticker, "\n")
    return(NULL)
  })

  if (!is.null(data) && nrow(data) > 0) {
    if (!(ticker %in% names(wb))) {
      addWorksheet(wb, ticker)
      writeData(wb, sheet = ticker, x = data)
    } else {
      ancienne <- readWorkbook(wb, sheet = ticker)
      nouvelle <- rbind(ancienne, data)
      writeData(wb, sheet = ticker, x = nouvelle, withFilter = FALSE)
    }
  }
}

saveWorkbook(wb, chemin_fichier, overwrite = TRUE)
cat("✅ Mise à jour OK pour", date_du_jour, "\n")
