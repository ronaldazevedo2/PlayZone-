services:

  # ============================================================
  # BANCO DE DADOS MySQL 8.0
  # Acesso externo (ex: DBeaver): localhost:5306
  # ============================================================
  mysql:
    image: mysql:8.0
    container_name: baseapi_mysql
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: BaseApi@2024
      MYSQL_DATABASE: baseapi_db
      MYSQL_CHARACTER_SET_SERVER: utf8mb4
      MYSQL_COLLATION_SERVER: utf8mb4_unicode_ci
    ports:
      - "5306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-pBaseApi@2024"]
      interval: 10s
      timeout: 5s
      retries: 5

  # ============================================================
  # API .NET 8
  # Swagger: http://localhost:5000/swagger
  # ============================================================
  api:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: baseapi_api
    restart: unless-stopped
    ports:
      - "5000:8080"
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ConnectionStrings__MySQL=Server=mysql;Port=3306;Database=baseapi_db;User=root;Password=BaseApi@2024;
      - Jwt__ChaveSecreta=BaseApi_ChaveSecreta_MinimoDe32Caracteres_Aqui!
      - Jwt__Emissor=BaseApi
      - Jwt__Audiencia=BaseApiClientes
      - Jwt__ExpiracaoHoras=8
      # Preencha com suas credenciais do Mailtrap:
      - Email__Smtp__Host=sandbox.smtp.mailtrap.io
      - Email__Smtp__Porta=2525
      - Email__Smtp__Usuario=SEU_USUARIO_MAILTRAP
      - Email__Smtp__Senha=SUA_SENHA_MAILTRAP
      - Email__Smtp__RemetenteNome=BaseApi Sistema
      - Email__Smtp__RemetenteEmail=noreply@baseapi.com
    depends_on:
      mysql:
        condition: service_healthy

volumes:
  mysql_data:
