### 2023/11/28

AI アシスタント統合を強調したサンプルデジタルツインアプリケーションについては、ブログ記事をご覧ください：[AWS IoT TwinMaker と Amazon Bedrock でスマート製造のための AI アシスタントを構築する](https://aws.amazon.com/blogs/iot/building-an-ai-assistant-for-smart-manufacturing-with-aws-iot-twinmaker-and-amazon-bedrock/)

[iot-app-kit](https://github.com/awslabs/iot-app-kit) を使った React アプリケーションで構築されたサンプルデジタルツインアプリケーションについては、[CookieFactoryV2](https://github.com/aws-samples/aws-iot-twinmaker-samples/tree/main/src/workspaces/cookiefactoryv2) をご覧ください。

[TwinMaker Knowledge Graph](https://aws.amazon.com/about-aws/whats-new/2022/11/twinmaker-knowledge-graph-generally-available-aws-iot-twinmaker/) を強調したサンプルデジタルツインアプリケーションについては、ガイド付き [SmartBuilding ワークショップ](https://catalog.us-east-1.prod.workshops.aws/workshops/93076d98-bdf1-48b8-bfe8-f4039ca1bf25/en-US) をご覧ください。

---

注意：AWS IoT TwinMaker ワークスペースを作成する際に使用する IAM ポリシーのサンプルをお探しの場合は、こちらのサンプル [アクセス許可ポリシー](./docs/sample_workspace_role_permission_policy.json) と [信頼関係ポリシー](./docs/sample_workspace_role_trust_policy.json) をご覧ください。[AWS CloudFormation を使用して](https://console.aws.amazon.com/cloudformation/home#/stacks/create/template) このロールを作成したい場合は、[このテンプレート](./docs/sample_workspace_role.yml) をご利用ください。

ロールアクセス許可ポリシーは、S3 バケット内のワークスペースリソースを管理するために AWS IoT TwinMaker へのアクセスのみを付与します。バケットが作成されたら、特定の S3 バケットにバケット許可を範囲指定することをお勧めします。また、実装したカスタム AWS Lambda コネクタの呼び出しや、AWS IoT SiteWise および Amazon Kinesis Video Streams のビデオストリームメタデータへのアクセスなど、ユースケースに必要な追加の許可を付与するために、ロールを更新する必要があります。エンドツーエンドのセットアップエクスペリエンス（サンプルユースケースに必要なすべての許可を持つこれらのロールの自動生成を含む）については、以下の開始ガイドに従うことをお勧めします。

# AWS IoT TwinMaker はじめに

## 概要

このプロジェクトでは、AWS IoT TwinMaker を使用してデジタルツインアプリケーションを構築するプロセスを説明します。このプロジェクトには多くのサンプルが含まれており、IoT TwinMaker の多くの機能を探索できるシミュレートされたクッキー工場も含まれています。この README に従うことで、Grafana で以下のダッシュボードが実行され、サンプル CookieFactory デジタルツインとやり取りできるようになります。

![Grafana Import CookieFactory](docs/images/grafana_import_result_cookiefactory.png)

問題が発生した場合は、このページのトラブルシューティングセクションを参照してください。

## 前提条件

注意：これらの手順は主に Mac/Linux/WSL 環境でテストされています。標準化された開発環境の場合は、以下を使用できます：
- **[Development Container](./.devcontainer/README.md)**（推奨） - すべての依存関係が事前設定された VS Code Dev Containers
- **[Cloud9 セットアップガイド](./CLOUD9_SETUP.md)** - AWS Cloud9 環境

1. このサンプルは、まだすべてのリージョンで利用できない可能性のある AWS サービスに依存しています。以下のいずれかのリージョンでこのサンプルを実行してください：
   - 米国東部（バージニア北部）(us-east-1)
   - 米国西部（オレゴン）(us-west-2)
   - 欧州（アイルランド）(eu-west-1)
2. IoT TwinMaker の AWS アカウント + [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
   - このサンプルをセットアップするアカウントと一致するように、デフォルトの認証情報を[構成](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)することをお勧めします。以下のコマンドを使用して、正しいアカウントを使用していることを確認してください。（これは Cloud9 で事前設定されている必要があります。）
     ```bash
     aws sts get-caller-identity
     ```
   - AWS CLI のバージョンが少なくとも 1.22.94 であることを確認してください。（AWS CLI v2 の場合は 2.5.5 以降）
     ```bash
     aws --version
     ```
   - セットアップが完了したら、以下のコマンドでアクセスをテストしてください。（エラーが発生しないはずです。）
     ```
     aws iottwinmaker list-workspaces --region us-east-1
     ```
3. [Python3](https://www.python.org/downloads/)
   - python3 のパスとバージョン（3.7 以降）を確認してください。（これは Cloud9 にプリインストールされている必要があります。）
     ```
     python3 --version
     ```
   - **オプション**：[Pyenv](https://github.com/pyenv/pyenv) と [Pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv)。正しい Python 依存関係を確保するために、`pyenv` と `pyenv-virtualenv` を使用してください。システム全体の Python3 インストールがある限りオプションですが、複数の Python プロジェクト間の競合を避けるために強く推奨されます。
4. [Node.js & NPM](https://nodejs.org/en/) node v14.18.1 以降および npm バージョン 8.10.0 以降。（これは Cloud9 にプリインストールされている必要があります。）以下のコマンドで確認してください。

   ```
   node --version
   ```

   ```
   npm --version
   ```

5. [AWS CDK toolkit](https://docs.aws.amazon.com/cdk/latest/guide/getting_started.html#getting_started_install) バージョン `2.27.0` 以降。（CDK は Cloud9 にプリインストールされている必要がありますが、アカウントをブートストラップする必要がある場合があります。）以下のコマンドで確認してください。

   ```
   cdk --version
   ```

   - サンプルの Lambda 関数などのカスタムアセットを簡単にデプロイできるように、CDK 用にアカウントをブートストラップする必要があります。以下のコマンドを使用してください。

     ```
     cdk bootstrap aws://[12桁のAWSアカウントID]/[リージョン]

     # 例
     # cdk bootstrap aws://123456789012/us-east-1
     ```

6. [Docker](https://docs.docker.com/get-docker/) バージョン 20 以降。（これは Cloud9 にプリインストールされている必要があります。）パブリック ECR レジストリ用に Docker を認証します
   ```
   docker --version
   ```
   - CDK の Lambda レイヤーをビルドするには、以下のコマンドを使用してください。
     ```bash
     aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
     ```

## サンプル Cookie Factory ワークスペースのデプロイ

1. 環境変数を設定します。

   残りの手順を簡単に実行できるように、以下の環境変数を設定します。

   ```bash
   # この README と同じディレクトリに移動
   cd [この README のディレクトリ]
   ```

   ```bash
   # AWS アカウント ID を設定します。`aws sts get-caller-identity` を使用して、現在使用しているアカウント ID を確認できます
   export CDK_DEFAULT_ACCOUNT=[あなたの AWS アカウント ID に置き換え]
   ```

   ```bash
   # インストールのオプションを設定します。別のワークスペース ID を使用したい場合は、'CookieFactory' を希望のものに変更してください
   export GETTING_STARTED_DIR=$PWD
   export AWS_DEFAULT_REGION=us-east-1
   export CDK_DEFAULT_REGION=$AWS_DEFAULT_REGION
   export TIMESTREAM_TELEMETRY_STACK_NAME=CookieFactoryTelemetry
   export WORKSPACE_ID=CookieFactory
   ```

2. Python ライブラリをインストールします。

   Cookie Factory サンプルデータのデプロイを支援するために Python を使用します。以下のコマンドを使用して、必要な Python ライブラリをインストールしてください。

   ```bash
   pip3 install -r $GETTING_STARTED_DIR/src/workspaces/cookiefactory/requirements.txt
   ```

3. IoT TwinMaker ワークスペースを作成します。

   a. IoT TwinMaker 実行ロールを作成します

   デジタルツインアプリケーションごとに異なるリソースを使用します。以下のコマンドを実行して、このサンプルアプリケーションに必要な許可を持つワークスペースの実行ロールを作成してください。次の手順でワークスペースを作成する際に、ロール名を使用することに注意してください。

   ```bash
   python3 $GETTING_STARTED_DIR/src/workspaces/cookiefactory/setup_cloud_resources/create_iottwinmaker_workspace_role.py --region $AWS_DEFAULT_REGION
   ```

   b. AWS コンソールでワークスペースを作成します

   次に、コンソールに移動して、ステップ 1 で WORKSPACE_ID に使用したのと同じ名前でワークスペースを作成します。コンソールで S3 バケットを自動的に作成させることができます。ワークスペースのロールを提供するように求められたら、前述のスクリプトによって生成されたロール名を使用してください。（名前には文字列「IoTTwinMakerWorkspaceRole」が含まれているはずです。）

   ワークスペース設定を入力すると、ワークスペースとやり取りするために使用する Grafana 環境を指定するように求められます。インフラストラクチャをホストするために Amazon Managed Grafana を使用することをお勧めしますが、[Grafana の手順](./docs/grafana_local_docker_setup.md) に従って決定し、環境を構築することができます。

   ダッシュボードロールを要求されたら、コンソールの手順に従って、Grafana で使用する IAM ポリシーとロールを手動で作成できます。ワークスペースを作成した後の次の手順で、このパッケージのスクリプトを使用してロールを自動的に作成できます。

   最後に、レビューページで「作成」をクリックして、ワークスペースを作成します。

   us-east-1 のコンソールリンク：https://us-east-1.console.aws.amazon.com/iottwinmaker/home?region=us-east-1

   c. Grafana ダッシュボード IAM ロールを作成します

   ダッシュボード設定手順を完了していない場合は、以下のスクリプトを実行して、Grafana ダッシュボードでワークスペースにアクセスするためのロールを作成してください。これは、Grafana での IoT TwinMaker およびその他の AWS サービスへの ReadOnly アクセスのために範囲指定された許可を使用します。作成したロールの ARN をメモしてください。Grafana でデータソースを構成する際に使用します。

   ```bash
   python3 $GETTING_STARTED_DIR/src/modules/grafana/create_grafana_dashboard_role.py --workspace-id $WORKSPACE_ID --region $AWS_DEFAULT_REGION --account-id $CDK_DEFAULT_ACCOUNT
   ```

   Amazon Managed Grafana を使用している場合は、フィールドを追加してください：

   ```bash
   --auth-provider <Amazon Managed Grafana ワークスペース IAM ロール ARN>
   ```

   現在の AWS 認証情報が Grafana で使用するものと同じであることを確認してください。そうでない場合は、このスクリプトを実行した後、IAM コンソールに移動し、使用する認証プロバイダーの信頼許可を更新してください。[ドキュメントの認証プロバイダー](https://docs.aws.amazon.com/iot-twinmaker/latest/guide/dashboard-IAM-role.html#grafana-IAM-role)の詳細をお読みください。

   Grafana データソース、Scene Viewer パネル、および Video Player パネルの基本機能を有効にするために、IoT TwinMaker と Kinesis Video Streams の許可を自動的に追加します。Video Player のより多くの機能（タイムスクラバーバー + キャッシュからのビデオアップロードリクエスト）を有効にしたい場合は、[ビデオプレーヤーポリシードキュメント](https://docs.aws.amazon.com/iot-twinmaker/latest/guide/tm-video-policy.html)に従って IAM ポリシーを手動で更新する必要があります。

4. Timestream Telemetry モジュールのインスタンスをデプロイします。

   Timestream Telemetry は、IoT データのサンプルテレメトリストアです。単一の AWS Timestream データベースとテーブル、および読み取りと書き込みのための Lambda 関数を使用します。後の手順で、このテーブルに Cookie Factory のサンプルデータを入力します。以下のコマンドは、データベースとテーブルを作成し、/src/lib/timestream_telemetry の下にある Lambda 関数をデプロイします。

   ```bash
   cd $GETTING_STARTED_DIR/src/modules/timestream_telemetry/cdk/
   ```

   以下のコマンドを使用して、モジュールの依存関係をインストールします

   ```
   npm install
   ```

   モジュールをデプロイします。（IAM の変更を承認するよう求められたら、'y' を入力してください。）

   ```
   cdk deploy
   ```

5. 以下のコマンドを使用して、Cookie Factory コンテンツをインポートします。

   ```bash
   cd $GETTING_STARTED_DIR/src/workspaces/cookiefactory/

   # Cookie Factory データをワークスペースにインポート
   python3 -m setup_content \
     --telemetry-stack-name $TIMESTREAM_TELEMETRY_STACK_NAME \
     --workspace-id $WORKSPACE_ID \
     --region-name $AWS_DEFAULT_REGION \
     --import-all
   ```

   サンプルコンテンツを再インポートする場合は、古いコンテンツを削除するフラグを追加する必要があります（--delete-all または --delete-telemetry や --delete-entities などの個別のフラグ）。

   サンプルコンテンツの一部のみをインポートする場合は、--import-all の代わりに個別のインポートフラグを使用できます（--import-telemetry や --import-entities など）。

   注意：初回インポート時、スクリプトはサンプルテレメトリとビデオを生成するために使用される開始タイムスタンプを保存します。これは、TwinMaker ワークスペースの `samples_content_start_time` タグに保存されます。スクリプトの後続の再実行時には、この開始タイムスタンプは一貫したデータ生成のために再利用されます。代わりに現在の時刻を使用してデータを再作成したい場合は、ワークスペースからタグを削除してください。

6. （オプション）Unified Data Query（UDQ）を使用して、エンティティ、シーン、およびテストデータの接続性を確認します。

   すべてのコンテンツをインポートした後、IoT TwinMaker コンソールに移動して、作成したエンティティとシーンを表示できます。

   - https://us-east-1.console.aws.amazon.com/iottwinmaker/home?region=us-east-1

   AWS IoT TwinMaker は、そのコンポーネントモデルと Unified Data Query インターフェースを介してデータソースに接続し、クエリを実行する機能を提供します。この入門ガイドでは、一部のデータを Timestream にインポートし、クエリを実行できるようにするコンポーネントとサポート UDQ Lambda 関数を設定しました。`get-property-value-history` API を使用してアラームデータをクエリできるかどうかをテストするには、以下のコマンドを使用してください。

   ```
   aws iottwinmaker get-property-value-history \
      --region $AWS_DEFAULT_REGION \
      --cli-input-json '{"componentName": "AlarmComponent","endTime": "2023-06-01T00:00:00Z","entityId": "Mixer_2_06ac63c4-d68d-4723-891a-8e758f8456ef","orderByTime": "ASCENDING","selectedProperties": ["alarm_status"],"startTime": "2022-06-01T00:00:00Z","workspaceId": "'${WORKSPACE_ID}'"}'
   ```

   他のサポートされているリクエスト例については、[追加の UDQ サンプルリクエスト](#追加の-udq-サンプルリクエスト)を参照してください。

7. Cookie Factory の Grafana をセットアップします。

   AWS IoT TwinMaker は、IoT TwinMaker シーンとモデル化されたデータソースを使用してダッシュボードを構築するために使用できる Grafana プラグインを提供します。Grafana は Docker コンテナとしてデプロイ可能です。新規ユーザーには、ローカルコンテナとして Grafana をセットアップするための次の手順に従うことをお勧めします：[手順](./docs/grafana_local_docker_setup.md)。（Cloud9 でリンクが機能しない場合は、`docs/grafana_local_docker_setup.md` を開いてください。）

   本番環境の Grafana インストールをアカウントにセットアップすることを目指す上級ユーザーには、https://github.com/aws-samples/aws-cdk-grafana をチェックアウトすることをお勧めします。

8. Cookie Factory の Grafana ダッシュボードをインポートします。

   Grafana ページが開いたら、以下をクリックして、`$GETTING_STARTED_DIR/src/workspaces/cookiefactory/sample_dashboards/` にあるサンプルダッシュボード JSON ファイルをインポートできます。（Cloud9 から実行している場合は、右クリックしてファイルをローカルにダウンロードし、ローカルマシンからインポートできます）

   - mixer_alarms_dashboard.json

   ![Grafana Import CookieFactory](docs/images/grafana_import_dashboard.png)

   ローカル Grafana で実行している CookieFactory サンプルの場合、http://localhost:3000/d/y1FGfj57z/aws-iot-twinmaker-mixer-alarm-dashboard?orgId=1& に移動してダッシュボードを表示できます。

## 追加（アドオン）コンテンツのデプロイ

### SiteWise コネクタ

このセクションでは、SiteWise アセットとテレメトリを追加し、CookieFactory デジタルツインエンティティを更新してこのデータソースにリンクします。

1. SiteWise アセットとテレメトリを追加します。

   ```
   python3 $GETTING_STARTED_DIR/src/modules/sitewise/deploy-utils/SiteWiseTelemetry.py import --csv-file $GETTING_STARTED_DIR/src/workspaces/cookiefactory/sample_data/telemetry/telemetry.csv \
     --entity-include-pattern WaterTank \
     --asset-model-name-prefix $WORKSPACE_ID
   ```

2. エンティティを更新して SiteWise コネクタをアタッチします。

   ```
   python3 $GETTING_STARTED_DIR/src/modules/sitewise/lib/patch_sitewise_content.py --workspace-id $WORKSPACE_ID --region $AWS_DEFAULT_REGION
   ```

3. UDQ を使用して SiteWise データの接続性をテストし、WaterTank ボリュームメトリクスをクエリします。

   ```
   aws iottwinmaker get-property-value-history \
     --region $AWS_DEFAULT_REGION \
     --cli-input-json '{"componentName": "WaterTankVolume","endTime": "2023-06-01T00:00:00Z","entityId": "WaterTank_ab5e8bc0-5c8f-44d8-b0a9-bef9c8d2cfab","orderByTime": "ASCENDING","selectedProperties": ["tankVolume1"],"startTime": "2022-06-01T00:00:00Z","workspaceId": "'${WORKSPACE_ID}'"}'
   ```

### S3 ドキュメントコネクタ

このセクションでは、IoT TwinMaker エンティティが S3 に保存されたデータにリンクできるように S3 コネクタを追加します。

`s3` モジュールディレクトリに移動し、[README](./src/modules/s3/README.md) を確認してください。

```
cd $GETTING_STARTED_DIR/src/modules/s3
```

### AWS IoT TwinMaker Insights and Simulation

注意：このアドオンは、AWS 料金が発生する可能性のある実行中の Amazon Kinesis Data Analytics（KDA）コンピューティングリソースを作成します。使用が終了したら、[アドオンのティアダウン：AWS IoT TwinMaker Insights and Simulation](#アドオンのティアダウン-aws-iot-twinmaker-insights-and-simulation) の手順で KDA ノートブックリソースを停止または削除することをお勧めします。

このセクションでは、AWS IoT TwinMaker Flink ライブラリを使用して、Mixer のテレメトリデータを 2 つのサービスに接続し、エンティティデータをより深い洞察で強化します：

* RPM に基づいて Mixer の消費電力を計算する Maplesoft シミュレーション
* RPM 異常検出用の事前トレーニング済み機械学習モデル

両方のサービスは SageMaker エンドポイントとして公開され、このアドオンがアカウントにセットアップします。

`insights` モジュールディレクトリに移動し、[README](./src/modules/insights/README.md) を確認してください。

```
cd $GETTING_STARTED_DIR/src/modules/insights
```

### 追加の UDQ サンプルリクエスト

このセクションには、CookieFactory ワークスペースで `get-property-value-history` でサポートされている追加のサンプルリクエストが含まれています。

1. 単一エンティティ、複数プロパティリクエスト（Mixer データ）
   
   ```
   aws iottwinmaker get-property-value-history \
      --region $AWS_DEFAULT_REGION \
      --cli-input-json '{"componentName": "MixerComponent","endTime": "2023-06-01T00:00:00Z","entityId": "Mixer_2_06ac63c4-d68d-4723-891a-8e758f8456ef","orderByTime": "ASCENDING","selectedProperties": ["Temperature", "RPM"],"startTime": "2022-06-01T00:00:00Z","workspaceId": "'${WORKSPACE_ID}'"}'
   ```

2. 複数エンティティ、単一プロパティリクエスト（アラームデータ）

   ```
   aws iottwinmaker get-property-value-history \
     --region $AWS_DEFAULT_REGION \
     --cli-input-json '{"componentTypeId": "com.example.cookiefactory.alarm","endTime": "2023-06-01T00:00:00Z","orderByTime": "ASCENDING","selectedProperties": ["alarm_status"],"startTime": "2022-06-01T00:00:00Z","workspaceId": "'${WORKSPACE_ID}'"}'
   ```
 
3. 複数エンティティ、複数プロパティリクエスト（Mixer データ）

   ```
   aws iottwinmaker get-property-value-history \
     --region $AWS_DEFAULT_REGION \
     --cli-input-json '{"componentTypeId": "com.example.cookiefactory.mixer","endTime": "2023-06-01T00:00:00Z","orderByTime": "ASCENDING","selectedProperties": ["Temperature", "RPM"],"startTime": "2022-06-01T00:00:00Z","workspaceId": "'${WORKSPACE_ID}'"}'
   ```

---

## ティアダウン

**これらは破壊的なアクションであり、このサンプルから作成/変更したすべてのコンテンツが削除されることに注意してください。**

前のセットアップ手順から以下の環境変数が設定されている必要があります。

```bash
GETTING_STARTED_DIR=__上記参照__
WORKSPACE_ID=__上記参照__
TIMESTREAM_TELEMETRY_STACK_NAME=__上記参照__
AWS_DEFAULT_REGION=us-east-1
```

### アドオンのティアダウン：SiteWise コネクタ

アドオン SiteWise コンテンツをインストールし、削除したい場合は、以下を実行してください

```
python3 $GETTING_STARTED_DIR/src/modules/sitewise/deploy-utils/SiteWiseTelemetry.py cleanup --asset-model-name-prefix $WORKSPACE_ID
```

### アドオンのティアダウン：S3 ドキュメントコネクタ

アドオン S3 コンテンツをインストールし、削除したい場合は、以下を実行してください

```
aws cloudformation delete-stack --stack-name IoTTwinMakerCookieFactoryS3 --region $AWS_DEFAULT_REGION && aws cloudformation wait stack-delete-complete --stack-name IoTTwinMakerCookieFactoryS3 --region $AWS_DEFAULT_REGION
```

### アドオンのティアダウン：AWS IoT TwinMaker Insights and Simulation

アドオン AWS IoT TwinMaker Insights and Simulation コンテンツをインストールし、削除したい場合は、以下を実行してください。これらのスタックは削除に数分かかる場合があります。

インストールされたアセットを削除

```
python3 $INSIGHT_DIR/install_insights_module.py --workspace-id $WORKSPACE_ID --region-name $AWS_DEFAULT_REGION --kda-stack-name $KDA_STACK_NAME --sagemaker-stack-name $SAGEMAKER_STACK_NAME --delete-all
```

CloudFormation スタックを削除

```
aws cloudformation delete-stack --stack-name $KDA_STACK_NAME --region $AWS_DEFAULT_REGION && aws cloudformation wait stack-delete-complete --stack-name $KDA_STACK_NAME --region $AWS_DEFAULT_REGION
```

```
aws cloudformation delete-stack --stack-name $SAGEMAKER_STACK_NAME --region $AWS_DEFAULT_REGION && aws cloudformation wait stack-delete-complete --stack-name $SAGEMAKER_STACK_NAME --region $AWS_DEFAULT_REGION
```

### ベースコンテンツの削除

ディレクトリを変更

```
cd $GETTING_STARTED_DIR/src/workspaces/cookiefactory
```

Grafana ダッシュボードロールを削除（存在する場合）

```
python3 $GETTING_STARTED_DIR/src/modules/grafana/cleanup_grafana_dashboard_role.py --workspace-id $WORKSPACE_ID --region $AWS_DEFAULT_REGION
```

AWS IoT TwinMaker ワークスペース + コンテンツを削除

```
# エンティティが削除中に停止しているように見える場合、このスクリプトは安全に終了して再起動できます
python3 -m setup_content \
     --telemetry-stack-name $TIMESTREAM_TELEMETRY_STACK_NAME \
     --workspace-id $WORKSPACE_ID \
     --region-name $AWS_DEFAULT_REGION \
     --delete-all \
     --delete-workspace-role-and-bucket
```

Telemetry CFN スタックを削除 + 待機

```
aws cloudformation delete-stack --stack-name $TIMESTREAM_TELEMETRY_STACK_NAME --region $AWS_DEFAULT_REGION && aws cloudformation wait stack-delete-complete --stack-name $TIMESTREAM_TELEMETRY_STACK_NAME --region $AWS_DEFAULT_REGION
```

### （オプション）ローカル Grafana 設定を削除

```
rm -rf ~/local_grafana_data/
```

---

## トラブルシューティング

ここで対処されていない問題については、Issue を開くか、AWS サポートにお問い合わせください。

### `ImportError: libGL.so.1: cannot open shared object file: No such file or directory`

`mesa-libGL` がインストールされていることを確認してください。例：

```
sudo yum install mesa-libGL
```

---

## セキュリティ

詳細については、[CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) を参照してください。

## ライセンス

このプロジェクトは Apache-2.0 ライセンスの下でライセンスされています。
