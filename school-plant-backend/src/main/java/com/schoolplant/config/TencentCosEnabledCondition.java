package com.schoolplant.config;

import org.springframework.context.annotation.Condition;
import org.springframework.context.annotation.ConditionContext;
import org.springframework.core.env.Environment;
import org.springframework.core.type.AnnotatedTypeMetadata;
import org.springframework.util.StringUtils;

public class TencentCosEnabledCondition implements Condition {
    @Override
    public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
        Environment env = context.getEnvironment();

        boolean enabled = env.getProperty("tencent.cos.enabled", Boolean.class, Boolean.TRUE);
        if (!enabled) {
            return false;
        }

        String secretId = env.getProperty("tencent.cos.secret-id");
        String secretKey = env.getProperty("tencent.cos.secret-key");
        String bucket = env.getProperty("tencent.cos.bucket");
        String region = env.getProperty("tencent.cos.region");

        return StringUtils.hasText(secretId)
                && StringUtils.hasText(secretKey)
                && StringUtils.hasText(bucket)
                && StringUtils.hasText(region);
    }
}

