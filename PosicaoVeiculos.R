# Instalar e carregar os pacotes necessários
if (!require(httr)) install.packages("httr", dependencies = TRUE)
if (!require(jsonlite)) install.packages("jsonlite", dependencies = TRUE)
if (!require(dplyr)) install.packages("dplyr", dependencies = TRUE)
if (!require(tidyr)) install.packages("tidyr", dependencies = TRUE)

library(httr)
library(jsonlite)
library(dplyr)
library(tidyr)

# Definir a URL base da API
base_url <- "http://api.olhovivo.sptrans.com.br/v2.1"

# Função para autenticar na API
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

# Função para buscar a posição dos veículos
buscar_posicao_veiculos <- function() {
  url_posicao <- paste0(base_url, "/Posicao")
  resposta <- GET(url_posicao)
  
  if (status_code(resposta) == 200) {
    dados <- fromJSON(content(resposta, "text", encoding = "ISO-8859-1"))
    
    if (!is.null(dados$l) && length(dados$l) > 0) {
      linhas <- dados$l
      
      # Desmembrar as posições dos veículos em uma tabela detalhada
      posicoes <- linhas %>%
        select(codigo_linha = cl, letreiro_completo = c, terminal_origem = lt0, terminal_destino = lt1, sentido_linha = sl, veiculos = vs) %>%
        unnest(veiculos) %>%
        rename(
          prefixo_veiculo = p,
          acessivel = a,
          horario_captura = ta,
          latitude = py,
          longitude = px
        )
      
      return(posicoes)
    } else {
      cat("Nenhuma posição de veículo encontrada.\n")
      return(NULL)
    }
  } else {
    cat("Falha ao buscar a posição dos veículos.\n")
    return(NULL)
  }
}

# Autenticação utilizando o token fornecido
token <- "5815939c86858c6631dc068008aab013119d4d4b1bc562632001d07b91685f77"
if (autenticar(token)) {
  # Buscar a posição dos veículos
  posicoes <- buscar_posicao_veiculos()
  
  if (!is.null(posicoes)) {
    # Criar a pasta "data" se não existir
    if (!dir.exists("data")) dir.create("data")
    
    # Salvar os dados em um arquivo CSV
    write.csv2(posicoes, file = "data/posicao_veiculos.csv", row.names = FALSE, fileEncoding = "UTF-8")
    
    cat("Arquivo de posição dos veículos gravado com sucesso!\n")
  }
}
