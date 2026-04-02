package com.schoolplant.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Data
@ConfigurationProperties(prefix = "tencent.cos")
public class TencentCosProperties {
    private boolean enabled;
    private String secretId;
    private String secretKey;
    private String bucket;
    private String region;

    private boolean https = true;

    private int connectTimeoutMs = 5000;
    private int socketTimeoutMs = 10000;
    private int connectionRequestTimeoutMs = 5000;
    private int maxConnections = 50;

    private boolean objectPublicRead = false;
}
