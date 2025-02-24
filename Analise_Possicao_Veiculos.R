# Carregar pacotes necessários
packages <- c("readr", "dplyr", "ggplot2", "lubridate", "sf")
for (p in packages) {
  if (!require(p, character.only = TRUE)) install.packages(p, dependencies = TRUE)
  library(p, character.only = TRUE)
}

# Carregar os dados
posicao_veiculos <- read_csv2("data/posicao_veiculos.csv", locale = locale(encoding = "ISO-8859-1"))

# 1. Visualizar as primeiras linhas
cat("Primeiras 5 linhas do dataset:\n")
print(head(posicao_veiculos, 5))

# 2. Estrutura do dataset
cat("\nEstrutura do dataset:\n")
str(posicao_veiculos)

# 3. Resumo estatístico
cat("\nResumo estatístico:\n")
print(summary(posicao_veiculos))

# 4. Valores ausentes
cat("\nValores ausentes por coluna:\n")
print(colSums(is.na(posicao_veiculos)))

# 5. Distribuição das linhas de ônibus
cat("\nDistribuição das linhas de ônibus:\n")
linhas_contagem <- posicao_veiculos %>%
  count(letreiro_completo, sort = TRUE)

print(head(linhas_contagem, 10))

# 6. Distribuição geográfica
ggplot(posicao_veiculos, aes(x = longitude, y = latitude)) +
  geom_point(alpha = 0.5, color = "blue") +
  labs(
    title = "Distribuição de Posições dos Veículos",
    x = "Longitude",
    y = "Latitude"
  ) +
  theme_minimal()

# 7. Distribuição de veículos acessíveis
veiculos_acessiveis <- posicao_veiculos %>%
  count(acessivel)

cat("\nDistribuição de veículos acessíveis:\n")
print(veiculos_acessiveis)

# Plotagem de veículos acessíveis
ggplot(veiculos_acessiveis, aes(x = acessivel, y = n, fill = acessivel)) +
  geom_bar(stat = "identity") +
  labs(
    title = "Distribuição de Veículos Acessíveis",
    x = "Veículo Acessível",
    y = "Quantidade"
  ) +
  theme_minimal()

# 8. Mapa de calor de posições geográficas
ggplot(posicao_veiculos, aes(x = longitude, y = latitude)) +
  stat_density2d(aes(fill = ..level..), geom = "polygon", alpha = 0.4) +
  scale_fill_viridis_c() +
  labs(
    title = "Mapa de Calor das Posições de Veículos",
    x = "Longitude",
    y = "Latitude"
  ) +
  theme_minimal()

# 9. Top 10 linhas com mais veículos
posicao_veiculos %>%
  count(letreiro_completo, sort = TRUE) %>%
  top_n(10) %>%
  ggplot(aes(x = reorder(letreiro_completo, n), y = n)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Top 10 Linhas com Maior Número de Veículos",
    x = "Letreiro Completo",
    y = "Quantidade de Veículos"
  ) +
  theme_minimal()

# 10. Frequência de veículos por hora
posicao_veiculos <- posicao_veiculos %>%
  mutate(hora_captura = hour(ymd_hms(horario_captura)))

posicao_veiculos %>%
  count(hora_captura) %>%
  ggplot(aes(x = hora_captura, y = n)) +
  geom_line(color = "blue", size = 1.2) +
  geom_point(color = "red", size = 2) +
  labs(
    title = "Frequência de Veículos por Hora",
    x = "Hora do Dia",
    y = "Quantidade de Veículos"
  ) +
  theme_minimal()

# 11. Distribuição por sentido de linha
posicao_veiculos %>%
  count(sentido_linha) %>%
  ggplot(aes(x = as.factor(sentido_linha), y = n, fill = as.factor(sentido_linha))) +
  geom_bar(stat = "identity") +
  labs(
    title = "Distribuição de Veículos por Sentido da Linha",
    x = "Sentido da Linha",
    y = "Quantidade de Veículos",
    fill = "Sentido"
  ) +
  theme_minimal()

  malha_viaria <- st_read("data/malha_viaria.json", quiet = TRUE)

# 12. Visualizar a malha junto com a posição dos veículos
ggplot() +
  geom_sf(data = malha_viaria, color = "grey50", fill = NA, size = 0.5) +  # Adicionar malha viária
  geom_point(data = posicao_veiculos, aes(x = longitude, y = latitude), 
             color = "blue", alpha = 0.6, size = 1.5) +  # Adicionar os pontos de posição dos veículos
  labs(
    title = "Distribuição de Veículos com Malha Viária",
    x = "Longitude",
    y = "Latitude"
  ) +
  theme_minimal()
