---
title: "使用 IAM 角色委派跨 AWS 账号的访问权限设置"
date: 2018-02-09T18:06:00+08:00
tags: ["aws"]
author: "ox0spy"
categories: ["aws"]
---

你可能会有多个 AWS 账号，比如：A-account, B-account。如果希望 A-account 中的服务 (比如：EC2) 有权限访问 B-account 上的服务 (比如：S3, s3://b-s3-bucket)。

## 方案一

在 B-account 上创建一个用户，赋予该用户访问 S3 bucket 的权限，为该用户生成 aws key，然后用 aws key 访问 B-account S3。

但，这个方案并不好：

- 需要创建新的用户
- 应该尽可能的减少使用 aws key，而多使用 aws role/policy 来分配权限

## 方案二 (推荐方案)

[aws 的教程](https://docs.aws.amazon.com/zh_cn/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html)写的很详细，我只记录几点注意事项：

再回顾下问题：A-account 的 EC2 需要访问 B-account 的 S3 bucket。

- 在 B-account 上创建角色 (如：role-b-s3)
 + 创建角色有多个选项，选着：`Another AWS account Belonging to you or 3rd party`，并输入 A-account 的 `account id`
 + 为该角色添加 policy ，使之拥有访问指定 S3 bucket 的权限

- 为 A-account 的 EC2 指定 角色 (如：role-a-ec2)
 + 为该 role 添加 policy，允许对 B-account 的 role-b-s3 角色执行 AssumeRole 操作。
 + policy 语法类似下面

    {
        "Version": "2012-10-17",
        "Statement": {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "arn:aws:iam::account-b-id:role/role-b-s3"
        }
    }


### 测试

#### `aws cli` 命令行测试：

    $ aws sts assume-role --role-arn "arn:aws:iam::account-b-id:role/role-b-s3"  --role-session-name "session-role-b-s3"

### `Python` 程序使用

参考：[切换到 IAM 角色](https://docs.aws.amazon.com/zh_cn/IAM/latest/UserGuide/id_roles_use_switch-role-api.html)

    import boto3


    # create an STS client object that represents a live connection to the
    # STS service
    sts_client = boto3.client('sts')

    # Call the assume_role method of the STSConnection object and pass the role
    # ARN and a role session name.
    assumedRoleObject = sts_client.assume_role(
        RoleArn="arn:aws:iam::account-b-id:role/role-b-s3",
        RoleSessionName="session-role-b-s3"
    )

    # From the response that contains the assumed role, get the temporary
    # credentials that can be used to make subsequent API calls
    credentials = assumedRoleObject['Credentials']

    print(credentials)


### aws config 配置文件

添加到 aws config 配置文件中，方便使用，想了解更多配置文件的用法，请参考：[AWS CLI Configuration Variables](https://docs.aws.amazon.com/cli/latest/topic/config-vars.html)：

    $ cat ~/.aws/config
    [profile b-s3]
    credential_source = Ec2InstanceMetadata
    role_arn = arn:aws:iam::account-b-id:role/role-b-s3
    region = us-east-1


`credential_source` 取值说明：

- `Ec2InstanceMetadata`，意思是使用 EC2 的 role 做认证
- `Environment`，从环境变量中获取认证信息
- `EcsContainer`, use the ECS container credentials as the source credentials.
- 文章中为 EC2 创建了 role 来分配权限的，所以，此处应该用 `Ec2InstanceMetadata`

#### aws cli 使用

和使用 aws profile 一样使用：

    $ aws --profile b-s3 s3 ls s3://b-s3-bucket/

#### 使用 boto3

Python 程序使用也类似

    import boto3


    session = boto3.Session(profile_name='b-s3')
    client = session.client('s3')


## 总结

上面就实现了从 `A 账号` 的 EC2 访问 `B 账号` S3，访问其它服务也是类似的。

文章只列出了要点，有些具体的操作没有描述，可以查看 aws 文档，有图文介绍的。
