# .devcontainer/ フォルダー詳細説明書

作成日: 2026年1月21日

## フォルダーの目的

`.devcontainer/` は、開発環境をコードで定義するフォルダーです。Dev Container（Development Container）の設定を記述し、GitHub CodespacesやローカルのVS Codeで一貫した開発環境を提供します。

---

## Dev Containerとは

### 概要

Dev Containerは、開発に必要なツール・ランタイム・拡張機能をDockerコンテナとして定義する仕組みです。

**メリット**:
- ✅ チーム全員が同じ環境で開発
- ✅ 環境構築の自動化（ボタン1つで完了）
- ✅ ローカルマシンを汚さない
- ✅ クラウド開発（GitHub Codespaces）対応

**仕組み**:
```
devcontainer.json
    ↓
Dockerイメージのダウンロード・ビルド
    ↓
コンテナの起動
    ↓
VS Code Serverのインストール
    ↓
拡張機能のインストール
    ↓
開発開始！
```

---

## ファイル: `devcontainer.json`

### 目的
開発コンテナの設定ファイル

### 内容の詳細説明

```jsonc
{
    // ========================================
    // ベースイメージ
    // ========================================
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    // Microsoft公式のDev Container用Ubuntuイメージ
    // - Ubuntu 24.04 LTS
    // - 基本的な開発ツール（git, curl, wgetなど）が pre-installed
    
    // ========================================
    // 機能（Features）
    // ========================================
    "features": {
        // --- Azure CLI ---
        // for Azure CLI
        "ghcr.io/devcontainers/features/azure-cli:1": {},
        // 説明: Azureリソースの管理・デプロイに使用
        // バージョン: 最新（自動更新）
        // コマンド: az
        // 用途: 
        //   - Bicepファイルのデプロイ
        //   - Azureリソースの確認・操作
        //   - サービスプリンシパルの管理
        
        // --- Node.js ---
        // for Node.js
        "ghcr.io/devcontainers/features/node:1": {
            "version": "20"
        },
        // 説明: Node.jsランタイムとnpm
        // バージョン: 20.x（LTS）
        // コマンド: node, npm, npx
        // 用途:
        //   - TypeScriptアプリケーションの実行
        //   - 依存パッケージの管理
        //   - tsxによるTypeScript直接実行
        
        // --- Azure Functions Core Tools ---
        // for azure functions tools.
        "ghcr.io/jlaundry/devcontainer-features/azure-functions-core-tools:1": {
            "version": "4"
        },
        // 説明: Azure Functionsのローカル開発ツール
        // バージョン: 4.x
        // コマンド: func
        // 用途:
        //   - Azure Functionsのローカル実行
        //   - 新しいFunctionプロジェクトの作成
        //   - Functionsのデプロイ
        // 注意: 将来的にFunctionsを開発する際に使用
        
        // --- Docker ---
        // for Docker (Docker outside of Docker for GitHub Codespaces)
        "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {}
        // 説明: ホストのDockerデーモンを使用
        // 方式: Docker outside of Docker (DooD)
        // コマンド: docker, docker-compose
        // 用途:
        //   - コンテナイメージのビルド
        //   - ローカルでのコンテナテスト
        //   - GitHub Codespacesで動作
        // 技術詳細:
        //   - コンテナ内からホストのDocker daemonにアクセス
        //   - /var/run/docker.sockをマウント
        //   - Docker in Docker (DinD) より軽量
    },
    
    // ========================================
    // ポストクリエイトコマンド
    // ========================================
    "postCreateCommand": "az bicep install",
    // 説明: コンテナ作成後に自動実行されるコマンド
    // 実行内容: Bicep CLIのインストール
    // タイミング: 初回起動時のみ（コンテナ再起動では実行されない）
    // 目的: Bicepファイルのビルド・デプロイを可能にする
    
    // ========================================
    // カスタマイズ
    // ========================================
    "customizations": {
        "vscode": {
            // VS Code拡張機能の自動インストール
            "extensions": [
                "github.copilot",                            // GitHub Copilot AI code completion.
                "ms-azuretools.vscode-azurefunctions",       // Azure Functions support.
                "ms-azuretools.vscode-azureappservice",      // Azure App Service support.
                "ms-vscode.azurecli",                        // Az command support.
                "ms-vscode.vscode-bicep"                     // Bicep language support.
            ]
        }
    }
}
```

