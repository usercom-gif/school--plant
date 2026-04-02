package com.schoolplant.controller;

import com.qcloud.cos.model.COSObjectSummary;
import com.schoolplant.common.R;
import com.schoolplant.service.CosStorageService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Tag(name = "腾讯云COS", description = "对象存储（COS）接口")
@RestController
@RequestMapping("/cos")
public class CosController {

    @Autowired(required = false)
    private CosStorageService cosStorageService;

    @Operation(summary = "上传文件到COS")
    @PostMapping("/upload")
    public R<Map<String, Object>> upload(@RequestParam("file") MultipartFile file,
                                         @RequestParam(value = "key", required = false) String key) {
        ensureEnabled();
        String actualKey = key;
        if (actualKey == null || actualKey.isBlank()) {
            String ext = "";
            String original = file.getOriginalFilename();
            if (original != null && original.contains(".")) {
                ext = original.substring(original.lastIndexOf('.'));
            }
            actualKey = "uploads/" + UUID.randomUUID() + ext;
        }

        String url = cosStorageService.upload(file, actualKey);
        Map<String, Object> data = new HashMap<>();
        data.put("url", url);
        data.put("key", actualKey);
        return R.ok(data);
    }

    @Operation(summary = "列出对象")
    @GetMapping("/list")
    public R<List<Map<String, Object>>> list(@RequestParam(value = "prefix", required = false) String prefix,
                                             @RequestParam(value = "maxKeys", required = false) Integer maxKeys) {
        ensureEnabled();
        List<COSObjectSummary> list = cosStorageService.list(prefix, maxKeys);
        List<Map<String, Object>> data = list.stream().map(o -> {
            Map<String, Object> m = new HashMap<>();
            m.put("key", o.getKey());
            m.put("size", o.getSize());
            m.put("lastModified", o.getLastModified());
            return m;
        }).collect(Collectors.toList());
        return R.ok(data);
    }

    @Operation(summary = "下载对象（返回Base64/二进制请按需扩展）")
    @GetMapping("/download")
    public R<Map<String, Object>> download(@RequestParam("key") String key) {
        ensureEnabled();
        byte[] bytes = cosStorageService.downloadBytes(key);
        Map<String, Object> data = new HashMap<>();
        data.put("key", key);
        data.put("size", bytes.length);
        data.put("contentBase64", java.util.Base64.getEncoder().encodeToString(bytes));
        return R.ok(data);
    }

    @Operation(summary = "下载对象（二进制流）")
    @GetMapping("/download/raw")
    public ResponseEntity<byte[]> downloadRaw(@RequestParam("key") String key) {
        ensureEnabled();
        byte[] bytes = cosStorageService.downloadBytes(key);

        String filename = key;
        if (filename.contains("/")) {
            filename = filename.substring(filename.lastIndexOf('/') + 1);
        }

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .body(bytes);
    }

    @Operation(summary = "删除对象")
    @DeleteMapping("/delete")
    public R<Void> delete(@RequestParam("key") String key) {
        ensureEnabled();
        cosStorageService.delete(key);
        return R.ok();
    }

    @Operation(summary = "连接状态检查")
    @GetMapping("/health")
    public R<Map<String, Object>> health() {
        ensureEnabled();
        cosStorageService.healthCheck();
        Map<String, Object> data = new HashMap<>();
        data.put("available", true);
        data.put("checkedAt", LocalDateTime.now().toString());
        return R.ok(data);
    }

    @Operation(summary = "连接测试（上传/列表/下载/删除）")
    @PostMapping("/test")
    public R<Map<String, Object>> test() {
        ensureEnabled();
        String key = "test/connection-" + UUID.randomUUID() + ".txt";
        String content = "COS连接测试：" + LocalDateTime.now();
        byte[] bytes = content.getBytes(StandardCharsets.UTF_8);

        Map<String, Object> result = new HashMap<>();
        result.put("key", key);

        String url = cosStorageService.uploadBytes(bytes, key, "text/plain; charset=utf-8");
        result.put("uploadUrl", url);

        List<COSObjectSummary> list = cosStorageService.list("test/connection-", 20);
        boolean listed = list.stream().anyMatch(o -> key.equals(o.getKey()));
        result.put("listOk", listed);

        byte[] downloaded = cosStorageService.downloadBytes(key);
        boolean downloadOk = content.equals(new String(downloaded, StandardCharsets.UTF_8));
        result.put("downloadOk", downloadOk);

        cosStorageService.delete(key);
        result.put("deleteOk", true);

        result.put("success", listed && downloadOk);
        return R.ok(result);
    }

    private void ensureEnabled() {
        if (cosStorageService == null) {
            throw new RuntimeException("COS 未启用或未配置密钥：请设置 tencent.cos.enabled=true，并配置环境变量 TENCENT_COS_SECRET_ID 与 TENCENT_COS_SECRET_KEY");
        }
    }
}
