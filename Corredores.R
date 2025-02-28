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
  
  if (status_code(resposta) == 200 && content(resposta, "text", encoding = "ISO-8859-1") == "true") {
    cat("Autenticação bem-sucedida!\n")
    return(TRUE)
  } else {
    cat("Falha na autenticação.\n")
    return(FALSE)
  }
}

# Função para buscar todos os corredores
buscar_corredores <- function() {
  url_corredores <- paste0(base_url, "/Corredor")
  resposta <- GET(url_corredores)
  
  if (status_code(resposta) == 200) {
    corredores <- fromJSON(content(resposta, "text", encoding = "ISO-8859-1"))
    
    # Verificar se corredores não está vazio
    if (is.data.frame(corredores) && nrow(corredores) > 0) {
      # Renomear as colunas para melhorar a legibilidade
      corredores <- corredores %>%
        rename(
          codigo_corredor = cc,
          nome_corredor = nc
        )
      
      return(corredores)
    } else {
      cat("Nenhum dado de corredor encontrado.\n")
      return(NULL)
    }
  } else {
    cat("Falha ao buscar os corredores.\n")
    return(NULL)
  }
}

# Autenticação utilizando o token fornecido
token <- "5815939c86858c6631dc068008aab013119d4d4b1bc562632001d07b91685f77" # Token de teste foi exclido, seguir a documentação para criar um novo
if (autenticar(token)) {
  # Buscar os corredores
  corredores <- buscar_corredores()
  
  if (!is.null(corredores)) {
    # Criar a pasta "data" se não existir
    if (!dir.exists("data")) dir.create("data")
    
    # Gravar os corredores em um arquivo CSV
    caminho_arquivo <- "data/corredores.csv"
    write.csv2(corredores, file = caminho_arquivo, row.names = FALSE, fileEncoding = "UTF-8")
    
    cat("Arquivo de corredores gravado com sucesso!\n")
  }
}
