# Azure-Env-Inspector

## プロジェクト概要

Azure環境の動作確認・構成可視化ツールのサンプルプロジェクト。
Web App, Static Web Apps、Functions App、Key Vault、Blob Storage、Queue Storage、PostgreSQLが正常稼働していることを複数のエンドポイントで確認します。

このプロジェクトは**モノレポ構成**で、インフラストラクチャコードとアプリケーションコードを統合管理しています。

## プロジェクト構造

```
azure-env-inspector/
├── infra/                      # インフラストラクチャコード (Bicep)
│   ├── main.bicep              # メインテンプレート
│   ├── postgresql.bicep        # PostgreSQL Flexible Server
│   ├── rg.bicep                # リソースグループ
│   └── *.bicepparam            # パラメータファイル
│
├── apps/                       # アプリケーションコード
│   └── env-inspector/          # 環境確認アプリ
│       ├── test.ts
│       └── package.json
│
├── .github/workflows/          # CI/CDパイプライン
│   ├── infra-deploy.yml        # インフラデプロイ
│   └── app-deploy.yml          # アプリデプロイ
│
├── .devcontainer/              # 開発環境定義
│   └── devcontainer.json
│
├── DEPLOYMENT.md               # デプロイガイド
└── README.md                   # このファイル
```

## アプリケーションの役割

**PaaS確認**
* Static Web Apps → Web App → Queue → Function App → Key Vault
* Static Web Apps → Web App → Blob Storage
* Static Web Apps → Web App → Key Vault
* Static Web Apps → Web App → Function App

**VNet閉域網確認**
* Static Web Apps → (Hub) Azure Firewall → (Spoke) Web App → 同上

**出力情報**
- ホスト名
- ランタイム情報
- インスタンスID
- スケールアウト確認
- PostgreSQL接続確認
- Blob Storage接続確認
- Key Vault接続確認

## 技術スタック

- **言語・ランタイム**
  - Web App: Node.js (TypeScript)
  - Functions: Node.js (TypeScript)
- **インフラストラクチャ**
  - Bicep (Infrastructure as Code)
  - Azure CLI
- **コード管理**
  - GitHub (モノレポ)
- **開発環境**
  - GitHub Codespaces
  - VS Code (Web/Local)
- **CI/CD**
  - GitHub Actions (パスフィルター対応)

## クイックスタート

### 前提条件

- Azure CLI がインストールされていること
- Azure サブスクリプションへのアクセス権限
- GitHub Codespaces または Docker環境（ローカル開発の場合）

### 1. リポジトリのクローン

```bash
git clone https://github.com/masatoshisato/azure-env-inspector.git
cd azure-env-inspector
```

### 2. 開発環境のセットアップ

**GitHub Codespacesの場合:**
- GitHubでリポジトリを開き、「Code」→「Create codespace on main」

**ローカル開発の場合:**
```bash
# VS Codeでリポジトリを開く
code .
# Dev Containerで再度開く（拡張機能のプロンプトに従う）
```

### 3. インフラストラクチャのデプロイ

詳細は[DEPLOYMENT.md](DEPLOYMENT.md)を参照してください。

```bash
# Azure ログイン
az login

# デプロイ前の検証（What-If）
az deployment sub what-if \
  --location japaneast \
  --template-file infra/main.bicep \
  --parameters infra/main.parameters.bicepparam

# デプロイ実行
az deployment sub create \
  --name azure-env-inspector-$(date +%Y%m%d-%H%M%S) \
  --location japaneast \
  --template-file infra/main.bicep \
  --parameters infra/main.parameters.bicepparam
```

### 4. アプリケーションのデプロイ

```bash
cd apps/env-inspector
npm install
npm run build  # （ビルドスクリプトがある場合）

# Azure Web App / Functionsへのデプロイ
# （具体的なコマンドはデプロイ先に依存）
```

## CI/CD パイプライン

### インフラストラクチャのデプロイ

