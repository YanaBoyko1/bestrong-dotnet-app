FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /usr/app/src

COPY ["DotNetCrudWebApi.sln", "./"]
COPY ["DotNetCrudWebApi/DotNetCrudWebApi.csproj", "DotNetCrudWebApi/"]
RUN dotnet restore "DotNetCrudWebApi.sln"

COPY . .
RUN dotnet build "DotNetCrudWebApi.sln" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "DotNetCrudWebApi/DotNetCrudWebApi.csproj" -c Release -o /app/publish \
    --no-restore \
    /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /usr/app

COPY --from=publish /app/publish .

EXPOSE 8080

ENTRYPOINT ["dotnet", "DotNetCrudWebApi.dll"]