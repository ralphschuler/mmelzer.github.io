
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS dotnet-build
WORKDIR /src
COPY ./App ./src
RUN dotnet restore
RUN dotnet build -c Release -o /app/build

FROM dotnet-build AS dotnet-publish
RUN dotnet publish -c Release -o /app/publish

FROM node as node-builder
WORKDIR /node
COPY ./App/ClientApp /node
RUN npm install
RUN npm run build

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
RUN mkdir /app/wwwroot
COPY --from=dotnet-publish /app/publish /app
COPY --from=node-builder /node/build /app/wwwroot
ENTRYPOINT ["dotnet", "App.dll"]