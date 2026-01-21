# Env-Inspector Application

Azure環境確認用TypeScriptアプリケーション。

## 概要

このアプリケーションは、Azure上の各種リソースへの接続確認と動作テストを行います。

## 機能

- PostgreSQL接続確認
- Blob Storage接続確認
- Queue Storage接続確認
- Key Vault接続確認
- Azure Functions呼び出し確認
- ホスト情報の出力

## 開発環境

### ローカル開発

```bash
# 依存関係のインストール
npm install

# 開発サーバー起動
npm run dev

# テスト実行
npm test

# ビルド
npm run build
```

### 環境変数

以下の環境変数を設定してください（`.env`ファイルまたはAzure App Settingsで）:

```bash
# PostgreSQL
POSTGRES_HOST=your-postgres-server.postgres.database.azure.com
POSTGRES_DATABASE=appdb
POSTGRES_USER=pgadmin
POSTGRES_PASSWORD=your-password

# Storage Account
STORAGE_ACCOUNT_NAME=yourstorageaccount
STORAGE_CONNECTION_STRING=DefaultEndpointsProtocol=https;...

# Key Vault
KEY_VAULT_URL=https://your-keyvault.vault.azure.net/

# Azure Functions
FUNCTION_APP_URL=https://your-function-app.azurewebsites.net
```

## デプロイ

### Azure Web Appへのデプロイ

```bash
# ZIPパッケージの作成
npm run build
zip -r ../app.zip . -x "node_modules/*" "*.git*"

# Azure CLIでデプロイ
az webapp deployment source config-zip \
  --resource-group <resource-group> \
  --name <webapp-name> \
  --src ../app.zip
```

### Azure Functionsへのデプロイ

```bash
# ZIPパッケージの作成
npm run build
zip -r ../app.zip . -x "node_modules/*" "*.git*"

# Azure CLIでデプロイ
az functionapp deployment source config-zip \
  --resource-group <resource-group> \
  --name <function-app-name> \
  --src ../app.zip
```

## Managed Identity

本番環境では、接続文字列の代わりにManaged Identityを使用することを推奨します。

```typescript
// 例: Key Vaultへのアクセス
import { DefaultAzureCredential } from "@azure/identity";
import { SecretClient } from "@azure/keyvault-secrets";

const credential = new DefaultAzureCredential();
const client = new SecretClient(vaultUrl, credential);
```

## 参考資料

- [Azure SDK for JavaScript](https://github.com/Azure/azure-sdk-for-js)
- [Azure Web Apps](https://learn.microsoft.com/azure/app-service/)
- [Azure Functions](https://learn.microsoft.com/azure/azure-functions/)
