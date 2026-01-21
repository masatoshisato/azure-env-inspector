# Azureインフラストラクチャ デプロイガイド

このプロジェクトは、Bicep と Azure CLI を使用してAzureインフラストラクチャをデプロイします。

## プロジェクト構造

```
azure-env-inspector/ (モノレポ)
├── infra/                    # インフラストラクチャコード (Bicep)
│   ├── main.bicep
│   ├── postgresql.bicep
│   └── ...
├── apps/                     # アプリケーションコード
│   └── env-inspector/        # 環境確認アプリ
│       ├── test.ts
│       └── package.json
└── .github/workflows/        # CI/CD パイプライン
```

## 前提条件

- Azure CLI がインストールされていること
- Azure サブスクリプションへのアクセス権限
- 適切なRBACロール（Contributor以上）

## セットアップ手順

### 1. 環境変数の設定

`.env.sample` をコピーして `.env` ファイルを作成し、必要な値を設定します:

```bash
cp .env.sample .env
```

`.env` ファイルを編集して、以下の値を設定してください:

```bash
AZURE_ENV_NAME=dev
AZURE_LOCATION=japaneast
POSTGRES_ADMIN_LOGIN=pgadmin
POSTGRES_ADMIN_PASSWORD=YourStrongPassword123!
POSTGRES_DATABASE_NAME=appdb
```

### 2. Azure へのログイン

```bash
az login
az account set --subscription <your-subscription-id>
```

### 3. インフラストラクチャのデプロイ

#### 検証（What-If）

本番デプロイ前に、変更内容を確認:

```bash
az deployment sub what-if \
  --location japaneast \
  --template-file infra/main.bicep \
  --parameters infra/main.parameters.bicepparam
```

#### デプロイ実行

```bash
az deployment sub create \
  --name azure-env-inspector-$(date +%Y%m%d-%H%M%S) \
  --location japaneast \
  --template-file infra/main.bicep \
  --parameters infra/main.parameters.bicepparam
```

このコマンドは以下を実行します:
- リソースグループの作成
- PostgreSQL Flexible Server のプロビジョニング
- Key Vault、Storage Account、VNetなどの作成
- ファイアウォールルールの設定

### 4. デプロイ後の確認

デプロイの状態を確認:

```bash
az deployment sub show \
  --name <deployment-name> \
  --query properties.outputs
```

リソースグループ内のリソース一覧:

```bash
az resource list \
  --resource-group <resource-group-name> \
  --output table
```

## リソース構成

### PostgreSQL Flexible Server

- **SKU**: Burstable (Standard_B1ms)
- **バージョン**: PostgreSQL 16
- **ストレージ**: 32 GB (自動拡張有効)
- **バックアップ**: 7日間保持
- **認証**: パスワード認証

### その他のリソース

- Key Vault: シークレット管理
- Storage Account: Blob/Queue Storage
- Virtual Network: VNet統合と閉域網
- Azure Firewall: セキュリティ制御

## カスタマイズ

`infra/postgresql.bicep` および各Bicepファイルでパラメータを変更することで、以下の設定をカスタマイズできます:

- PostgreSQL バージョン (13, 14, 15, 16, 17, 18)
- コンピュートティア (Burstable, GeneralPurpose, MemoryOptimized)
- ストレージサイズ (32GB - 16TB)
- バックアップ保持期間 (7 - 35日)
- 高可用性の有効化
- Geo冗長バックアップ

## アプリケーションのデプロイ

アプリケーションのデプロイについては、各アプリのREADMEを参照してください:

- [apps/env-inspector/README.md](apps/env-inspector/README.md)

## クリーンアップ

リソースグループごと削除:

```bash
az group delete \
  --name <resource-group-name> \
  --yes --no-wait
```

## トラブルシューティング

### デプロイエラーの確認

```bash
az deployment sub show \
  --name <deployment-name> \
  --query properties.error
```

### PostgreSQL接続の確認

```bash
psql "host=<SERVER_FQDN> port=5432 dbname=<DATABASE_NAME> user=<ADMIN_LOGIN> sslmode=require"
```

### Bicep ファイルの検証

```bash
az bicep build --file infra/main.bicep
```

## CI/CD パイプライン

GitHub Actionsを使用した自動デプロイ:

- **インフラ**: `.github/workflows/infra-deploy.yml`
  - `infra/` 配下の変更時にトリガー
  - What-If → 承認 → デプロイ

- **アプリ**: `.github/workflows/app-deploy.yml`
  - `apps/` 配下の変更時にトリガー
  - ビルド → デプロイ

## セキュリティのベストプラクティス

1. **強力なパスワードの使用**: 管理者パスワードは十分に複雑なものを使用
2. **ファイアウォールルールの制限**: 本番環境では特定のIPのみ許可
3. **Managed Identity**: アプリからのアクセスにはManaged Identityを使用
4. **Private Endpoint**: VNet統合でパブリックアクセスを制限
5. **SSL/TLS の強制**: 常に暗号化された接続を使用
6. **Key Vault**: 認証情報はKey Vaultで管理

## 参考資料

- [Azure Database for PostgreSQL - Flexible Server](https://learn.microsoft.com/azure/postgresql/flexible-server/)
- [Azure CLI](https://learn.microsoft.com/cli/azure/)
- [Bicep ドキュメント](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Infrastructure as Code (IaC) ベストプラクティス](https://learn.microsoft.com/azure/architecture/framework/devops/iac)
