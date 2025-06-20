# Estágio 1: Build da aplicação com Maven
# Usaremos uma imagem oficial do Maven que já tem JDK.
# Escolha a versão do JDK compatível com seu projeto (ex: 17, 11).
# 'AS builder' nomeia este estágio para que possamos copiar artefatos dele depois.
FROM maven:3.9-eclipse-temurin-17 AS builder

# Define o diretório de trabalho dentro do container
WORKDIR /app

# Copia o pom.xml primeiro para aproveitar o cache de camadas do Docker.
# Se o pom.xml não mudar, as dependências não precisarão ser baixadas novamente.
COPY pom.xml .

# Baixa as dependências (opcional, mas pode acelerar builds subsequentes se o pom.xml não mudar)
# RUN mvn dependency:go-offline

# Copia todo o resto do código do projeto
COPY src ./src

# Roda o comando do Maven para limpar, compilar e empacotar a aplicação, pulando os testes.
# O resultado será um arquivo .jar na pasta /app/target/
RUN mvn clean package -DskipTests

# Estágio 2: Imagem final de execução
# Usaremos uma imagem JRE (Java Runtime Environment) que é menor que um JDK completo.
# Escolha a versão do JRE compatível.
FROM eclipse-temurin:17-jre-jammy

# Define o diretório de trabalho
WORKDIR /app

# Copia o arquivo JAR construído no estágio 'builder' (da pasta /app/target/)
# para o diretório de trabalho atual (/app/) da imagem final, nomeando-o como app.jar.
# Ajuste '*.jar' se seu pom.xml gerar um JAR com um nome muito específico e previsível,
# ou se gerar múltiplos JARs (o que é incomum para uma aplicação Spring Boot simples).
COPY --from=builder /app/target/*.jar app.jar

# Expõe a porta em que a aplicação Spring Boot roda (padrão é 8080)
# Isso é mais uma documentação para o Docker e para o usuário.
# A plataforma de hospedagem (Render) geralmente lida com o mapeamento de portas.
EXPOSE 8080

# Comando que será executado quando o container iniciar.
# Ele roda a aplicação Java a partir do app.jar.
ENTRYPOINT ["java", "-jar", "app.jar"]