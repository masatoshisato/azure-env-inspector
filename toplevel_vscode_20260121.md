# トップレベルファイル & .vscode/ 詳細説明書

作成日: 2026年1月21日

## トップレベルファイル一覧

```
azure-env-inspector/
├── .env.sample           # 環境変数のテンプレート
├── .vscode/              # VS Code設定フォルダー
│   └── launch.json       # デバッグ設定
├── DEPLOYMENT.md         # デプロイガイド
└── README.md             # プロジェクト概要
```

---

## 1. `.env.sample`

### 目的
環境変数のテンプレートファイル

### 使用方法
```bash
# .envファイルにコピー
cp .env.sample .env

# .envファイルを編集して実際の値を設定
vim .env
```

### 内容の詳細説明

```dotenv
# ========================================
# Environment variables for Azure deployment
# ========================================
# Copy this file to .env and fill in the values
# .envファイルは.gitignoreに含まれるため、Gitにコミットされません

# ========================================
# Azure環境設定
# ========================================

# Azure environment name (e.g., dev, test, prod)
AZURE_ENV_NAME=dev
# 説明: 環境名（開発、テスト、本番を区別）
# 用途: リソース名の生成、タグ付けに使用
# 例:
#   - dev: 開発環境
#   - staging: ステージング環境
#   - prod: 本番環境

# Azure region for deployment
AZURE_LOCATION=japaneast
# 説明: デプロイ先のAzureリージョン
# 用途: リソースの配置場所
# 選択肢:
#   - japaneast: 東日本
#   - japanwest: 西日本
#   - eastus: 米国東部
#   - westeurope: 西ヨーロッパ
# 注意: リージョンによってコストとレイテンシが異なる

# ========================================
# PostgreSQL設定
# ========================================

# PostgreSQL administrator login
POSTGRES_ADMIN_LOGIN=pgadmin
# 説明: PostgreSQL管理者のログイン名
# 制約:
#   - 英数字とハイフンのみ
#   - 予約語は使用不可（postgres, admin, root など）
#   - 最大63文字

# PostgreSQL administrator password (REQUIRED)
# Please set a strong password with at least 8 characters
POSTGRES_ADMIN_PASSWORD=
# 説明: PostgreSQL管理者のパスワード（必須）
# 要件:
#   - 最低8文字
#   - 大文字、小文字、数字、記号を含むことを推奨
#   - 例: MyStr0ng!P@ssw0rd
# 注意: 空のままデプロイするとエラーになります

# PostgreSQL database name
POSTGRES_DATABASE_NAME=appdb
# 説明: 作成するデータベース名
# デフォルト: appdb
# 用途: アプリケーションが接続するデータベース

# ========================================
# Entra ID認証設定（オプション）
# ========================================

# Enable Entra ID authentication (Enabled or Disabled)
ENTRA_ID_AUTH_ENABLED=Enabled
# 説明: Azure Entra ID（旧Azure AD）認証の有効化
# オプション:
#   - Enabled: Entra ID認証を使用（推奨）
#   - Disabled: パスワード認証のみ
# メリット（Enabled時）:
#   - パスワードレス認証
#   - Managed Identityとの統合
#   - Azure RBACによる細かいアクセス制御

# Entra ID administrator object ID
# You can get this by running: az ad user show --id <email> --query id -o tsv
ENTRA_ID_ADMIN_OBJECT_ID=
# 説明: Entra ID管理者のオブジェクトID（UUID）
# 取得方法:
#   az ad user show --id user@example.com --query id -o tsv
# 例: 12345678-1234-1234-1234-123456789abc
# 用途: PostgreSQLのEntra ID管理者として設定
# 注意: ENTRA_ID_AUTH_ENABLED=Enabled の場合は必須

# Entra ID administrator principal name (email address)
ENTRA_ID_ADMIN_PRINCIPAL_NAME=
# 説明: Entra ID管理者のプリンシパル名（メールアドレス）
# 例: user@example.com
# 用途: PostgreSQLのEntra ID管理者として設定
# 注意: ENTRA_ID_AUTH_ENABLED=Enabled の場合は必須
```

---

### セキュリティのベストプラクティス

#### 1. `.env`ファイルの管理

```bash
# .gitignoreに追加されていることを確認
cat .gitignore | grep .env
# 出力: .env

# 誤ってコミットしていないか確認
git status
# .envが表示されないことを確認
```

#### 2. パスワードの要件

```
強力なパスワードの例:
✅ MyStr0ng!P@ssw0rd
✅ Az_ure2026#Secure
✅ P@ssw0rd!Complex123

弱いパスワードの例:
❌ password
❌ 12345678
❌ admin123
```

#### 3. 本番環境での管理

**推奨方法**:
- Azure Key Vaultにシークレットを保存
- GitHub Secretsでパスワードを管理
- 環境変数を直接Azureリソースに設定

**例: Azure Key Vaultの使用**
```bash
# Key Vaultにシークレットを保存
az keyvault secret set \
  --vault-name my-keyvault \
  --name postgres-admin-password \
  --value "MyStr0ng!P@ssw0rd"

# Bicepでシークレットを参照
resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: 'my-keyvault'
}

param postgresPassword string = kv.getSecret('postgres-admin-password')
```

---

## 2. `.vscode/launch.json`

### 目的
VS Codeデバッガーの設定ファイル

### 内容の詳細説明

