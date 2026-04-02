package com.schoolplant.service.impl;

import com.qcloud.cos.COSClient;
import com.qcloud.cos.exception.CosClientException;
import com.qcloud.cos.exception.CosServiceException;
import com.qcloud.cos.model.*;
import com.schoolplant.config.TencentCosProperties;
import com.schoolplant.service.CosStorageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBean;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.net.SocketTimeoutException;
import java.util.List;
import java.util.UUID;

@Service
@ConditionalOnBean(COSClient.class)
public class CosStorageServiceImpl implements CosStorageService {

    @Autowired
    private COSClient cosClient;

    @Autowired
    private TencentCosProperties properties;

    @Override
    public String upload(MultipartFile file, String key) {
        if (file == null || file.isEmpty()) {
            throw new RuntimeException("上传文件不能为空");
        }
        if (!StringUtils.hasText(key)) {
            String ext = "";
            String original = file.getOriginalFilename();
            if (original != null && original.contains(".")) {
                ext = original.substring(original.lastIndexOf('.'));
            }
            key = "uploads/" + UUID.randomUUID() + ext;
        }

        try {
            ObjectMetadata metadata = new ObjectMetadata();
            metadata.setContentLength(file.getSize());
            if (StringUtils.hasText(file.getContentType())) {
                metadata.setContentType(file.getContentType());
            }

            PutObjectRequest request = new PutObjectRequest(properties.getBucket(), key, file.getInputStream(), metadata);
            PutObjectResult result = cosClient.putObject(request);

            if (properties.isObjectPublicRead()) {
                cosClient.setObjectAcl(properties.getBucket(), key, CannedAccessControlList.PublicRead);
            }

            if (result == null) {
                throw new RuntimeException("文件上传失败：未获取到上传结果");
            }

            return cosClient.getObjectUrl(properties.getBucket(), key).toString();
        } catch (CosServiceException e) {
            throw new RuntimeException(mapCosServiceException(e), e);
        } catch (CosClientException e) {
            throw new RuntimeException(mapCosClientException(e), e);
        } catch (IOException e) {
            throw new RuntimeException("文件上传失败：读取文件流异常", e);
        }
    }

    @Override
    public String uploadBytes(byte[] bytes, String key, String contentType) {
        if (bytes == null || bytes.length == 0) {
            throw new RuntimeException("上传内容不能为空");
        }
        if (!StringUtils.hasText(key)) {
            key = "uploads/" + UUID.randomUUID();
        }

        try {
            ObjectMetadata metadata = new ObjectMetadata();
            metadata.setContentLength(bytes.length);
            if (StringUtils.hasText(contentType)) {
                metadata.setContentType(contentType);
            }
            PutObjectRequest request = new PutObjectRequest(properties.getBucket(), key, new java.io.ByteArrayInputStream(bytes), metadata);
            PutObjectResult result = cosClient.putObject(request);
            if (properties.isObjectPublicRead()) {
                cosClient.setObjectAcl(properties.getBucket(), key, CannedAccessControlList.PublicRead);
            }
            if (result == null) {
                throw new RuntimeException("文件上传失败：未获取到上传结果");
            }
            return cosClient.getObjectUrl(properties.getBucket(), key).toString();
        } catch (CosServiceException e) {
            throw new RuntimeException(mapCosServiceException(e), e);
        } catch (CosClientException e) {
            throw new RuntimeException(mapCosClientException(e), e);
        }
    }

    @Override
    public InputStream download(String key) {
        if (!StringUtils.hasText(key)) {
            throw new RuntimeException("对象键名不能为空");
        }
        try {
            COSObject cosObject = cosClient.getObject(properties.getBucket(), key);
            if (cosObject == null || cosObject.getObjectContent() == null) {
                throw new RuntimeException("对象不存在或无法读取");
            }
            return cosObject.getObjectContent();
        } catch (CosServiceException e) {
            throw new RuntimeException(mapCosServiceException(e), e);
        } catch (CosClientException e) {
            throw new RuntimeException(mapCosClientException(e), e);
        }
    }

    @Override
    public byte[] downloadBytes(String key) {
        try (InputStream in = download(key)) {
            return in.readAllBytes();
        } catch (IOException e) {
            throw new RuntimeException("读取对象内容失败", e);
        }
    }

    @Override
    public List<COSObjectSummary> list(String prefix, Integer maxKeys) {
        try {
            ListObjectsRequest req = new ListObjectsRequest();
            req.setBucketName(properties.getBucket());
            if (StringUtils.hasText(prefix)) {
                req.setPrefix(prefix);
            }
            if (maxKeys != null && maxKeys > 0) {
                req.setMaxKeys(maxKeys);
            }
            ObjectListing listing = cosClient.listObjects(req);
            return listing.getObjectSummaries();
        } catch (CosServiceException e) {
            throw new RuntimeException(mapCosServiceException(e), e);
        } catch (CosClientException e) {
            throw new RuntimeException(mapCosClientException(e), e);
        }
    }

    @Override
    public void delete(String key) {
        if (!StringUtils.hasText(key)) {
            throw new RuntimeException("对象键名不能为空");
        }
        try {
            cosClient.deleteObject(properties.getBucket(), key);
        } catch (CosServiceException e) {
            throw new RuntimeException(mapCosServiceException(e), e);
        } catch (CosClientException e) {
            throw new RuntimeException(mapCosClientException(e), e);
        }
    }

    @Override
    public void healthCheck() {
        try {
            ListObjectsRequest req = new ListObjectsRequest();
            req.setBucketName(properties.getBucket());
            req.setMaxKeys(1);
            cosClient.listObjects(req);
        } catch (CosServiceException e) {
            throw new RuntimeException(mapCosServiceException(e), e);
        } catch (CosClientException e) {
            throw new RuntimeException(mapCosClientException(e), e);
        }
    }

    private String mapCosServiceException(CosServiceException e) {
        String code = e.getErrorCode();
        if ("AccessDenied".equalsIgnoreCase(code)) {
            return "权限不足：请检查密钥权限、存储桶 ACL/策略与对象访问权限";
        }
        if ("InvalidAccessKeyId".equalsIgnoreCase(code) || "SignatureDoesNotMatch".equalsIgnoreCase(code)) {
            return "认证失败：请检查 SecretId/SecretKey 是否正确，或密钥是否已禁用";
        }
        if (e.getStatusCode() == 404) {
            return "资源不存在：请检查存储桶名称、地域或对象键名";
        }
        return "COS 服务异常：" + (StringUtils.hasText(e.getMessage()) ? e.getMessage() : "请求失败");
    }

    private String mapCosClientException(CosClientException e) {
        Throwable cause = e.getCause();
        if (cause instanceof SocketTimeoutException) {
            return "网络超时：请检查网络连接或适当增大超时时间";
        }
        return "COS 客户端异常：" + (StringUtils.hasText(e.getMessage()) ? e.getMessage() : "请求失败");
    }

    
}
