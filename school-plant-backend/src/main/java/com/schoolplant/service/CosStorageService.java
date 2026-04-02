package com.schoolplant.service;

import com.qcloud.cos.model.COSObjectSummary;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.util.List;

public interface CosStorageService {
    String upload(MultipartFile file, String key);

    String uploadBytes(byte[] bytes, String key, String contentType);

    InputStream download(String key);

    byte[] downloadBytes(String key);

    List<COSObjectSummary> list(String prefix, Integer maxKeys);

    void delete(String key);

    void healthCheck();
}
