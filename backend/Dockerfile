# Estágio 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copia os arquivos de projeto e restaura dependências (cache de camadas)
COPY BaseApi.sln ./
COPY src/BaseApi.Domain/BaseApi.Domain.csproj src/BaseApi.Domain/
COPY src/BaseApi.Application/BaseApi.Application.csproj src/BaseApi.Application/
COPY src/BaseApi.Infrastructure/BaseApi.Infrastructure.csproj src/BaseApi.Infrastructure/
COPY src/BaseApi.API/BaseApi.API.csproj src/BaseApi.API/
RUN dotnet restore

# Copia o restante do código e faz o publish
COPY . .
RUN dotnet publish src/BaseApi.API/BaseApi.API.csproj -c Release -o /app/publish --no-restore

# Estágio 2: Runtime (imagem menor)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .

# Porta interna do container
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "BaseApi.API.dll"]
