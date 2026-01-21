# GitHub Actions Secrets の設定ガイド

CI/CDパイプラインを有効にするために必要なGitHub Secretsの設定方法を説明します。

## 必須のSecrets

### 1. AZURE_CREDENTIALS

Azureサービスプリンシパルの認証情報（JSON形式）

**作成手順:**

```bash
# サービスプリンシパルの作成
az ad sp create-for-rbac \
  --name "github-actions-azure-env-inspector" \
  --role contributor \
  --scopes /subscriptions/<your-subscription-id> \
  --sdk-auth
```

出力されたJSONをそのままGitHub Secretsに設定してください。

**形式:**
```json
{
  "clientId": "<client-id>",
  "clientSecret": "<client-secret>",
  "subscriptionId": "<subscription-id>",
  "tenantId": "<tenant-id>",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

### 2. AZURE_SUBSCRIPTION_ID

AzureサブスクリプションのID

```bash
# 確認方法
az account show --query id -o tsv
```

### 3. RESOURCE_GROUP_NAME

デプロイ先のリソースグループ名（例: `rg-azure-env-inspector-dev`）

## オプションのSecrets（アプリデプロイ用）

### 4. WEBAPP_NAME

Web Appの名前（Web Appを使用する場合）

### 5. FUNCTION_APP_NAME

Function Appの名前（Azure Functionsを使用する場合）

## GitHub Secretsの設定方法

1. GitHubリポジトリを開く
2. `Settings` → `Secrets and variables` → `Actions`
3. `New repository secret` をクリック
4. 各Secretを追加:
   - Name: `AZURE_CREDENTIALS`
   - Value: 上記のJSON
   - `Add secret` をクリック

## 検証

Secretsを設定した後、以下の方法で動作確認できます:

1. `infra/` 配下のファイルを編集してコミット
2. GitHub Actionsタブで `Deploy Infrastructure` ワークフローが実行されることを確認
3. ログを確認して、Azure Login が成功していることを確認

## セキュリティのベストプラクティス

- **最小権限の原則**: サービスプリンシパルには必要最小限のRBACロールのみ付与
- **定期的なローテーション**: クライアントシークレットを定期的に更新
- **環境分離**: dev/staging/prodで別々のサービスプリンシパルを使用
- **監査**: Azure Activity Logでサービスプリンシパルの操作を監視

## トラブルシューティング

### エラー: "The client does not have authorization"

サービスプリンシパルに適切なRBACロールが付与されていない可能性があります。

```bash
# Contributorロールを付与
az role assignment create \
  --assignee <client-id> \
  --role Contributor \
  --scope /subscriptions/<subscription-id>/resourceGroups/<resource-group-name>
```

### エラー: "Invalid credentials"

`AZURE_CREDENTIALS` のJSON形式が正しいか確認してください。特に、改行やスペースが含まれていないか確認します。

## 参考資料

- [GitHub Actions for Azure](https://github.com/Azure/actions)
- [Azure Login Action](https://github.com/Azure/login)
- [Azure CLI - Service Principals](https://learn.microsoft.com/cli/azure/create-an-azure-service-principal-azure-cli)
