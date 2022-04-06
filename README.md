# AWS Lambda 1

## 関数のビルド・デプロイ

### Lambda関数用のRoleの作成

- 下記の`policy.json`は最低限のCloudWatchの権限のみのポリシーが書いてあるJSONファイル。
  - 関数内容によって、ポリシーを調整する
- awsコマンドを使って、policy.jsonの内容で、`lambda-test-func-policy`という名前のポリシーを作成する。

```policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    }
  ]
}
```

```shell
aws iam create-policy --policy-name lambda-test-func-policy --policy-document file://policy.json
```

- ロールに適用する「assume-role-policy」を作成する
  - このロールを使えるサービスを設定するような認識。今回はLambdaだけで使えればよいので、そのように設定する。

```role-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
``` 

- 上記の「assume-role-policy」を適用したロールを作成する。

```shell
aws iam create-role --role-name lambda-test-role --assume-role-policy-document file://role-policy.json
```

- 作成したロールにポリシーを適用する。

```shell
aws iam attach-role-policy --role-name lambda-test-role --policy-arn ${POLICY_ARN}
```

### 認証

```shell
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_URI}
```

### リポジトリ作成

```shell
aws ecr create-repository --region ${REGION} --repository-name ${REPO_NAME} --image-scanning-configuration scanOnPush=true --image-tag-mutability MUTABLE
```

### ビルド

```shell
docker build -t ${REPO_NAME} .
``` 

### タグ作成

```shell
docker tag ${REPO_NAME}:${TAG_NAME} ${ECR_URI}/${REPO_NAME}:${TAG_NAME}
```

### プッシュ

```shell
docker push ${ECR_URI}/${REPO_NAME}:${TAG_NAME}
```

### デプロイ
#### 関数の新規作成

```shell
aws lambda create-function --region ${REGION} --function-name ${FUNCTION_NAME} \
  --package-type Image \
  --code ImageUri=${ECR_URI}/${REPO_NAME}:${TAG_NAME} \
  --role ${ROLE_ARN}
```

#### 関数のアップデート

```shell
aws lambda update-function-code --region ${REGION} \
  --function-name ${FUNCTION_NAME} \
  --image-uri ${ECR_URI}/${REPO_NAME}:${TAG_NAME}
```

## ローカル環境でのテスト

```shell
docker run -p 9000:8080 ${REPO_NAME}:${TAG_NAME}
```

```shell
curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'
```