- **トリガー**: `infra/` 配下のファイル変更時
- **処理**:
  1. Bicep テンプレートの検証
  2. What-If 分析
  3. Azure へのデプロイ

### アプリケーションのデプロイ

- **トリガー**: `apps/env-inspector/` 配下のファイル変更時
- **処理**:
  1. 依存関係のインストール
  2. ビルド・テスト
  3. Azure へのデプロイ

### GitHub Secrets の設定

CI/CDを有効にするには、以下のSecretsを設定してください:

```
AZURE_CREDENTIALS           # Azureサービスプリンシパル認証情報
AZURE_SUBSCRIPTION_ID       # AzureサブスクリプションID
RESOURCE_GROUP_NAME         # リソースグループ名
WEBAPP_NAME                 # Web App名（オプション）
FUNCTION_APP_NAME           # Function App名（オプション）
```

## モノレポの利点

このプロジェクトは、インフラとアプリを1つのリポジトリで管理する**モノレポ構成**を採用しています。

**メリット:**
- 📁 統合管理: すべてのコードが1箇所に
- 🚀 柔軟なデプロイ: インフラのみ/アプリのみを独立してデプロイ可能
- 🔄 一貫性: インフラとアプリのバージョンが連携
- 🛠️ 開発効率: 1つの開発環境ですべてを扱える

**GitHub Actionsのパスフィルター:**
```yaml
# インフラのみデプロイ
on:
  push:
    paths:
      - 'infra/**'

# アプリのみデプロイ
on:
  push:
    paths:
      - 'apps/env-inspector/**'
```

## GitHub Codespaces の仕組み

Github Codespacesは「マネージドなDocker環境」＋ VS Code Webを提供するサービスと捉えることができる。

## Github Codespaces起動時の挙動

まず、Github Codespacesがリポジトリからdevcontainer.jsonを読み、Dockerイメージを作成してからDockerコンテナを起動してVS Codeが起動される。

devcontainer.jsonはVS Codeの設定ファイルではなく、開発コンテナのための共通規格。

1. Github CodespacesがGithubリポジトリを読む
2. .devcontainer/devcontainer.jsonを探し、見つかったらCodespaces起動前に読む
3. そこに書かれたimage/featureをもとにDockerコンテナを作る
4. Docker container起動
5. VS Code Server 起動（コンテナ内）
6. BrowserにVS Code UI表示

## ローカルVS Code + Dockerの場合

Github Codespacesと同じ処理をローカルVS Codeが実行しているだけ。

1. VS Codeにdevcontainer拡張機能をインストール
2. VS Code起動時に拡張機能がdevcontainer.jsonを探し、あれば「コンテナで開きますか？」が聞かれる。
3. 拡張機能がdevcontainer.jsonを読み、以下を実行
    1. 指定されているイメージをdocker pullでダウンロード
    2. docker build
    3. docker runでコンテナ実行
4. VS Code Serverがインストールされる
5. ローカルのVS Codeがサーバーと接続され、コーディングが開始できる。

# Github Codespaces環境

開発環境をコードで定義したもの。

IaCの開発環境版。

これを共有すると、誰が使っても同じ環境になる。

- image
    - Ubuntuイメージ
- feature
    - azure cli
    - node runtime
    - azure functions core tools
- extensions
    - vscode-azurefunctions
    - vscode-azureappservice
    - github copilot
    - azure cli
    - vscode-bicep

```
// devcontainer.json
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/devcontainers/features/azure-cli:1": {},
        "ghcr.io/devcontainers/features/node:1": {
            "version": "20"
        },
	      "ghcr.io/jlaundry/devcontainer-features/azure-functions-core-tools:1": {},
        "ghcr.io/azure/"
    },
    "postCreateCommand": "az bicep install",
    "customizations": {
        "vscode": {
            "extensions": [
                "github.copilot", // GitHub Copilot AI code completion.
                "ms-azuretools.vscode-azurefunctions", // Azure Functions support.
                "ms-azuretools.vscode-azureappservice", // Azure App Service support.
                "ms-vscode.azurecli", // Az command support.
                "ms-vscode.vscode-bicep" // Bicep language support.
            ]
        }
    }
}
```

