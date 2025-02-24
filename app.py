import requests
from bs4 import BeautifulSoup

url = 'http://www.sptrans.com.br/'  # Coloque o URL correto aqui
response = requests.get(url)
soup = BeautifulSoup(response.content, 'html.parser')

# Encontre os elementos que contêm as informações das linhas
linhas = soup.find_all('div', class_='linha')  # Ajuste conforme a estrutura da página

for linha in linhas:
  print(linha.text)

