---
title: "Jenkins Tips"
date: 2018-09-22T10:06:00+08:00
tags: ["jenkins"]
author: "ox0spy"
categories: ["jenkins"]
---

Jenkins 使用中的一些问题记录。

## 邮件配置

jenkins配置邮件发送，然后点击 测试配置 报错，报错信息如下：

    Failed to send out e-mail

    com.sun.mail.smtp.SMTPSenderFailedException: 501 mail from address must be same as authorization user

        at com.sun.mail.smtp.SMTPTransport.mailFrom(SMTPTransport.java:1587)
    Caused: com.sun.mail.smtp.SMTPSendFailedException: 501 mail from address must be same as authorization user
    ;
    nested exception is:
        com.sun.mail.smtp.SMTPSenderFailedException: 501 mail from address must be same as authorization user

        at com.sun.mail.smtp.SMTPTransport.issueSendCommand(SMTPTransport.java:2057)

解决：

Jenkins 系统配置 -> Jenkins Location ，确保 系统管理员邮件地址 的配置 和 邮件通知 中的邮箱是一样的。