```jsonc
{
  "version": "0.2.0",  // launch.jsonのスキーマバージョン
  
  // ========================================
  // デバッグ構成の配列
  // ========================================
  "configurations": [
    // --- 構成1: Debug test.ts ---
    {
      "type": "node",                       // デバッガーの種類: Node.js
      "request": "launch",                  // 起動モード: launch（新規起動）
      "name": "Debug test.ts",              // VS Code UIに表示される名前
      "skipFiles": ["<node_internals>/**"], // スキップするファイル（Node.js内部）
      
      // デバッグ対象のプログラム
      "program": "${workspaceFolder}/apps/env-inspector/test.ts",
      
      // TypeScript実行ツール（tsx）のパス
      "runtimeExecutable": "${workspaceFolder}/apps/env-inspector/node_modules/.bin/tsx",
      
      // 作業ディレクトリ
      "cwd": "${workspaceFolder}/apps/env-inspector",
      
      // 出力先: 統合ターミナル
      "console": "integratedTerminal",
      
      // デバッグコンソールを開かない
      "internalConsoleOptions": "neverOpen"
    },
    
    // --- 構成2: Run test.ts ---
    {
      "type": "node",
      "request": "launch",
      "name": "Run test.ts",                // 別の実行構成（グローバルtsx使用）
      "skipFiles": ["<node_internals>/**"],
      "program": "${workspaceFolder}/apps/env-inspector/test.ts",
      
      // グローバルにインストールされたtsxを使用
      "runtimeExecutable": "tsx",
      
      "cwd": "${workspaceFolder}/apps/env-inspector",
      "console": "integratedTerminal"
    }
  ]
}
```

---

### 各プロパティの詳細

#### 1. `type`
- **値**: `"node"`, `"pwa-node"`, `"chrome"`, `"edge"` など
- **説明**: デバッガーの種類
- **Node.js**: `"node"` を使用

#### 2. `request`
- **`launch`**: 新しいプロセスを起動してデバッグ
- **`attach`**: 既存のプロセスにアタッチ

#### 3. `skipFiles`
- **目的**: ステップ実行時にスキップするファイルを指定
- **`<node_internals>/**`**: Node.js内部のファイルをスキップ
- **例**: `["node_modules/**"]` で依存パッケージをスキップ

#### 4. `${workspaceFolder}`
- **説明**: ワークスペースのルートディレクトリ
- **値**: `/workspaces/azure-env-inspector`

#### 5. `console`
- **`integratedTerminal`**: VS Code統合ターミナルに出力（推奨）
- **`internalConsole`**: デバッグコンソールに出力
- **`externalTerminal`**: 外部ターミナルを起動

---

### 使用方法

#### ステップ1: デバッグ構成を選択

1. **デバッグパネルを開く**
   - サイドバーの「実行とデバッグ」アイコン（▶️🐛）
   - または `Ctrl+Shift+D`

2. **ドロップダウンから選択**
   - 「Debug test.ts」または「Run test.ts」

#### ステップ2: ブレークポイントを設定

```typescript
// test.ts
const server = http.createServer((req, res) => {
  res.statusCode = 200;            // ← ここにブレークポイント（行番号をクリック）
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello, World!\n');
});
```

#### ステップ3: デバッグ開始

- **F5**キーを押す
- または緑の▶️ボタンをクリック

#### ステップ4: デバッグ操作

| キー | 操作 | 説明 |
|------|------|------|
| **F5** | 続行 | 次のブレークポイントまで実行 |
| **F10** | ステップオーバー | 現在の行を実行して次の行へ |
| **F11** | ステップイン | 関数内に入る |
| **Shift+F11** | ステップアウト | 関数から抜ける |
| **Shift+F5** | 停止 | デバッグを終了 |

#### ステップ5: 変数の確認

- **変数パネル**: 左サイドバーに表示
- **ウォッチ式**: 監視したい式を追加
- **ホバー**: コード上でマウスオーバー

---

### 高度な設定例

#### 環境変数の設定

```jsonc
{
  "type": "node",
  "request": "launch",
  "name": "Debug with ENV",
  "program": "${workspaceFolder}/apps/env-inspector/test.ts",
  "runtimeExecutable": "tsx",
  "env": {
    "PORT": "3001",
    "NODE_ENV": "development",
    "DEBUG": "*"
  }
}
```

#### コマンドライン引数の追加

```jsonc
{
  "type": "node",
  "request": "launch",
  "name": "Debug with Args",
  "program": "${workspaceFolder}/apps/env-inspector/test.ts",
  "runtimeExecutable": "tsx",
  "args": ["--verbose", "--config", "dev.json"]
}
```

#### ソースマップの有効化

```jsonc
{
  "type": "node",
  "request": "launch",
  "name": "Debug with SourceMap",
  "program": "${workspaceFolder}/apps/env-inspector/test.ts",
  "runtimeExecutable": "tsx",
  "sourceMaps": true,
  "outFiles": ["${workspaceFolder}/dist/**/*.js"]
}
```

---

## まとめ

### `.env.sample`
- **目的**: 環境変数のテンプレート
- **使用方法**: `.env`にコピーして実際の値を設定
- **セキュリティ**: `.env`はGitにコミットしない
- **必須項目**: `POSTGRES_ADMIN_PASSWORD`

### `.vscode/launch.json`
- **目的**: VS Codeデバッガーの設定
- **構成**: 2つのデバッグ構成（ローカルtsx、グローバルtsx）
- **使用方法**: F5でデバッグ開始
- **ブレークポイント**: 行番号をクリックして設定
- **GitHub Codespaces**: そのまま使用可能

### ベストプラクティス
1. ✅ `.env.sample`は常に最新に保つ
2. ✅ `.env`は絶対にコミットしない
3. ✅ パスワードは強力なものを使用
4. ✅ 本番環境ではKey Vaultを使用
5. ✅ デバッグ構成は用途に応じて追加
6. ✅ ブレークポイントを活用して効率的にデバッグ