自分の場合は、これにプラスして [vscodevim](https://github.com/jlaundry/devcontainer-features/tree/main/src/azure-functions-core-tools) をブラウザインストール。


## devcontainer.jsonの環境確認方法

確認手順は以下の通り。

1. OS/ Container
2. CLIツール
3. VS Code拡張機能
4. Azure

### OS/Containerの確認

ターミナルで以下コマンドを実行。→ OK
```
> cat /etc/os-release
PRETTY_NAME="Ubuntu 24.04.3 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
VERSION="24.04.3 LTS (Noble Numbat)"
VERSION_CODENAME=noble
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=noble
LOGO=ubuntu-logo
```

### Nodeの確認

ターミナルで以下コマンドを確認。→ OK
```
> node -v
v20.19.6

> npm -v
10.8.2
```

### CLIツールの確認

ターミナルで以下コマンドを実行。→ OK
```
> az version
{
  "azure-cli": "2.81.0",
  "azure-cli-core": "2.81.0",
  "azure-cli-telemetry": "1.1.0",
  "extensions": {}
}
```

### Azure CLIログイン状態の確認

→ OK
```
> az account show
Please run 'az login' to setup account.

> az login
To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code xxxxxxxx to authenticate.
```

### Bicep CLIの確認

→ OK
```
> az bicep version
Bicep CLI version 0.39.26 (1e90b06e40)
```

### azdの確認
```
> azd version
azd version 1.22.5 (commit f1850eb726d560d54118b4fa1c5f770d5f38e7f5)
```

### VS Code 拡張機能の確認

VS CodeのExtensionsで確認。いくつか謎のステータスになっているものがある。

→ 一応OK

- **Azure App Service (preview)**
- **Azure CLI Tools**
- **Azure Functions**
- **Azure Resources**
- **ESLint (Nodeをインストールすると有効化されるのかしら？)**
- **GitHub Copilot Chat**
- **Japanese Language Pack for Visual Studio Code (有効化されているけど、ブラウザインストールできる風になってる、でもブラウザインストールしようとするとエラーになる。。)**
- **GitHub Copilot (グレーアウトされてるっぽいけどインストールされている)**

### Github Copilotの動作確認

“test.ts”ファイルを作成し、以下を入力してコード補完されればOK

```
１行毎に提案されるので、その度にTABキーを押せば、シンプルなHTTPサーバーのコードが生成される。
```

→ OK
```
// create a simple http server
```

数秒待って、グレー文字で補完され、Tabで確定できればOK.
```
// create a simple http server
import * as http from 'http';

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello, World!\n');
});

const PORT = 3000;
server.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}/`);
});

// export the server for testing purposes
export default server; 
```

このとき、”http”についてモジュールや型宣言が見つからないというエラーが発生し、”@types/node”のインストールが提案される。
```
モジュール 'http' またはそれに対応する型宣言が見つかりません。
```

これは、TypeScriptの型宣言が見つからないことが原因で、TypeScriptの型チェック機能が警告しているようだ。

Nodeプロジェクトとしてnpm initを実行し、package.jsonファイルを作成してそこにNode用の型チェックモジュールを宣言することで解決するようだ。

### Node.jsの型定義をインストール

#### プロジェクト初期化。

package.jsonが作成され、プロジェクトとして認識される。
```
> npm init -y
Wrote to /workspaces/azure-env-inspector/package.json:

{
  "name": "azure-env-inspector",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}
```

#### Node.jsの型定義をインストール

開発用途向けにNodeの型定義モジュールをインストールする。

これでnode.jsの型定義がインストールされ、TypeScriptがnode標準のhttpモジュールの型を認識できるようになる。
```
> npm install --save-dev @types/node

