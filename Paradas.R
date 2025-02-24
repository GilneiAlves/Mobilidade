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

# Função para buscar os corredores
buscar_corredores <- function() {
  url_corredores <- paste0(base_url, "/Corredor")
  resposta <- GET(url_corredores)
  
  if (status_code(resposta) == 200) {
    corredores <- fromJSON(content(resposta, "text", encoding = "ISO-8859-1"))
    
    if (is.data.frame(corredores) && nrow(corredores) > 0) {
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

# Função para buscar as paradas de um corredor
buscar_paradas_por_corredor <- function(codigo_corredor) {
  url_paradas <- paste0(base_url, "/Parada/BuscarParadasPorCorredor?codigoCorredor=", codigo_corredor)
  resposta <- GET(url_paradas)
  
  if (status_code(resposta) == 200) {
    paradas <- fromJSON(content(resposta, "text", encoding = "UTF-8"))
    
    if (is.data.frame(paradas) && nrow(paradas) > 0) {
      # Renomear as colunas para melhorar a legibilidade
      paradas <- paradas %>%
        rename(
          codigo_parada = cp,
          nome_parada = np,
          endereco = ed,
          latitude = py,
          longitude = px
        )
      return(paradas)
    } else {
      cat("Nenhuma parada encontrada para o corredor", codigo_corredor, "\n")
      return(NULL)
    }
  } else {
    cat("Falha ao buscar paradas para o corredor", codigo_corredor, "\n")
    return(NULL)
  }
}

# Autenticação utilizando o token fornecido
token <- "5815939c86858c6631dc068008aab013119d4d4b1bc562632001d07b91685f77"
if (autenticar(token)) {
  # Buscar todos os corredores
  corredores <- buscar_corredores()
  
  if (!is.null(corredores)) {
    # Criar a pasta "data" se não existir
    if (!dir.exists("data")) dir.create("data")
    
    # Loop para buscar paradas de cada corredor e salvar em CSV
    for (i in 1:nrow(corredores)) {
      codigo_corredor <- corredores$codigo_corredor[i]
      nome_corredor <- corredores$nome_corredor[i]
      
      cat("Buscando paradas para o corredor:", nome_corredor, "\n")
      
      paradas <- buscar_paradas_por_corredor(codigo_corredor)
      
      if (!is.null(paradas)) {
        # Criar o nome do arquivo baseado no nome do corredor
        nome_arquivo <- paste0("data/paradas_", gsub(" ", "_", nome_corredor), ".csv")
        
        # Gravar o arquivo CSV
        write.csv2(paradas, file = nome_arquivo, row.names = FALSE, fileEncoding = "UTF-8")
        
        cat("Arquivo de paradas para o corredor", nome_corredor, "gravado com sucesso!\n")
      }
    }
  }
}