---

## 各機能の詳細

### 1. Azure CLI (`az`)

**インストール内容**:
- Azure CLI 本体（`az`コマンド）
- Bicep CLI（`az bicep`コマンド）

**主要コマンド**:
```bash
# Azureへのログイン
az login

# サブスクリプション一覧
az account list -o table

# リソースグループ一覧
az group list -o table

# Bicepファイルのデプロイ
az deployment sub create \
  --template-file infra/main.bicep \
  --parameters infra/main.parameters.bicepparam
```

**確認方法**:
```bash
az version
# 出力: "azure-cli": "2.81.0"
```

---

### 2. Node.js & npm

**インストール内容**:
- Node.js 20.x（LTS）
- npm（Node Package Manager）
- npx（パッケージ実行ツール）

**主要コマンド**:
```bash
# Node.jsバージョン確認
node -v
# 出力: v20.19.6

# npmバージョン確認
npm -v
# 出力: 10.8.2

# パッケージのインストール
npm install

# アプリケーションの実行
npm start
```

**用途**:
- TypeScriptアプリケーションの実行（`tsx`経由）
- 依存パッケージの管理
- ビルドスクリプトの実行

---

### 3. Azure Functions Core Tools (`func`)

**インストール内容**:
- Azure Functions Core Tools v4
- ローカル開発サーバー
- テンプレートジェネレーター

**主要コマンド**:
```bash
# バージョン確認
func --version
# 出力: 4.x.x

# 新しいFunctionプロジェクトの作成
func init MyFunctionApp --typescript

# ローカル実行
func start

# Azureへのデプロイ
func azure functionapp publish <app-name>
```

**用途**（将来的に）:
- HTTP TriggerによるAPI実装
- Timer Triggerによる定期実行
- Queue Triggerによる非同期処理

---

### 4. Docker

**インストール内容**:
- Docker CLI（`docker`コマンド）
- Docker Compose CLI（`docker-compose`コマンド）

**技術詳細: Docker outside of Docker (DooD)**

```
┌─────────────────────────────────┐
│ Host Machine                    │
│                                 │
│  Docker Daemon ◄────────┐       │
│     │                   │       │
│     ├─ Container 1      │       │
│     ├─ Container 2      │       │
│     └─ Dev Container    │       │
│          │              │       │
│          └──────────────┘       │
│           /var/run/docker.sock  │
└─────────────────────────────────┘
```

**特徴**:
- ホストのDockerデーモンを共有
- コンテナ内からDockerコマンドを実行可能
- イメージビルドやコンテナ起動が可能
- GitHub Codespacesで利用可能

**主要コマンド**:
```bash
# イメージ一覧
docker images

# コンテナ一覧
docker ps -a

# イメージのビルド
docker build -t myapp:latest .

# コンテナの起動
docker run -p 3000:3000 myapp:latest
```

**用途**:
- アプリケーションのコンテナ化
- ローカルでのコンテナテスト
- Azure Container Appsへのデプロイ前検証

---

## VS Code拡張機能の詳細

### 1. GitHub Copilot (`github.copilot`)
**機能**: AI コード補完
**用途**: コーディング効率の向上

### 2. Azure Functions (`ms-azuretools.vscode-azurefunctions`)
**機能**: Azure Functions開発支援
**主要機能**:
- プロジェクト作成ウィザード
- ローカルデバッグ
- Azureへのデプロイ
- ログストリーミング

### 3. Azure App Service (`ms-azuretools.vscode-azureappservice`)
**機能**: Azure App Service管理
**主要機能**:
- Web Appの作成・削除
- デプロイ（ZIP、Git、FTP）
- ログストリーミング
- 環境変数の管理

### 4. Azure CLI Tools (`ms-vscode.azurecli`)
**機能**: Azure CLIコマンドの補完とシンタックスハイライト
**主要機能**:
- `.azcli`ファイルのサポート
- コマンドの実行（Ctrl+Enter）
- インテリセンス

