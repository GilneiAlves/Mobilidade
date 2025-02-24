# Instalar e carregar os pacotes necessários
if (!require(httr)) install.packages("httr", dependencies = TRUE)
if (!require(jsonlite)) install.packages("jsonlite", dependencies = TRUE)
if (!require(dplyr)) install.packages("dplyr", dependencies = TRUE)

library(httr)
library(jsonlite)
library(dplyr)

# Definir a URL base da API
base_url <- "http://api.olhovivo.sptrans.com.br/v2.1"

# Função para autenticação na API
autenticar <- function(token) {
  url_auth <- paste0(base_url, "/Login/Autenticar?token=", token)
  resposta <- POST(url_auth)
  
  if (status_code(resposta) == 200 && content(resposta, "text") == "true") {
    cat("Autenticação bem-sucedida!\n")
    return(TRUE)
  } else {
    cat("Falha na autenticação.\n")
    return(FALSE)
  }
}

# Função para buscar informações de linhas
buscar_linhas <- function(termos_busca) {
  url_busca <- paste0(base_url, "/Linha/Buscar?termosBusca=", URLencode(termos_busca))
  resposta <- GET(url_busca)
  
  if (status_code(resposta) == 200) {
    linhas <- fromJSON(content(resposta, "text"))
    
    # Verificar se linhas não está vazio e é uma lista
    if (is.list(linhas) && length(linhas) > 0) {
      # Converter para data frame
      linhas <- as.data.frame(linhas)
      
      # Renomear as colunas para melhorar a legibilidade
      linhas <- linhas %>%
        rename(
          codigo_linha = cl,
          linha_circular = lc,
          letreiro_numerico = lt,
          tipo_linha = tl,
          sentido_linha = sl,
          descricao_terminal_principal = tp,
          descricao_terminal_secundario = ts
        )
      
      return(linhas)
    } else {
      cat("Nenhum dado encontrado para:", termos_busca, "\n")
      return(NULL)
    }
  } else {
    cat("Falha ao buscar informações de linhas para:", termos_busca, "\n")
    return(NULL)
  }
}

# Lista de linhas para buscar
linhas_para_buscar <- c("5118/10", "5119/10", "647P/10", "647A/10", "7241/10", "746H/10", "746J/10", "775F/10", "756A/10")

# Autenticação utilizando o token fornecido
token <- "5815939c86858c6631dc068008aab013119d4d4b1bc562632001d07b91685f77"
if (autenticar(token)) {
  # Criar a pasta "data" se não existir
  if (!dir.exists("data")) dir.create("data")
  
  # Loop para buscar informações de cada linha e gravar em CSV
  for (linha in linhas_para_buscar) {
    resultado_linhas <- buscar_linhas(linha)
    
    if (!is.null(resultado_linhas)) {
      # Definir o caminho do arquivo CSV
      caminho_arquivo <- paste0("data/", gsub("/", "_", linha), ".csv")
      
      # Gravar o DataFrame em um arquivo CSV
      write.csv(resultado_linhas, file = caminho_arquivo, row.names = FALSE, fileEncoding = "UTF-8", sep = ";")
      
      cat("Arquivo gravado com sucesso para a linha:", linha, "\n")
    }
  }
}