added 2 packages, and audited 3 packages in 910ms

found 0 vulnerabilities
```

これにより、package.jsonは以下のようになる。
```
{
  "name": "azure-env-inspector",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "devDependencies": {
    "@types/node": "^25.0.3" // -> これが追加された
  }
}
```

以上で、httpモジュールの型がTypeScriptで認識され、メッセージは消える。

### Azure Functions拡張機能の確認

ターミナルで以下を確認。

バージョン情報が出ればOK。
```
> func --version
4.6.0

```

### Azure連携の確認

Azureサブスクリプションが見れること。
```
ログインしていない場合
> az account list -o table
Please run "az login" to access your accounts.

ログイン済みの場合
> az account list -o table
Name                                       CloudName    SubscriptionId                        TenantId                              State    IsDefault
-----------------------------------------  -----------  ------------------------------------  ------------------------------------  -------  -----------
Subscription-IBMJPOCKSPOC-MPN-EA-Dev-Test  AzureCloud   48a288e7-d57f-4e9a-b8f7-14042109d26f  ac231d85-5e4a-48a4-9b8d-3e67d4efe6d4  Enabled  True
```

### App Service拡張の確認

左サイドバーのAzureアイコンが表示されており、App Serviceが表示され、サブスクリプションが見える。

### Functions拡張の確認

同じく、Azure → Functions が表示される。

## この時点のGithubソース構成

一旦以下のファイル構成でgithubにpush。
```
azure-env-inspector/
├─ .devcontainer/
│   └─ devconatiner.json
├─ node_modules/
├─ .gitignore
├─ package-lock.json
├─ package.json
├─ README.md
└─ test.ts
```

この状態でgit pushしたが、git lfsというコマンドがインストールされていないためpushできずというエラーが発生。

git lfs（Large File Storage）とは、巨大なファイルをポインタ管理するための仕組み。通常gitでは、すべてのファイルを１つのバージョンとして管理するため、巨大なファイルがあると、ストレージが肥大化する。そのような巨大ファイルは１つのファイルとして保持し、内容に変更がなければポインタとして各バージョンに保存する仕組み。

何やら、リポジトリを作成したときに含まれていたようで、Github Copilotで解決してもらった。
```
Git LFS (Large File Storage) は、大きなファイルをGitで効率的に管理するための拡張機能です。

通常のGitの問題点
Gitは通常、すべてのファイルの全履歴をリポジトリに保存します。画像、動画、データセット、ビルド成果物などの大きなファイルを何度も更新すると、リポジトリのサイズが膨大になり、クローンやフェッチが遅くなります。

Git LFSの仕組み
大きなファイルは別の場所に保存: 実際のファイルはGitサーバーの専用ストレージに保存されます
リポジトリには「ポインタ」だけ: Gitリポジトリには小さなポインタファイル(数百バイト)だけが保存されます
必要な時だけダウンロード: チェックアウト時に必要なバージョンだけがダウンロードされます
よく使われるファイル
画像・動画ファイル (.png, .jpg, .mp4)
データセット (.csv, .json)
バイナリファイル (.zip, .exe, .dll)
機械学習モデル (.pkl, .h5)
あなたのケース
このリポジトリには.gitattributesファイルがなく、Git LFSで追跡しているファイルもないようです。おそらく過去にGit LFSを設定したが、現在は使用していない状態です。

推奨: Git LFSを使う予定がなければ、**方法2(pre-pushフックを削除)**で問題ありません。
```

## Azureリソースをbicepで準備する

### リソースグループの作成

https://learn.microsoft.com/ja-jp/azure/azure-resource-manager/bicep/create-resource-group

https://qiita.com/masafullversion/items/d0c1a85a38f624ee2310

```
> az deployment sub create --template-file infra/rg.bicep --location japaneast
```
“—location”は必須パラメータになったようで。メタデータの格納場所だそうです。