### 5. Bicep (`ms-vscode.vscode-bicep`)
**機能**: Bicep言語のサポート
**主要機能**:
- シンタックスハイライト
- インテリセンス（自動補完）
- エラー検出（リアルタイム）
- リソースビジュアライザー
- 定義へジャンプ

---

## 開発環境の起動方法

### GitHub Codespacesの場合

1. **GitHubリポジトリを開く**
   ```
   https://github.com/masatoshisato/azure-env-inspector
   ```

2. **「Code」ボタンをクリック**

3. **「Codespaces」タブを選択**

4. **「Create codespace on main」をクリック**

5. **自動的に実行される処理**
   ```
   1. devcontainer.jsonの読み込み
   2. Dockerイメージのダウンロード
   3. コンテナの起動
   4. VS Code Serverのインストール
   5. 拡張機能のインストール
   6. postCreateCommandの実行（az bicep install）
   7. VS Code UIの表示
   ```

6. **開発開始**
   - 2〜3分で完全な開発環境が利用可能

---

### ローカルVS Codeの場合

#### 前提条件
- Docker Desktopのインストール
- VS Code Dev Containers拡張機能のインストール

#### 手順

1. **リポジトリをクローン**
   ```bash
   git clone https://github.com/masatoshisato/azure-env-inspector.git
   cd azure-env-inspector
   ```

2. **VS Codeで開く**
   ```bash
   code .
   ```

3. **プロンプトに従う**
   ```
   「Reopen in Container」をクリック
   ```
   または
   ```
   Ctrl+Shift+P → Dev Containers: Reopen in Container
   ```

4. **自動的に実行される処理**
   ```
   1. devcontainer.jsonの読み込み
   2. Dockerイメージのpull/build
   3. コンテナの起動
   4. VS Code Serverのインストール
   5. 拡張機能のインストール
   6. postCreateCommandの実行
   ```

5. **開発開始**
   - 初回は5〜10分、2回目以降は数秒で起動

---

## トラブルシューティング

### エラー: `Docker is not running`

**原因**: Docker Desktopが起動していない

**解決方法**:
```
1. Docker Desktopを起動
2. VS Codeでリロード
```

---

### エラー: `Failed to install Bicep`

**原因**: postCreateCommandの失敗

**解決方法**:
```bash
# 手動でインストール
az bicep install

# バージョン確認
az bicep version
```

---

### 拡張機能がインストールされない

**原因**: ネットワークエラーまたはマーケットプレイスの問題

**解決方法**:
```
1. VS Codeの拡張機能パネルを開く
2. 手動で検索してインストール
   - GitHub Copilot
   - Azure Functions
   - Bicep
```

---

### コンテナが起動しない

**原因**: devcontainer.jsonの構文エラー

**解決方法**:
```bash
# JSONの検��
cat .devcontainer/devcontainer.json | jq .

# エラーメッセージを確認
# VS Code: View → Output → Dev Containers
```

---

## カスタマイズ例

### ポート転送の追加

```jsonc
{
    "forwardPorts": [3000, 5432],
    "portsAttributes": {
        "3000": {
            "label": "Application",
            "onAutoForward": "notify"
        },
        "5432": {
            "label": "PostgreSQL",
            "onAutoForward": "silent"
        }
    }
}
```

---

### 環境変数の設定

```jsonc
{
    "containerEnv": {
        "AZURE_ENV_NAME": "dev",
        "NODE_ENV": "development"
    }
}
```

---

### 追加の拡張機能

```jsonc
{
    "customizations": {
        "vscode": {
            "extensions": [
                "github.copilot",
                "dbaeumer.vscode-eslint",      // ESLint
                "esbenp.prettier-vscode",      // Prettier
                "eamodio.gitlens"              // GitLens
            ]
        }
    }
}
```

---

## まとめ

- **Dev Container**: 開発環境をコード化（IaC for Development）
- **一貫性**: チーム全員が同じ環境で開発
- **自動化**: ボタン1つで完全な環境が起動
- **ツール**: Azure CLI、Node.js、Docker、Azure Functions Core Tools
- **拡張機能**: Bicep、Azure、GitHub Copilot
- **プラットフォーム**: GitHub Codespaces、ローカルVS Code
