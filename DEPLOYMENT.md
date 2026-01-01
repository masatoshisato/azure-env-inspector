# Azure Database for PostgreSQL デプロイガイド

このプロジェクトは、Azure Developer CLI (azd) と Bicep を使用して Azure Database for PostgreSQL Flexible Server をデプロイします。

## 前提条件

- Azure CLI がインストールされていること
- Azure Developer CLI (azd) がインストールされていること
- Azure サブスクリプションへのアクセス権限

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
azd auth login
az login
```

### 3. デプロイ

初回デプロイ:

```bash
azd up
```

このコマンドは以下を実行します:
- リソースグループの作成
- PostgreSQL Flexible Server のプロビジョニング
- データベースの作成
- ファイアウォールルールの設定

### 4. デプロイ後の確認

デプロイが完了したら、以下のコマンドで出力値を確認できます:

```bash
azd env get-values
```

## リソース構成

### PostgreSQL Flexible Server

- **SKU**: Burstable (Standard_B1ms)
- **バージョン**: PostgreSQL 16
- **ストレージ**: 32 GB (自動拡張有効)
- **バックアップ**: 7日間保持
- **認証**: パスワード認証

### ファイアウォール

- Azure サービスからのアクセスを許可

## カスタマイズ

`infra/postgresql.bicep` ファイルでパラメータを変更することで、以下の設定をカスタマイズできます:

- PostgreSQL バージョン (13, 14, 15, 16, 17, 18)
- コンピュートティア (Burstable, GeneralPurpose, MemoryOptimized)
- ストレージサイズ (32GB - 16TB)
- バックアップ保持期間 (7 - 35日)
- 高可用性の有効化
- Geo冗長バックアップ

## クリーンアップ

すべてのリソースを削除する場合:

```bash
azd down
```

## トラブルシューティング

### 接続の確認

PostgreSQL サーバーへの接続を確認:

```bash
psql "host=<SERVER_FQDN> port=5432 dbname=<DATABASE_NAME> user=<ADMIN_LOGIN> sslmode=require"
```

### ログの確認

Azure Portal でサーバーログを確認できます。

## セキュリティのベストプラクティス

1. **強力なパスワードの使用**: 管理者パスワードは十分に複雑なものを使用してください
2. **ファイアウォールルールの制限**: 本番環境では、特定の IP アドレスのみを許可するようにしてください
3. **Private Endpoint の使用**: VNet 統合を検討してください
4. **SSL/TLS の強制**: 常に暗号化された接続を使用してください

## 参考資料

- [Azure Database for PostgreSQL - Flexible Server](https://learn.microsoft.com/azure/postgresql/flexible-server/)
- [Azure Developer CLI](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- [Bicep ドキュメント](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
