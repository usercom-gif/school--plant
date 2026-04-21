package com.schoolplant.config;

import com.qcloud.cos.COSClient;
import com.qcloud.cos.ClientConfig;
import com.qcloud.cos.auth.BasicCOSCredentials;
import com.qcloud.cos.auth.COSCredentials;
import com.qcloud.cos.http.HttpProtocol;
import com.qcloud.cos.region.Region;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;

@Configuration
@EnableConfigurationProperties(TencentCosProperties.class)
@ConditionalOnProperty(name = "school-plant.storage", havingValue = "cos")
public class TencentCosConfig {

    @Autowired
    private TencentCosProperties properties;

    @Bean(destroyMethod = "shutdown")
    public COSClient cosClient() {
        COSCredentials credentials = new BasicCOSCredentials(properties.getSecretId(), properties.getSecretKey());
        ClientConfig clientConfig = new ClientConfig(new Region(properties.getRegion()));
        clientConfig.setHttpProtocol(properties.isHttps() ? HttpProtocol.https : HttpProtocol.http);

        clientConfig.setConnectionTimeout(properties.getConnectTimeoutMs());
        clientConfig.setSocketTimeout(properties.getSocketTimeoutMs());
        clientConfig.setConnectionRequestTimeout(properties.getConnectionRequestTimeoutMs());
        clientConfig.setMaxConnectionsCount(properties.getMaxConnections());

        return new COSClient(credentials, clientConfig);
    }
}
